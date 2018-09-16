#!/usr/bin/perl -w

$n = 0;
$backup=".$ARGV[0].$n";
while (-e $backup) {
    $n++;
    $backup=".$ARGV[0].$n";
}
open F, "<", $ARGV[0] or die;
while ($line = <F>) {
    push @arr, $line;
}
close F;
open F, ">", $backup or die;
while (scalar @arr > 0) {
    $line = shift @arr;
    print F "$line";
}
close F;
print "Backup of '$ARGV[0]' saved as '$backup'\n";
