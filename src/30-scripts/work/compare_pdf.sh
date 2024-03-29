#!/bin/bash
#
# Compare two PDF files.
# Dependencies:
#  - bc
#  - pdfinfo (xpdf)
#  - pdfjam  (texlive-extra-utils)
#  - diffpdf

if ! command -v bc &>/dev/null ||
        ! command -v pdfinfo &>/dev/null ||
        ! command -v pdfjam &>/dev/null ||
        ! command -v pdfinfo &>/dev/null
then
	echo "Dependencies (bc, pdfinfo (xpdf), pdfjam (texlive-extra-utils), diffpdf) need to be installed"
	exit -1
fi

MAX_HEIGHT=15840 #The maximum height of a page (in points), limited by pdfjam.

TMPFILE1=$(mktemp /tmp/XXXXXX.pdf)
TMPFILE2=$(mktemp /tmp/XXXXXX.pdf)

usage="usage: scrolldiff -h FILE1.pdf FILE2.pdf
  -h print this message

v0.0"

while getopts "h" OPTIONS; do
	case ${OPTIONS} in
	h | -help)
		echo "${usage}"
		exit
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$1" ] || [ -z "$2" ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
	echo "ERROR: input files do not exist."
	echo
	echo "$usage"
	exit
fi

#Get the number of pages:
pages1=$(pdfinfo "$1" | grep 'Pages' - | awk '{print $2}')
pages2=$(pdfinfo "$2" | grep 'Pages' - | awk '{print $2}')
numpages=$pages2
if [[ $pages1 > $pages2 ]]; then
	numpages=$pages1
fi

#Get the paper size:
width1=$(pdfinfo "$1" | grep 'Page size' | awk '{print $3}')
height1=$(pdfinfo "$1" | grep 'Page size' | awk '{print $5}')
width2=$(pdfinfo "$2" | grep 'Page size' | awk '{print $3}')
height2=$(pdfinfo "$2" | grep 'Page size' | awk '{print $5}')

if [ $(bc <<<"$width1 < $width2") -eq 1 ]; then
	width1=$width2
fi
if [ $(bc <<<"$height1 < $height2") -eq 1 ]; then
	height1=$height2
fi

height=$(echo "scale=2; $height1 * $numpages" | bc)
if [ $(bc <<<"$MAX_HEIGHT < $height") -eq 1 ]; then
	height=$MAX_HEIGHT
fi
papersize="${width1}pt,${height}pt"

#Make the scrolls:
pdfj="pdfjam --nup 1x$numpages --papersize {${papersize}} --outfile"
$pdfj "$TMPFILE1" "$1"
$pdfj "$TMPFILE2" "$2"

diffpdf "$TMPFILE1" "$TMPFILE2"

rm -f $TMPFILE1 $TMPFILE2
