#!/bin/zsh

# Dealing with options
NB_PROC=1
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
OPT_SERVER=""

if [ "$SERVER_MODE_ON" = true ]
then
  OPT_SERVER="-s"
fi

if [ "$SERVER_MODE_ON" != true ]
then
    case `hostname` in
        Darwin)
            zsh $PWD/mac/install.sh $OPT_SERVER -j $NB_PROC $PREFIX
            ;;
        lemagues-surface)
            (cd $PWD/surface; zsh install.sh $OPT_SERVER -j $NB_PROC $PREFIX)
            ;;
        arch)
            (cd $PWD/arch; zsh install.sh $OPT_SERVER -j $NB_PROC $PREFIX)
            ;;
        *)
            exit -1
            ;;
    esac
fi
