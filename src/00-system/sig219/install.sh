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

sudo dnf -y upgrade
sudo dnf -y update

# Add brave repository
sudo dnf -y config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Add font repository
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install helpers
sudo dnf group install "C Development Tools and Libraries" "Development Tools"

# Install the packages
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    (
        sudo dnf -y install $(grep -v "^#" $l | sed 's/[ ]*(.*//g' | tr '\n' ' ') # TODO: delete empty lines
    )
done

# Change shell
sudo chsh -s /bin/zsh $USER

# Set docker bits
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
