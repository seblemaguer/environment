#!/bin/zsh

NB_PROC=1
EMACS_VERSION=30.2

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
    if [ ! -e $PWD/sltools ]; then
        git clone git@github.com:seblemaguer/sltools.git
    fi

    (
        cd sltools
        git pull # Ensure everything is up-to-date

        # Install only the dedicated local environment
        micromamba run -n local_environment pip install -e .
    )
fi
