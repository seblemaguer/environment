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
sudo add-apt-repository --yes "deb http://archive.canonical.com/ $(lsb_release -sc) partner"

# Add surface repository
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \ | sudo apt-key add -
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list

# Add xournalpp repository
sudo add-apt-repository --yes ppa:andreasbutti/xournalpp-master

# Add teams repository
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" | sudo tee /etc/apt/sources.list.d/teams.list

# Add qarte repository
wget -O- 'https://build.opensuse.org/projects/home:jgeboski/public_key' | sudo apt-key add -
sudo add-apt-repository --yes ppa:vincent-vandevyvre/vvv

# Add Nodejs repository
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
rm -rfv nodesource_setup.sh

# Update the system
sudo apt-get update
sudo apt-get -q -y dist-upgrade

# Package installation
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    sudo apt-get -y --fix-missing install `sed 's/[ ]*(.*//g' $l | tr '\n' ' '` # TODO: delete empty lines
done

# Define some group
sudo usermod -aG docker $USER
