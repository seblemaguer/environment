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
git clone --branch master --depth 1 https://github.com/emacs-mirror/emacs.git
cd emacs

# Configure
./autogen.sh

if [ "$SERVER_MODE_ON" != true ]
then
    ./configure --with-pgtk --with-json --with-modules --with-xwidgets --with-native-compilation --prefix=$PREFIX/apps/emacs
else
    ./configure ---without-xpm --without-gif --with-json --with-modules --with-native-compilation --prefix=$PREFIX/apps/emacs
fi

# Compile
make -j $NB_PROC

# Install
make install

# Clean
cd ../
rm -rf emacs

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
    rm -rfv td
fi
