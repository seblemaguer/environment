#!/bin/zsh

flac=$1
parent_dir=`dirname $flac`
date=`stat -c %y "$flac"`
metaflac --remove --block-type=PICTURE $flac
metaflac --import-picture-from=$parent_dir/cover_med.jpg $flac
touch -d "$date" $flac
