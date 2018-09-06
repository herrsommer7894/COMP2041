#!/usr/bin/perl -w

open F, "<", $ARGV[0] ;

$sum = 0;
while ($line = <F>) {
    if ($line =~ /\s(\d+)\sOrca/) {
    #print "$1\n";
        $sum += $1;
    }
}
print "$sum Orcas reported in $ARGV[0]\n";
