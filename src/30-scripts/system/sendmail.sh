#!/bin/zsh

# Get root dir according to platform
case `python -mplatform | sed 's/.*-with-//g'` in
    Darwin)
        echo "Darwin"
    ;;
    Ubuntu)
        ROOT_DIR=/usr/share/doc/msmtp/examples/msmtpqueue/
    ;;
    arch)
        ROOT_DIR=/usr/share/doc/msmtp/msmtpqueue
    ;;
    *)
        exit -1
    ;;
esac

# Enqueue
bash $ROOT_DIR/msmtp-enqueue.sh $*

# Check if the connection is on
wget --timeout=15 --spider www.user-contributions.org &> /dev/null
if [ $? -eq 0 ]
then
    bash $ROOT_DIR/msmtp-runqueue.sh > /dev/null&
fi

exit 0
