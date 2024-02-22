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

# sudo apt-get -y upgrade
# sudo apt-get -y update

# Install surface part
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" \
	| sudo tee /etc/apt/sources.list.d/linux-surface.list
sudo apt-get install -y  linux-image-surface linux-headers-surface libwacom-surface iptsd
sudo systemctl enable iptsd
sudo apt-get install -y linux-surface-secureboot-mok
sudo update-grub

# Install the packages
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    (
        sudo apt-get -y install $(grep -v "^#" $l | sed 's/[ ]*(.*//g' | tr '\n' ' ') # TODO: delete empty lines
    )
done

# Define some user specificities
sudo usermod -aG docker $USER
sudo chsh -s /bin/zsh $USER
