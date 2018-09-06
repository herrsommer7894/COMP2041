#!/bin/bash

for dir in "$@"
do
    if [ -d "$dir" ]
    then
        for file in "$dir"/*
        do
            test ! -f "$file" && continue
            #echo "$file:"
            album=`echo "$file" | cut -d'/' -f2 | cut -d'/' -f3`
            track=`echo "$file" | cut -d'/' -f3- | cut -d' ' -f1 | sed 's/[ ]*$//'| sed 's/^\///' `
            title=`echo "$file" | cut -d'-' -f2- | sed 's/[ ][-].*$//'`
            title=`echo "$title" | sed 's/^[ ]*//' | sed 's/[ ]*$//'`
            artist=`echo "$file" | cut -d'-' -f2- | sed 's/^.*[ ][-][ ]//' | sed 's/[.][m][p][3]$//'`
            year=`echo "$file" | cut -d',' -f2 | cut -d'/' -f1 | sed 's/^[ ]*//'`
            id3 -A "$album" -a "$artist" -T "$track" -t "$title" -y "$year" "$file" > /dev/null

        done
    else
        echo "not a directory"
    fi
done
