#!/bin/zsh

# Default values
NB_PROC=1
SERVER_MODE_ON=false

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

(
    # Prepare
    git clone git@github.com:prominic/groovy-language-server.git
    cd groovy-language-server

    # Build
    ./gradlew build --max-workers=$NB_PROC

    # Install
    mkdir -p $PREFIX/lib/
    cp -rfv build/libs/groovy-language-server-all.jar $PREFIX/lib

    # Clean
    cd ../
    rm -rfv groovy-language-server
)
