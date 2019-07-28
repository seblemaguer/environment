#!/bin/zsh

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

if [ $# -lt 1 ]
then
    echo "$0 [-s] [-j <nb_proc>] <prefix>"
    exit -1
fi

PREFIX=$1

# Install the last version of R
if [ "$SERVER_MODE_ON" != true ]
then
    # Get root dir according to platform
    case `python -mplatform | sed 's/.*-with-//g'` in
        Darwin)
            echo "Darwin"
            ;;
        Ubuntu)
            if [ `grep -c "cran" /etc/apt/sources.list` -lt 1 ]
            then
                export UBUNTU_VERSION=`lsb_release -a 2>/dev/null| grep Codename | cut -d':' -f2 | sed 's/^[ \t]*//g'`
                echo "deb https://cran.univ-paris1.fr/bin/linux/ubuntu $UBUNTU_VERSION/" | sudo tee -a /etc/apt/sources.list > /dev/null
                sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
                sudo apt-get update
                sudo apt-get -q -y dist-upgrade
            fi
            ;;
        arch)
            ;;
        *)
            exit -1
            ;;
    esac
fi

# Dealing with the root directory
mkdir -p $PREFIX/R
export R_LIBS=$PREFIX/R

# Install package (NOTE: suppose that the repos is defined in the .Rprofile)
R -e "install.packages('ggplot2', Ncpus=$NB_PROC)"
R -e "install.packages('ggmosaic', Ncpus=$NB_PROC)"
R -e "install.packages('reshape', Ncpus=$NB_PROC)"
R -e "install.packages('lintr', Ncpus=$NB_PROC)"
R -e "install.packages('languageR', Ncpus=$NB_PROC)"
R -e "install.packages('prettyR', Ncpus=$NB_PROC)"
R -e "install.packages('dplyr', Ncpus=$NB_PROC)"
R -e "install.packages('ez', Ncpus=$NB_PROC)"
R -e "install.packages('lsr', Ncpus=$NB_PROC)"
R -e "install.packages('lmtest', Ncpus=$NB_PROC)"
R -e "install.packages('psych', Ncpus=$NB_PROC)"
R -e "install.packages('tikzDevice', Ncpus=$NB_PROC)"
R -e "install.packages('docopt', Ncpus=$NB_PROC)"
R -e "install.packages('tidyr', Ncpus=$NB_PROC)"
