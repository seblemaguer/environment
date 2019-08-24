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

# Music part
if [ "$SERVER_MODE_ON" != true ]
then
    ln -s $PWD/music_management/cover_convert.sh $PREFIX/bin/cover_convert
    ln -s $PWD/music_management/split2flac.sh $PREFIX/bin/split2flac
    ln -s $PWD/music_management/explode_flac.sh $PREFIX/bin/explode_flac
    ln -s $PWD/music_management/emms-print-metadata.pl $PREFIX/bin/emms-print-metadata
fi

# Versioning part
ln -s $PWD/cvs/init_git.sh $PREFIX/bin/init_git
ln -s $PWD/cvs/prune_history.sh $PREFIX/bin/prune_history

# Latex part
ln -s $PWD/latex_utils/compilePGF.py $PREFIX/bin/compilePGF

# Mailing
ln -s $PWD/system/sendmail.sh $PREFIX/bin/sendmail
ln -s $PWD/system/stamp_mails.sh $PREFIX/bin/stamp_mails
ln -s $PWD/system/syncmail.sh $PREFIX/bin/syncmail
ln -s $PWD/system/emacs.sh $PREFIX/bin/emacs

