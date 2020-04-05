#!/bin/zsh

if [ $# -ne 1 ]
then
    echo "$0 <music root directory>"
    exit -1
fi

OUT=$1

msg="printf"
GETTAG=("cueprint" "-n" "1" "-t")
VALIDATE=("sed" "s/[^][[:space:][:alnum:]&_#,.'\"\(\)!-]//g")
OUTPATTERN="@artist/{@year - }@album/"

perlrename() {
    if hash perl-rename 2>/dev/null; then
        perl-rename "$@"
    else
        rename "$@"
    fi
}

# replaces a tag name with the value of the tag. $1=pattern $2=tag_name $3=tag_value
update_pattern_aux () {
    tag_name="$2"
    tag_value="$3"
    expr_match="@${tag_name}"
    expr_match_opt="[{]\([^}{]*\)${expr_match}\([^}]*\)[}]"

    echo "$1" | { [ "${tag_value}" ] \
		      && sed "s/${expr_match_opt}/\1${tag_value}\2/g;s/${expr_match}/${tag_value}/g" \
		          || sed "s/${expr_match_opt}//g;s/${expr_match}//g"; }
}

# replaces a tag name with the value of the tag. $1=pattern $2=tag_name $3=tag_value
update_pattern () {
    # replace '/' with '\' and '&' with '\&' for proper sed call
    tag_name=$(echo "$2" | sed 's,/,\\\\,g;s,&,\\&,g')
    tag_value=$(echo "$3" | sed 's,/,\\\\,g;s,&,\\&,g')

    v=$(update_pattern_aux "$1" "${tag_name}" "${tag_value}")
    update_pattern_aux "$v" "_${tag_name}" $(echo "${tag_value}" | sed "s/ /_/g")
}

export_cover() {

    CUE=$(echo "$1" | sed 's/\.flac/.cue/g')
    cat $CUE > CUE_TMP.cue
    echo "" >> CUE_TMP.cue
    CUE=CUE_TMP.cue

    # get common tags
    TAG_ARTIST=$(${GETTAG} %P "${CUE}" 2>/dev/null)
    TAG_ALBUM=$(${GETTAG} %T "${CUE}" 2>/dev/null)

    TAG_GENRE=$(grep 'REM[ \t]\+GENRE[ \t]\+' "${CUE}" | head -1 | sed 's/REM[ \t]\+GENRE[ \t]\+//;s/^"\(.*\)"$/\1/')
    TAG_CD_NUM=$(grep 'REM[ \t]\+DISCNUMBER[ \t]\+' "${CUE}" | head -1 | sed 's/REM[ \t]\+DISCNUMBER[ \t]\+//;s/^"\(.*\)"$/\1/')

    YEAR=$(awk '{ if (/REM[ \t]+DATE/) { date=$3; gsub("\"", "", date); printf "%s", date; exit } }' < "${CUE}")
    YEAR=$(echo ${YEAR} | tr -d -c '[:digit:]')

    unset TAG_DATE

    if [ -n "${YEAR}" ]; then
	[ ${YEAR} -ne 0 ] && TAG_DATE="${YEAR}"
    fi

    $msg "\n${cG}Artist :$cZ ${TAG_ARTIST}\n"
    $msg "${cG}Album  :$cZ ${TAG_ALBUM}\n"
    [ "${TAG_GENRE}" ] && $msg "${cG}Genre  :$cZ ${TAG_GENRE}\n"
    [ "${TAG_DATE}"  ] && $msg "${cG}Year   :$cZ ${TAG_DATE}\n"
    [ "${TAG_CD_NUM}"  ] && $msg "${cG}DISCNUM   :$cZ ${TAG_CD_NUM}\n"

    # those tags won't change, so update the pattern now
    DIR_ARTIST=$(echo "${TAG_ARTIST}" | ${VALIDATE})
    if [ -n "${TAG_CD_NUM}" ]; then
        DIR_ALBUM=$(echo "${TAG_ALBUM} - ${TAG_CD_NUM}" | ${VALIDATE})
    else
        DIR_ALBUM=$(echo "${TAG_ALBUM}" | ${VALIDATE})
    fi
    PATTERN=$(update_pattern "${OUTPATTERN}" "artist" "${DIR_ARTIST}")
    PATTERN=$(update_pattern "${PATTERN}" "album" "${DIR_ALBUM}")
    PATTERN=$(update_pattern "${PATTERN}" "genre" "${TAG_GENRE}")
    PATTERN=$(update_pattern "${PATTERN}" "year" "${TAG_DATE}")
    PATTERN=$(update_pattern "${PATTERN}" "ext" "${FORMAT}")

    metaflac --export-picture-to=cover.jpg "$1"
    convert -resize 60x60 "cover.jpg" "$OUT/$PATTERN/cover_small.jpg"
    convert -resize 120x120 "cover.jpg" "$OUT/$PATTERN/cover_med.jpg"

    # Cleaning
    rm -rfv cover.jpg
    rm $CUE
}

#############################################################################################################################

files=("${(@f)$(ls -1 **/*.flac)}")
for f in $files
do
    echo "===== $f ====="

    # First some rename just to be sure
    perlrename 's/.flac.cue/.cue/g' $f.cue

    split2flac "$f" -o $OUT

    export_cover $f
done

rm -rf cover.jpg
rm -rf ~/.split2flac_*

python3 ~/shared/Dropbox/music/generate_change_log.py $OUT
