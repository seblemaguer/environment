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


if [ "$SERVER_MODE_ON" != true ]
then
    ECLIPSE_NAME=eclipse-android-neon-R-incubation-linux-gtk-x86_64.tar.gz

    # Download and extract eclipse
    wget http://artfiles.org/eclipse.org//technology/epp/downloads/release/neon/R/$ECLIPSE_NAME
    tar xvzf $ECLIPSE_NAME

    # "Install"
    mkdir -p $PREFIX/share
    mv eclipse $PREFIX/share
    ln -s $PREFIX/share/eclipse/eclipse $PREFIX/bin

    # Cleaning
    rm -rfv $ECLIPSE_NAME
fi
