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


VERSION=0.1.1
SUFFIX=x86_64-unknown-linux-musl
BASENAME=delta-${VERSION}-${SUFFIX}
URL=https://github.com/dandavison/delta/releases/download/${VERSION}/${BASENAME}.tar.gz

# Retrieve
wget $URL

# Extract
tar xzvf ${BASENAME}.tar.gz

# Install
cd $BASENAME
cp -rfv delta $PREFIX/bin/delta

# Clean
cd ..
rm -rfv $BASENAME $BASENAME.tar.gz
