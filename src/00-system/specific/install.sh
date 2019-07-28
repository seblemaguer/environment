#!/bin/zsh

# Dealing with options
NB_PROC=1
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
OPT_SERVER=""

if [ "$SERVER_MODE_ON" = true ]
then
  OPT_SERVER="-s"
fi

####################################################################################################


# Adapt python
if [ "$SERVER_MODE_ON" != true ]
then
    zsh $PWD/python.sh $OPT_SERVER -j $NB_PROC $PREFIX
fi

# Adapt R
if [ "$SERVER_MODE_ON" != true ]
then
    zsh $PWD/R.sh $OPT_SERVER -j $NB_PROC $PREFIX
fi

# Change the shell
if [ "$SERVER_MODE_ON" != true ]
then
    sudo chsh -s /bin/zsh lemagues
fi

# Install the mail part
if [ "$SERVER_MODE_ON" != true ]
then
    zsh $PWD/mail.sh $OPT_SERVER -j $NB_PROC $PREFIX
fi

# Install google-drive commandline utilty
if [ "$SERVER_MODE_ON" != true ]
then
    go get -u github.com/odeke-em/drive/cmd/drive
fi
