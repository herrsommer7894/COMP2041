#!/bin/bash

# Prints the names of the files in the cwd, splitting them into 3 categories
# Small (< 10 lines), Medium (< 100) and Large (else)
# Files listed in alphabetical ordering
_small=''
_med=''
_large=''
files=`ls -1 | sort`
for filename in $files; do
    #echo $filename
    size=`wc -l $filename | cut -d' ' -f1`
    if [ $size -lt 10 ]
    then 
        _small+="$filename "
    elif [ $size -lt 100 ]
    then
        _med+="$filename "
    else
        _large+="$filename "
    fi
done

# cut the trailing whitespace
small="$(echo -e "${_small}" | sed -e 's/[[:space:]]*$//')"
echo Small files: $small
med="$(echo -e "${_med}" | sed -e 's/[[:space:]]*$//')"
echo Medium-sized files: $med   
large="$(echo -e "${_large}" | sed -e 's/[[:space:]]*$//')"
echo Large files: $large
