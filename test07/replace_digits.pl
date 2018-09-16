#!/usr/bin/perl -w
# Replace all digits with #
# single argument as filename

scalar @ARGV == 1 or die;
open F, "<", $ARGV[0];

while ($line = <F>) {
    while ($line =~ s/[0-9]/#/){ } # notive there's no g, but a while loop instead.
    #print "$line";
    push @arr, $line;
}
close F;

open F, '>', $ARGV[0] or die;
foreach $line (@arr) {
    print F "$line";
}
close F;
