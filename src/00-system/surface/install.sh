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
    echo "$0 [-s] [-j <nb_proc>] <prefix>"
    exit -1
fi

PREFIX=$1


# Some activation
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"

# Add surface repository
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list

# Add bitlbee repository
echo "deb http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_19.10 ./"  | sudo tee /etc/apt/sources.list.d/bitlbee.list

# Add qarte repository
wget -O- 'https://build.opensuse.org/projects/home:jgeboski/public_key' | sudo apt-key add -

sudo add-apt-repository ppa:vincent-vandevyvre/vvv

# Update the system
sudo apt-get update
sudo apt-get -q -y dist-upgrade

# Package installation
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    sudo apt-get -y --fix-missing install `sed 's/[ ]*(.*//g' $l | tr '\n' ' '` # TODO: delete empty lines
done
