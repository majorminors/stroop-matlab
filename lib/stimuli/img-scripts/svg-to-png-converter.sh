#!/bin/bash

# uses inkscape to convert all files with extension  `.svg` to `.png`

# first convert from *.svg to *.svg.png
echo "converting .svg files in current folder to .png files"
sleep 1s
for f in *.svg; do
    inkscape --export-png="$f.png" --export-dpi=800 $f
done

# now remove that annoying `.svg` from the filename
echo "now removing lingering .svg from filenames"
sleep 1s
for filename in *.png; do 
    [ -f "$filename" ] || continue
    mv "$filename" "${filename//.svg/}"
done

echo "done"
