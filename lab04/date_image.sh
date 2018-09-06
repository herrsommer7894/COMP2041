#!/bin/bash

for file in "$@"
do
    if [[ "$file" =~ \.*jpg$ ]] || [[ "$file" =~ \.*png ]]
    then
        date=`ls -l $file | cut -d' ' -f6-8`
        echo $date
        convert -gravity south -pointsize 36 -draw "text 0,10 '$date'" $file $file
    else 
        echo "$file" cannot be viewed
    fi
done



