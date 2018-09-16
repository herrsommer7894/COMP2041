#!/usr/bin/perl -w

$n = $ARGV[0];
open F, '<', $ARGV[1];

$count = 1;
while ($line = <F>) {
    if ($count == $n) {
        print $line;
        close F;
        exit;
    }
    $count++;
}
close F;
