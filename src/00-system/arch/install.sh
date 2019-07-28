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

# Pacaur bootstrap
curl https://gist.githubusercontent.com/seblemaguer/ffcb5462e14a2ccbb59b53cc283518c0/raw/c7ab0a994f38505387094c6e3a0c3c7667fdc224/install-trizen.sh > install-trizen.sh
sh install-trizen.sh
rm -rfv install-trizen.sh

# Update system
trizen -Syu --aur

# Package installation
for l in `ls -1 arch_package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    trizen --needed --noconfirm -S `sed 's/[ ]*(.*//g' $l | grep -v "^#" | tr '\n' ' '` # TODO: delete empty lines
done

# Change locale for X-server
sudo localectl set-x11-keymap fr

# Define some configurations
sudo cp -f global_conf/lightdm.conf /etc/lightdm/
sudo cp -f global_conf/51-blueman.rules /etc/polkit-1/rules.d/

# User
username=`whoami`
sudo usermod -a -G wheel $username
sudo usermod -a -G docker $username

# Enable some service
sudo systemctl enable lightdm.service
sudo systemctl enable bluetooth
sudo systemctl enable bitlbee
sudo systemctl enable org.cups.cupsd.service
sudo systemctl enable postfix
sudo systemctl enable docker.service
