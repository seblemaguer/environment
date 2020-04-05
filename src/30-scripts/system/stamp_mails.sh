#!/bin/bash
for i in `ls`
do
    # Find the date field and then remove up to the first space (Date: )
    DATE=$(grep '^Date:' $i | head -1 | cut -d' ' -f1 --complement)

    # Create a timestamp from the date above
    STAMP=$(date --date="$DATE" +%Y%m%d%H%M)

    # touch the file with the correct timestamp
    touch -t $STAMP $i

    echo "$i stamped"
done
