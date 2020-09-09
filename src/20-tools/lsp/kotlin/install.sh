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

(
    # Prepare
    git clone git@github.com:fwcd/kotlin-language-server.git
    cd kotlin-language-server

    # Build
    ./gradlew :server:installDist --max-workers=$NB_PROC

    # Install
    rsync -avP server/build/install/server/bin/ $PREFIX/bin
    rsync -avP server/build/install/server/lib/ $PREFIX/lib

    # Clean
    cd ../
    rm -rfv kotlin-language-server
)
