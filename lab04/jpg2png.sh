#!/bin/bash

for filename in *
do
    test -d "$filename" && continue
    if [[ $filename =~ \.jpg$ ]] 
    then
        # convert to png, but first check if filename.png already exists.
        new_name=`echo "$filename" |sed -e 's/.jpg/.png/g'`
        if [ ! -e "$new_name" ]
        then
            convert "$filename" "$new_name"
        else 
            echo "$new_name" already exists
        fi
    fi
done
