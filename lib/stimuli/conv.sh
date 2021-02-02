#!/bin/bash

for f in *.svg; do
    inkscape --export-png="$f.png" --export-dpi=600 $f
done
