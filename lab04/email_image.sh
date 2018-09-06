#!/bin/bash

for file in "$@"
do
    if [[ "$file" =~ \.*jpg$ ]] || [[ "$file" =~ \.*png ]]
    then
        display "$file"
        echo -n "Address to email this image to? "
        read email
        if [[ "$email" =~ \.*@\.* ]]
        then
            echo -n "Message to accompany image? "
            read message
            echo "$message" | mutt -e 'set copy=no' -a "$file" -- "$email"
        fi
    else 
        echo "$file" cannot be viewed
    fi
done



