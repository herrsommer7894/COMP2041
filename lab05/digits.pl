#!/usr/bin/perl -w

foreach $line (<STDIN>) {
    $line =~ tr/[01234]/</;
    $line =~ tr/[6789]/>/;
    print "$line";
}
