#!/bin/zsh

# Default values
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

if [ $# -lt 1 ]
then
    echo "$0 [-s] [-j <nb_proc>] <prefix>"
    exit -1
fi

PREFIX=$1

if [ "$SERVER_MODE_ON" != true ]
then
    (
        PATH=$PATH:$PREFIX/emacs/bin
        emacs --version

        # Prepare
        git clone git@github.com:djcb/mu.git
        cd mu

        # Build
        ./autogen.sh --prefix=$PREFIX
        make -j $NB_PROC

        # Install
        make install

        # Clean
        cd ..
        rm -rf mu
    )
fi
