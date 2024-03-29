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

if [ "$SERVER_MODE_ON" != true ]
then
    git clone https://github.com/oniony/TMSU.git
    (
        cd TMSU
        make -j $NB_PROC
        cp $PWD/bin/tmsu -t $PREFIX/bin/
        cp $PWD/misc/bin/tmsu-* -t $PREFIX/bin/

        mkdir -p $PREFIX/share/man/man1
        gzip -fc $PWD/misc/man/tmsu.1 > $PREFIX/share/man/man1/tmsu.1.gz
        mkdir -p $PREFIX/share/zsh/site-functions
        cp $PWD/misc/zsh/_tmsu -t $PREFIX/share/zsh/site-functions
        mkdir -p $PREFIX/etc/bash_completion.d
        cp $PWD/misc/bash/tmsu -t $PREFIX/etc/bash_completion.d
    )
    rm -rf TMSU
fi
