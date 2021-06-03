#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Command should be: $0 <track_file> <root_dir>"
    exit -1
fi

# Have better variable names
track_file=$1
root_dir=$2

# Extract proper variables
part_to_parse=$(echo $track_file | sed "s%$root_dir%%g")
ARTIST=$(echo $part_to_parse | sed "s%/.*%%g")
ALBUM=$(echo $part_to_parse | sed "s%[^/]*/[0-9]\+ - \([^/]*\)/.*%\1%g")
DATE=$(echo $part_to_parse | sed "s%[^/]*/\([0-9]\+\) - .*%\1%g")
TRACKNUMBER=$(echo $part_to_parse | sed "s%[^/]*/[^/]*/\([0-9]\+\) - .*%\1%g")
TITLE=$(echo $part_to_parse | sed "s%[^/]*/[^/]*/[0-9]\+ - \(.*\).flac%\1%g")

# Fix tags
tag=ALBUM;       metaflac --remove-tag=$tag "--set-tag=$tag=$ALBUM" "$track_file"
tag=ARTIST;      metaflac --remove-tag=$tag "--set-tag=$tag=$ARTIST" "$track_file"
tag=TITLE;       metaflac --remove-tag=$tag "--set-tag=$tag=$TITLE" "$track_file"
tag=TRACKNUMBER; metaflac --remove-tag=$tag "--set-tag=$tag=$TRACKNUMBER" "$track_file"
tag=DATE;        metaflac --remove-tag=$tag "--set-tag=$tag=$DATE" "$track_file"
