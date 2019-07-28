#!/bin/zsh

#FIXME: only ubuntu support for now
if [ ! -e /usr/bin/node ]
then
    sudo ln -s /usr/bin/nodejs /usr/bin/node
fi

# install imapnotify
sudo npm install -g imapnotify
