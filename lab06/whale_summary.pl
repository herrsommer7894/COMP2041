#!/usr/bin/perl  -w

open F, "<", $ARGV[0] ;

$num = 0;
%whale_pods = (); 
%whale_nums = ();
while ($line = <F>) {
    if ($line =~ /\s(\d+)\s(.+)/) {
        #print "$1 $2\n"; # $1 is count, $2 is whale type
        $whale = lc $2; # Lower case whale
        $num = $1;
        $whale =~ s/[ ]+/ /g; # all instances of multiple spaces truncated to one
        $whale =~ s/^[ ]+|[ ]+$//g; # Remove all trailing and leading spaces
        $whale =~ s/s$//; # Remove any plurals
        $whale_nums{$whale} += $num;
        $whale_pods{$whale} += 1;
    }
}
foreach $key (sort keys %whale_nums) {
    print "$key observations: $whale_pods{$key} pods, $whale_nums{$key} individuals\n";

}
