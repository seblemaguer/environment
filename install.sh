#!/bin/zsh

# Set environment path to the current directory
ENV_PATH=$PWD
export PATH=$ENV_PATH/local/bin:$PATH
NB_PROC=1

# Dealing with options
while getopts ":j:hrs" opt; do
    case $opt in
        j)
            NB_PROC=$OPTARG
            echo "parallel mode activated with $NB_PROC process" >&2
            ;;
        r)
            echo "reinstall from scratch" >&2
            SCRATCH_INSTALL=true
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

# -1. clean the local environment to restart from scratch
if [ "$SCRATCH_INSTALL" = true ]
then
    rm -rf $ENV_PATH/local
    mkdir -p $ENV_PATH/local/bin
    mkdir -p $ENV_PATH/local/lib
fi


# Update in case off
git pull

# Installing different part
for src_dir in `ls -d src/*`
do
    echo "=============================================================================="
    echo "### Installating from $src_dir"
    echo "=============================================================================="
    if [ "$SERVER_MODE_ON" = true ]
    then
        (cd "$src_dir"; zsh "install.sh" -s -j "$NB_PROC" "$ENV_PATH/local")
    else
        (cd "$src_dir"; zsh "install.sh"    -j "$NB_PROC" "$ENV_PATH/local")
    fi
done
