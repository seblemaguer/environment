#!/bin/zsh

# Set environment path to the current directory
NB_PROC=1

# Dealing with options
while getopts ":j:hs" opt; do
    case $opt in
        j)
            NB_PROC=$OPTARG
            echo "parallel mode activated with $NB_PROC process" >&2
            ;;
        s)
            echo "server mode installation activated" >&2
            SERVER_MODE_ON=true
            ;;
        h)
            echo "An help part should be done" >&2
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done
shift $OPTIND-1

# Dealing with arguments
if [ $# -lt 1 ]
then
    echo "$0 [-s] [-j <nb_proc>] <prefix>"
    exit -1
fi
PREFIX=$1

# Reset the source the source
rm -rfv emacs
git clone --branch emacs-29 --depth 1 https://github.com/emacs-mirror/emacs.git
cd emacs

# Configure
export CC="gcc-12"
CC="gcc-12" ./autogen.sh
if [ "$SERVER_MODE_ON" != true ]
then
    ./configure                              --with-json --with-modules --with-x-toolkit=gtk3 --with-xwidgets --with-native-compilation --with-tree-sitter --prefix=$PREFIX/apps/emacs --mandir=$PREFIX/share/man --infodir=$PREFIX/share/info
else
    ./configure ---without-xpm --without-gif --with-json --with-modules                                       --with-native-compilation --with-tree-sitter --prefix=$PREFIX/apps/emacs --mandir=$PREFIX/share/man --infodir=$PREFIX/share/info
fi

# Compile
make -j $NB_PROC

# Install
make install

# Clean
cd ../
rm -rf emacs

#############################################
# Install tree-sitter helpers
##############################################
if [ "$SERVER_MODE_ON" != true ]
then
    git clone https://github.com/casouri/tree-sitter-module.git
    cd tree-sitter-module
    JOBS=$NB_PROC ./batch.sh
    mkdir ~/.emacs.d/tree-sitter
    cp -rfv dist/* ~/.emacs.d/tree-sitter
    cd ..
    rm -rf tree-sitter-module
fi

#############################################
# Install tdlib (needed for telega)
##############################################
if [ "$SERVER_MODE_ON" != true ]
then
    git clone --branch master --depth 1 https://github.com/tdlib/td
    cd td
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX ..
    cmake --build . --target prepare_cross_compiling -j $NB_PROC

    # This bit is necessary to avoid memory overflow
    cd ..
    php SplitSource.php
    cd build
    cmake --build . --target tdjson -j $NB_PROC
    cmake --build . --target tdjson_static -j $NB_PROC

    # Now we install and clean
    make install
    cd ../..
    rm -rf td
fi

#############################################
# Install language servers
##############################################
if [ "$SERVER_MODE_ON" != true ]
then
    # Easy NPM based installation
    npm install -g bash-language-server
    npm install -g @emacs-grammarly/grammarly-languageserver
    npm install -g dockerfile-language-server-nodejs

    # kotlin is a bit more tricky
    git clone https://github.com/fwcd/kotlin-language-server.git
    (
        cd kotlin-language-server;
        ./gradlew :server:installDist;
        cp server/build/install/server/bin/kotlin-language-server $PREFIX/bin;
        cp server/build/install/server/lib/* $PREFIX/lib
    )
    rm -rfv kotlin-language-server

    # Pip/Python ones to install
    pip install cmake-language-server
fi
