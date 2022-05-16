#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Command should be: $0 <album_dir> <root_dir>"
    exit -1
fi

# Have better variable names
album_dir=$(realpath "$1")
root_dir=$(realpath "$2")

shopt -s nullglob
list_tracks=("$album_dir"/*.flac)
shopt -u nullglob # Turn off nullglob to make sure it doesn't interfere with anything later

IFS=$'\n'
for track_file in ${list_tracks[@]}
do
    # Extract proper variables
    part_to_parse=$(echo "$track_file" | sed "s%$root_dir/%%g")
    ARTIST=$(echo $part_to_parse | sed "s%/.*%%g")
    ALBUM=$(echo $part_to_parse | sed "s%[^/]*/[0-9X]\+ - \([^/]*\)/.*%\1%g")
    DATE=$(echo $part_to_parse | sed "s%[^/]*/\([0-9X]\+\) - .*%\1%g")
    TRACKNUMBER=$(echo $part_to_parse | sed "s%[^/]*/[^/]*/\([0-9]\+\) - .*%\1%g")
    TITLE=$(echo $part_to_parse | sed "s%[^/]*/[^/]*/[^-]\+ - \(.*\).flac%\1%g")

    # Fix tags
    tag=ALBUM;       metaflac --remove-tag=$tag "--set-tag=$tag=$ALBUM" "$track_file"
    tag=ARTIST;      metaflac --remove-tag=$tag "--set-tag=$tag=$ARTIST" "$track_file"
    tag=TITLE;       metaflac --remove-tag=$tag "--set-tag=$tag=$TITLE" "$track_file"
    tag=TRACKNUMBER; metaflac --remove-tag=$tag "--set-tag=$tag=$TRACKNUMBER" "$track_file"
    tag=DATE;        metaflac --remove-tag=$tag "--set-tag=$tag=$DATE" "$track_file"
done
