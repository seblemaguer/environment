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


# Install mamba
echo "==== Get Mamba"
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-pypy3-$(uname)-$(uname -m).sh"
bash "Mambaforge-pypy3-$(uname)-$(uname -m).sh" -b -p "${PREFIX}/miniconda3"

source "${PREFIX}/miniconda3/etc/profile.d/conda.sh"
conda activate
source "${PREFIX}/miniconda3/etc/profile.d/mamba.sh"

# Activate conda (FIXME: should not be needed!)
source $PREFIX/miniconda3/etc/profile.d/conda.sh
conda init

# Install baseline packages
echo "=== Install ipython & black in the base environment"
mamba install -y ipython black pandas -n base -c conda-forge

# Installing the different environment
for env in `ls -d environments/*`
do
    echo "==== Creating conda environment from $PWD/$env"
    mamba env create -q -f $env
done

# Cleaning
echo "==== Cleaning conda installer"
rm -rfv "Mambaforge-pypy3-$(uname)-$(uname -m).sh"
