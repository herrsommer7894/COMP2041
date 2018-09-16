#!/bin/bash 

n=0
backup=".$1.$n"
while [ -f $backup ]
do
    ((n++))
    backup=".$1.$n"
done
cp $1 $backup

echo "Backup of '$1' saved as '$backup'"

