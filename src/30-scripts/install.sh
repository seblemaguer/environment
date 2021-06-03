#!/bin/zsh

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

# Music part
if [ "$SERVER_MODE_ON" != true ]
then
    for f in $(find . -name '*.*')
    do
        dir=$(dirname $f)
        if [ "$dir" != "." ]
        then
            base=$(basename $f | cut -d'.' -f 1)
            f=$(realpath $f)
            ln -s $f $PREFIX/bin/$base
        fi
    done
fi
