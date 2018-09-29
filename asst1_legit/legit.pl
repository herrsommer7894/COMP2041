#!/usr/bin/perl -w



if (scalar @ARGV == 0) 
{
    print_usage();
} elsif ($ARGV[0] eq "init") 
{
    # Create an empty Legit repo. Error if already exists
    mkdir ".legit" or print STDERR "legit.pl: error: .legit already exists\n" and exit 1;
    print "Initialized empty legit repository in .legit\n";

} elsif ($ARGV[0] eq "add") 
{
    if (not -d ".legit") 
    {
    
        print "legit.pl: error: no .legit directory containing legit repository exists\n";
    
    } else 
    {
        $#ARGV > 0 or print STDERR "usage: legit.pl add <filenames>\n" and exit 1;
        # create index if it doesn't already exist
        -d ".legit/index" or mkdir ".legit/index";
        # Check if they are "ordinary files" that also exist.
        foreach my $i (1..$#ARGV) {
            print "$ARGV[$i]\n\n";
            $ARGV[$i] =~ m/\-\-\-/g and print STDERR "usage: legit.pl add <filenames>\n" and exit 1;
            $ARGV[$i] =~ m/^[a-zA-Z0-9][a-zA-z0-9\.\-\_]*$/g or print STDERR "legit.pl: error: invalid filename '$ARGV[$i]'\n" and exit 1;
            if (not -e $ARGV[$i]) {
                print "legit.pl: error: can not open '$ARGV[$i]'\n" and exit 1;
            }
        }
        print "adding files now\n";
        foreach my $i (1..$#ARGV) {
            open F, "<", $ARGV[$i] or die;
            while ($line = <F>) {
                push @arr, $line;
            }
            close F;
            open F, ">", ".legit/index/$ARGV[$i]" or die;
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
    $i = 1;
    while ($ARGV[$i] ne "-m") {
        $i++; 
    }
    $commit = 1; # Assume we do need to commit
    $commit_no = 0;
    $commit_dir = ".legit/commit.$commit_no";
    if (-e $commit_dir) {
        $commit_no++;
        $commit_dir = ".legit/commit.$commit_no";
    }
    $commit_message = $ARGV[$i+1];
    print "Commit message is $commit_message\n";
    # Save a copy of all files in the index to the repo or print "nothing to commit" if index hasn't changed compared to prev commit
    if ($commit_no > 0) 
    {
        $commit = 0;
        $prev_commit_no = $commit_no-1;
        print "prev commit no $prev_commit_no\n";
        foreach $index_file (glob ".legit/index/*") {
            print "Checking";
            $index_file =~ m/^\.legit\/index\/(.+)$/g;
            $file = $1;
            printf "file is $file\n";
            if (not -e ".legit/commit.$prev_commit_no/$file") {
                $commit = 1;
            } elsif (compare_files("$index_file", ".legit/commit.$prev_commit_no/$file")) {
                print "Files are different\n";
                $commit = 1;
                last;
            }
        }
        open $log, ">>", ".legit/log.txt" or die;
    } else {
        print "Creating log.txt\n";
        open $log, ">", ".legit/log.txt" or die;
    }
    if ( $commit ) {
        printf("its time to COMMIT\n");
        mkdir "$commit_dir" or die;
        foreach $index_file (glob ".legit/index/*") {
            $index_file =~ m/^\.legit\/index\/(.+)$/g;
            $file = $1;
            open F, "<", "$index_file" or die;
            while ( $line = <F> ) {
                push @arr, $line;
            }
            close F;
            open F, ">", ".legit/commit.$commit_no/$file" or die;
            while ( scalar @arr > 0 ) {
                $line = shift @arr;
                print F "$line";
            }
            close F;
            $commit=0;
        }
        print $log "$commit_no $commit_message\n";
    } else {
        print STDERR "Nothing to commit\n";
    }
    close $log;

} elsif ($ARGV[0] eq "log") 
{
    -d ".legit/commit.0" or print STDERR "legit.pl: error: your repository does not have any commits yet\n";
    # use log.txt in .legit
    open F, "<", ".legit/log.txt" or die;
    @lines = reverse <F>;
    foreach $line (@lines) {
        print "$line";
    }

} elsif ($ARGV[0] eq "show") 
{
    # first check if any commits exist --> enough to check if .legit/commit.0 exists
    -d ".legit/commit.0" or print STDERR "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
    # print file contents from commit or index
    ($#ARGV > 0) or print STDERR "usage: legit.pl show <commit>:<filename>\n" and exit 1;
    if ( $ARGV[1] =~ m/^(\d+):(.+)$/g ) 
    {
        $commit = $1;
        print "Looking at commit $commit\n";
        $path = ".legit/commit.$commit";
        $filename = $2;
    } elsif ( $ARGV[1] =~ m/:(.+)$/g ) 
    {
        $path = ".legit/index";
        $filename = $1;
    } else {
        print STDERR "legit.pl: error: invalid filename''" and exit 1;
    }
    # Check if path exists
    -d $path or print STDERR "legit.pl: error: unknown commit '$commit'\n" and exit 1;
    $path = "$path/$filename";
    # Check if the file actually exists
    -e $path or print STDERR "legit.pl: error: '$filename' not found in commit $commit\n" and exit 1;
    # Print the file to stdout
    open F, "<", "$path" or die;
    while ( $line = <F> ) {
        print "$line";
    }

    

} else 
{
    print STDERR "legit.pl: error: unknown command $ARGV[0]\n";
    print_usage() and exit 1;
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

sub compare_files {
    my ( $file1, $file2 ) = @_;
    open my $F1, "<", $file1 or die;
    open my $F2, "<", $file2 or die;

    while ( my $line1 = <$F1> ) {
        if ( $line1 eq <$F2> ) {
            next;
        }
        return 1;
    }
    return 0;
}
