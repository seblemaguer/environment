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
    echo "$0 [-s] [-j <nb_proc>] <prefix> ($#)"
    exit -1
fi

PREFIX=$1

#####################################################################################################

# 1. Install pip
PIP=pip
case `python -mplatform | sed 's/.*-with-//g'` in
    Darwin)
    ;;
    Ubuntu)
        sudo easy_install3 pip
        PIP=pip3
        ;;
    arch)
        ;;
    *)
        exit -1
        ;;
esac
sudo $PIP install --upgrade pip

#####################################################################################################

# 2. Install scientific part
$PIP install --user numpy scipy
$PIP install --user sklearn

# 3. LSP
$PIP install --user jedi
$PIP install --user "python-language-server[all]"

# 4. Install needed stuff form emacs/ipython communication
$PIP install --user jupyter jupyter-console jupyter-client

# 5. Plotting part
$PIP install --user matplotlib
$PIP install --user cairocffi
$PIP install --user plotnine
