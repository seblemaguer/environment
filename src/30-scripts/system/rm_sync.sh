#!/bin/bash

rsync -avP remarkable:.local/share/remarkable/xochitl/ $HOME/shared/remarkable-db
borg_backup -R $HOME/shared/bkup $HOME/shared/remarkable-db
