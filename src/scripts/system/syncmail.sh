#!/bin/sh

if [ $# -ne 1 ]
then
    echo "$0 <mail account>"
    exit -1
fi


wget --timeout=15 --spider www.google.fr &> /dev/null
if [ $? -eq 0 ]
then
    # Clean what needs to be cleaned
    notmuch search --format=text0 --output=files tag:deleted | xargs -0 --no-run-if-empty rm

    # Run queue if only there is something in the queue
    nb_mail_in_queue=`ls -1 $HOME/.msmtpqueue | wc -l`
    if [ $nb_mail_in_queue -gt 0 ]
    then
        /usr/share/doc/msmtp/examples/msmtpqueue/msmtp-runqueue.sh
    fi

    # Update account
    mbsync -qq $1

    # Check if emacs is started
    CURTMPDIR=/tmp
    if [ "$TMPDIR" != "" ]
    then
        CURTMPDIR=$TMPDIR
    fi
    USERID=`id | sed 's/uid=\([0-9][0-9]*\)(.*/\1/'`
    if test -e $CURTMPDIR/emacs$USERID/server
    then
        emacsclient --eval "(notmuch-update-index)"
    fi
fi

exit 0
