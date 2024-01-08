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
sudo dnf -y install dnf-plugins-core

# Install surface part
sudo dnf -y config-manager \
     --add-repo=https://pkg.surfacelinux.com/fedora/linux-surface.repo
sudo dnf -y install --allowerasing kernel-surface kernel-surface-devel iptsd libwacom-surface
sudo systemctl enable iptsd
sudo dnf -y install surface-secureboot

# Ensure the proper kernel is installed
sudo cp $PWD/attachments/default-kernel.path /etc/systemd/system/default-kernel.path
sudo cp $PWD/attachments/default-kernel.service /etc/systemd/system/default-kernel.service
sudo systemctl enable default-kernel.path
sudo grubby --set-default /boot/vmlinuz*surface*

# Add font repository
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install the packages
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    (
        sudo dnf -y install --skip-broken $(grep -v "^#" $l | sed 's/[ ]*(.*//g' | tr '\n' ' ') # TODO: delete empty lines
    )
done

# Deal with multimedia bits (FIXME: see how to make this a bit more integrated)
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-plugin-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia --allowerasing
sudo dnf remove totem

# Define some user specificities
sudo usermod -aG docker $USER
sudo chsh -s /bin/zsh $USER
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
