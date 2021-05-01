#!/bin/zsh

NB_PROC=1

# Dealing with options
while getopts ":j:h" opt; do
    case $opt in
        j)
            NB_PROC=$OPTARG
            echo "parallel mode activated with $NB_PROC process" >&2
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

#  Retrieve the submodules
git submodule update --init
git submodule update --remote

# Now start the installation
rm -rf local
./install.sh -j $NB_PROC -r
