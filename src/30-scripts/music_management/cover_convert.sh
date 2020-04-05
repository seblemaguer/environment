#!/bin/sh

convert cover.jpg -resize 60x60 -density 72 -quality 75 cover_small.jpg
convert cover.jpg -resize 120x120 -density 72 -quality 75 cover_med.jpg
