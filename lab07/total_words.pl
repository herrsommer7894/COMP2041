#!/usr/bin/perl -w
# Count the total number of words found in STDIN
# A word is a maximal non-empty contiguous squence of alphabetical characters
# Could also split the line by regex defined by 'non-words', returning an array 

$count = 0;
while ($line = <>) {
    while ($line =~ m/[a-zA-Z]+/g) { $count++; }
}
print "$count words\n";

