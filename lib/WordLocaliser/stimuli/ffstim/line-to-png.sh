#!/bin/bash
lines=$(cat $1)
savedir=$2
count=0
mkdir "$2"
for line in $lines; do
    (( count++ ))
    convert -size 350x100 xc:none -fill white -stroke white -font BACS2sans -gravity Center -pointsize 100 -annotate +0+0 "$line" $savedir/$count.png
done
