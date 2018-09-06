#!/bin/bash

# Given 2 args n ands str, print the string n times

if [ $# -ne 2 ]
then
    echo Usage: $0 \<number of lines\> \<string\>
    exit
fi

n=$1
str=$2
counter=1
regex='^[0-9]+$'
if ! [[ $n =~ $regex ]]
then
    echo  $0: argument 1 must be a non-negative integer
    exit
elif [ $n -lt 0 ]  # the spaces are important
then 
    echo $0: argument 1 must be a non-negative integer
    exit

else
    while [ $counter -le $n ]
    do
        echo $str
        ((counter++))
    done
fi
