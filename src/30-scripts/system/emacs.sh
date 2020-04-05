#!/bin/zsh

# - Mac terminal/emacs issue
case `uname` in
    Darwin*)
        EMACS_DIR=$HOME/Applications/Emacs.app/Contents/MacOS/
        EMACS_CMD=$EMACS_DIR/Emacs
        EMACS_CLIENT_CMD=$EMACS_DIR/bin/emacsclient
        ;;
    *)
        EMACS_DIR=/usr/bin
        EMACS_CMD=$EMACS_DIR/emacs
        EMACS_CLIENT_CMD=$EMACS_DIR/emacsclient
        ;;;
esac

# SERVER_FILE

CURTMPDIR=/tmp
if [ "$TMPDIR" != "" ]
then
    CURTMPDIR=$TMPDIR
fi

USERID=`id | sed 's/uid=\([0-9][0-9]*\)(.*/\1/'`
SERVER_FILE=$CURTMPDIR/emacs$USERID/server
if ! test -e $SERVER_FILE
then
    SERVER_FILE=/run/user/$USERID/emacs/server
fi

cmd=`echo "$*" | grep -c -- "-\(stop\)"`
if [ $cmd -ne 0 ]
then
    if test -e $SERVER_FILE
    then
        $EMACS_CLIENT_CMD -e "(kill-emacs)"
        rm -rf $SERVER_FILE
    else
        echo "emacs already stopped"
    fi
    exit 0;
fi

# Check command line
cmd=`echo "$*" | grep -c -- "-\(batch\|version\|debug-init\|Q\|q\)"`
if [ $cmd -ne 0 ]
then
    #echo $cmd
    cmd=($EMACS_CMD $*)
    #echo "...$cmd..."
    $cmd
    exit $?
else

	cmd=`echo "$*" | grep -c -- "-\(nw\|t\|tty\)"`
	# Emacs client specific
	if [ $cmd -ne 0 ]
	then
		$EMACS_CLIENT_CMD $*
	# Normal!
	else
		if test -e $SERVER_FILE
		then
			echo "Ready."
		else
			echo "Starting server."
			$EMACS_CMD --daemon
		fi
    	$EMACS_CLIENT_CMD -c "$@"
	fi
fi
