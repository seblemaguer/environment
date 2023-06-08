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

# GDU
curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
chmod +x gdu_linux_amd64
mv gdu_linux_amd64 $PREFIX/bin/gdu


# Delta
VERSION=0.16.5
SUFFIX=x86_64-unknown-linux-musl
BASENAME=delta-${VERSION}-${SUFFIX}
curl -L https://github.com/dandavison/delta/releases/download/${VERSION}/${BASENAME}.tar.gz \
     --output /dev/stdout \
    | tar xz

# Install
cp -rfv $BASENAME/delta $PREFIX/bin/delta

# Clean
rm -rfv $BASENAME
