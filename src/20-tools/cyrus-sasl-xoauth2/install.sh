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
    git clone git@github.com:moriyoshi/cyrus-sasl-xoauth2.git
    cd cyrus-sasl-xoauth2
    ./autogen.sh
    ./autogen.sh # NOTE: needed because the first one fails without ltmain.sh
    ./configure --prefix=/usr --libdir=/usr/lib64
    sed -i 's%pkglibdir = ${CYRUS_SASL_PREFIX}/lib/sasl2%pkglibdir = ${CYRUS_SASL_PREFIX}/lib64/sasl2%' Makefile
    make -j $NB_PROC
    sudo make install
    cd ../
    rm -rf cyrus-sasl-xoauth2
fi
