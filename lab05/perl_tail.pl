#!/usr/bin/perl 

$n = 10;
foreach $arg (@ARGV) {
   if ( $arg eq "--version") {
      print "$0: version 0.1\n";
      exit 0;
      # handle other options
      # ...
   } elsif ($arg =~ /^-\d+$/) {
      $arg =~ s/-//g;
      $n = $arg;
   } else {
      push @files, $arg ;
   }
}

foreach $file (@files) {
   my $i = 0;
   open F, "<$file"  or die "$0: Can't open $file"; #: $!\n";
   if ($#files > 0) {
      print "==> $file <==\n";
   }
   my @file = <F>;
   undef(@tail);
   for ($i = 0; $i < $n && ($i <= $#file); $i++) {
      unshift @tail, pop @file;
   }
   foreach $line (@tail) {
      print "$line";
   }
   close F;
}
