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

# Prepare surface specific installation
if [ `grep -c "linux-surface" /etc/pacman.conf` = 0 ]
then
    # curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc | sudo pacman-key --add -
    # sudo pacman-key --finger 56C464BAAC421453
    # sudo pacman-key --lsign-key 56C464BAAC421453
    # echo "" | sudo tee -a /etc/pacman.conf
    # echo "[linux-surface]" | sudo tee -a /etc/pacman.conf
    # echo "Server = https://pkg.surfacelinux.com/arch/" | sudo tee -a /etc/pacman.conf
    echo "We ignore this for now!"
fi

# Update the system
sudo pacman -Syu

# Package installation
# sudo pacman -S --noconfirm yay
for l in `ls -1 package_lists/*`
do
    printf "########################### %-60s ##########################\n" $l
    (
        unset LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE
        yay -S --noconfirm `grep -v "^#" $l | sed 's/[ ]*(.*//g' | tr '\n' ' '` # TODO: delete empty lines
    )
done

# Define some group
sudo usermod -aG docker $USER

# Finalize surface
sudo systemctl enable iptsd
sudo grub-mkconfig -o /boot/grub/grub.cfg
