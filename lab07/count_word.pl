#!/usr/bin/perl -w

$word_uc = uc $ARGV[0];  # This wont work.. This will only check for death & DEATH, not DeAth
$word_lc = lc $word_uc;

$count=0;
while ($line = <STDIN>) {
    $line = uc $line; # FIX: upper case the line before any further processing
    while ($line =~ m/([a-zA-Z]+)/g) {
        if ($1 eq $word_uc || $1 eq $word_lc) { 
            #print "$1\n";
            $count++;
        }
    }
}
print "$ARGV[0] occurred $count times\n"
