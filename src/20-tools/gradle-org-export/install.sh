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


if [ "$SERVER_MODE_ON" != true ]
then
    # Install the actual plugin
    if [[ ! -e $PREFIX/apps/gradle-org-export-plugin ]]; then
        git clone git@github.com:seblemaguer/gradle-org-export-plugin.git $PREFIX/apps/gradle-org-export-plugin
    fi

    # Add useful helper
    sed "s%###PREFIX###%$PREFIX%g" $PWD/assets/gradle_export.sh > $PREFIX/bin/gradle_export
    chmod +x $PREFIX/bin/gradle_export
fi
