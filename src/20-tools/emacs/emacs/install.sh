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

# Get the source
git clone --branch emacs-27.1 --depth 1 https://github.com/emacs-mirror/emacs.git
cd emacs

# Configure
./autogen.sh

if [ "$SERVER_MODE_ON" != true ]
then
    ./configure --with-cairo --with-json --with-modules --prefix=$PREFIX/emacs
else
    ./configure ---without-xpm --without-gif --with-json --with-modules --prefix=$PREFIX/emacs
fi

# Compile
make -j $NB_PROC

# Install
make install
