#!/usr/bin/perl -w

@ARGV >= 1 or die;

$course = $ARGV[0];
($course =~ /^[A-Z]{4}[0-9]{4}$/) or die " $course is not valid";
#print "course is $course"
#$subject = ($course =~ /^([A-Z]{4})/);  # Brackets inside captures regex

@urls = ();
$url = "http://www.handbook.unsw.edu.au/postgraduate/courses/2018/$course.html";
push @urls, $url;
$url = "http://www.handbook.unsw.edu.au/undergraduate/courses/2018/$course.html";
push @urls, $url;
%prereqs = ();
foreach $link (@urls) {
    open F, "-|", "wget -q -O- $link" or die; # get html: -q turns off wget output -O- output to stdout. Pipe stdout into the file handle
    while ($line = <F>) {
        chomp $line;
        if ($line =~ /Prerequisite/) {
            if (!($line =~ /Excluded/)) {
                $line =~ /<p>(.+)CSS/;
                @matches = $1 =~ m/[A-Z]{4}[0-9]{4}/g;
            } else {
                $line =~ /<p>(.+)Excluded/;
                @matches = $1 =~ m/[A-Z]{4}[0-9]{4}/g;
            }
            last;
        }
    }
    foreach $prereq (@matches) {
        if (!exists $prereqs{$prereq}) {
            $prereqs{$prereq} = 1;
        }
    }

}
foreach $prereq (sort keys %prereqs) {
    print "$prereq\n";
}
