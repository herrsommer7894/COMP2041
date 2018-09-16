#!/usr/bin/perl -W
 

while ($line = <>) {
    push @lines, $line;
}
foreach $line (@lines) {
    @arr=();
    while ($line =~ /(?:\b|\s)([^\s]+)(?:\b|\s)/g) {
        chomp $1;
        $word = $1;
        $word eq " " or push @arr, $word;
    }
    @sorted_words = sort @arr;

    foreach $word (@sorted_words) {
        print "$word ";
    }
    print"\n";
    undef @arr;
}
