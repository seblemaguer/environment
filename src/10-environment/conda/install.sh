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

# Conda and install conda
echo "==== Get conda"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
zsh /tmp/miniconda.sh -q -b -p $PREFIX/miniconda3

# Activate conda (FIXME: should not be needed!)
source $HOME/environment/local/miniconda3/etc/profile.d/conda.sh

# Update conda
echo "==== Update conda"
conda update -q -y -n base -c defaults conda

# Installing the different environment
for env in `ls -d environments/*`
do

    echo "==== Creating conda environment from $PWD/$env"
    conda env create -q -f $env
done

# Cleaning
echo "==== Cleaning conda installer"
rm -rfv /tmp/miniconda.sh
