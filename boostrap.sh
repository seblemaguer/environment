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

# Install important packages
case `python -mplatform | sed 's/.*-with-//g'` in
    Darwin)
        ;;
    Ubuntu)
        sudo apt-get install zsh git
        ;;
    arch)
        sudo pacman --noconfirm -S zsh git openssh
        ;;
    *)
        exit -1
        ;;
esac

#  Retrieve the submodules
git submodule update --init
git submodule update --remote

# Now start the installation
./install.sh -j $NB_PROC -r
