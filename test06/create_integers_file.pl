#!/usr/bin/perl -w


open F, '>', $ARGV[2] or die;

$start=$ARGV[0];
$end=$ARGV[1];

for ($i=$start; $i <= $end; $i++) {
    print F "$i\n"; 
}
