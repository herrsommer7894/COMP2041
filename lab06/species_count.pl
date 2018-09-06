#!/usr/bin/perl -w

open F, "<", $ARGV[1] ;

$sum = 0; 
$pod = 0;
while ($line = <F>) {
    if ($line =~ /\s(\d+)\s$ARGV[0]/) {
    #print "$1\n";
        $sum += $1;
        $pod += 1;
    }
}
print "$ARGV[0] observations: $pod pods, $sum individuals\n";
