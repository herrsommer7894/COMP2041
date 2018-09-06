#!/usr/bin/perl -w 
if ($#ARGV != 1) {
    print STDERR "Usage: ./echon.pl <number of lines> <string>\n";
    exit;
}
if ($ARGV[0] !~ /^\d+$/ ) {
    print STDERR "./echon.pl: argument 1 must be a non-negative integer\n";
    exit;
}

for (my $i=0; $i < $ARGV[0]; $i++) {
    print "$ARGV[1]\n";

}
