#!/bin/bash

first_num=$1
end_num=$2
file=$3

truncate -s 0 $file

for i in $(seq $1 $2) 
do
    echo "$i" >> $file
done
