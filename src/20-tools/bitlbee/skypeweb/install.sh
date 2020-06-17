#!/bin/zsh

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
    # Preparing
    git clone git://github.com/EionRobb/skype4pidgin.git
    cd skype4pidgin/skypeweb
    mkdir build
    cd build

    # Compiling and packing
    cmake ..
    cpack

    # Install
    sudo apt install -y `ls ./*.deb`

    # Cleaning
    cd ../../..
    rm -rfv skype4pidgin
fi
