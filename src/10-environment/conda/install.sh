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
echo "==== Get Microamba"
BIN_FOLDER=$PREFIX/bin INIT_YES=yes CONDA_FORGE_YES=yes PREFIX_LOCATION=$PREFIX/micromamba \
                       "${SHELL}" <(curl -L micro.mamba.pm/install.sh) <&-
alias conda=micromamba

# Install baseline environment
conda create -r $HOME/environment/local/micromamba/ -n local_environment python=3.10
if [ "$SERVER_MODE_ON" != true ]
then
    case `hostname` in
        surface.home)
            conda in
            (cd $PWD/surface; zsh install.sh $OPT_SERVER -j $NB_PROC $PREFIX)
            ;;

    	# NOTE: for now, the work is assumed to be the most restrictive, so let's roll with it by default
        *)
            conda run -r $HOME/environment/local/micromamba/ -n local_environment pip install emailproxy[gui]
            ;;
    esac
fi
