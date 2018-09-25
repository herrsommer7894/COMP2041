#!/usr/bin/perl -w

if (scalar @ARGV == 0) 
{
    print_usage();
} elsif ($ARGV[0] eq "init") 
{
    # Create an empty Legit repo. Error if already exists
    mkdir ".legit" or print STDERR "legit.pl: error: .legit already exists\n";
    print "Initialized empty legit repository in .legit\n";

} elsif ($ARGV[0] eq "add") 
{
    if (not -d ".legit") {
        print "legit.pl: error: no .legit directory containing legit repository exists\n";
    } else {
        foreach my $i (1..$#ARGV) {
            # Check if they are "ordinary files"
            print "$ARGV[$i]\n\n";
            $ARGV[$i] =~ m/^[a-zA-z0-9\.\-\_]+$/g or print STDERR "legit.pl: error: invalid filename '$ARGV[$i]'\n" and exit;
            if (not -e $ARGV[$i]) {
                print "legit.pl: error: can not open '$ARGV[$i]'\n" and exit;
            }
        }
        print "adding files now\n";
        # We dont add any files unless all files are 'ordinary'
        foreach my $i (1..$#ARGV) {
            open F, "<", $ARGV[$i] or die;
            while ($line = <F>) {
                push @arr, $line;
            }
            close F;
            open F, ">", ".legit/$ARGV[$i]" or die;
            while (scalar @arr > 0) {
                $line = shift @arr;
                print F "$line";
            }
            close F;
        
        }
    }

} elsif ($ARGV[0] eq "commit") 
{
    # Save copy of all files in index to the repo
    ($#ARGV > 1) or print STDERR "usage: legit.pl commit [-a] -m commit-message\n";


} elsif ($ARGV[0] eq "log") 
{
    # use log.txt in .legit

} elsif ($ARGV[0] eq "show") 
{


} else 
{
    print STDERR "legit.pl: error: unknown command $ARGV[0]\n";
    print_usage();
}


sub print_usage {
    print STDERR "Usage: legit.pl <command> [<args>]

    These are the legit commands:
    init       Create an empty legit repository
    add        Add file contents to the index
    commit     Record changes to the repository
    log        Show commit log
    show       Show file at particular state
    rm         Remove files from the current directory and from the index
    status     Show the status of files in the current directory, index, and repository
    branch     list, create or delete a branch
    checkout   Switch branches or restore current directory files
    merge      Join two development histories together\n\n";
}
