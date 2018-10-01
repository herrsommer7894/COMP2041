#!/usr/bin/perl -w

if (scalar @ARGV == 0) 
{
    print_usage();
} 
elsif ($ARGV[0] eq "init") 
{
    # Create an empty Legit repo. Error if already exists
    mkdir ".legit" or print STDERR "legit.pl: error: .legit already exists\n" and exit 1;
    print "Initialized empty legit repository in .legit\n";

} 
elsif ($ARGV[0] eq "add") 
{
    if (not -d ".legit") 
    {
    
        print STDERR "legit.pl: error: no .legit directory containing legit repository exists\n" and exit 1;
    
    } 
    else 
    {
        $#ARGV > 0 or print STDERR "usage: legit.pl add <filenames>\n" and exit 1;
        # create index if it doesn't already exist
        -d ".legit/index" or mkdir ".legit/index";
        # Check if they are "ordinary files" that also exist.
        foreach my $i (1..$#ARGV) 
        {
            $ARGV[$i] =~ m/\-\-\-/g and print STDERR "usage: legit.pl add <filenames>\n" and exit 1;
            $ARGV[$i] =~ m/^[a-zA-Z0-9][a-zA-z0-9\.\-\_]*$/g or print STDERR "legit.pl: error: invalid filename '$ARGV[$i]'\n" and exit 1;
            if (not -e $ARGV[$i]) 
            {
                print "legit.pl: error: can not open '$ARGV[$i]'\n" and exit 1;
            }
        }
        foreach my $i (1..$#ARGV) 
        {
            open F, "<", $ARGV[$i] or die;
            @arr = <F>;
            close F;
            open F, ">", ".legit/index/$ARGV[$i]" or die;
            while (scalar @arr > 0) 
            {
                $line = shift @arr;
                print F "$line";
            }
            close F;
        }
    }

} 
elsif ($ARGV[0] eq "commit") 
{
    # Save copy of all files in index to the repo
    ($#ARGV > 1) or print STDERR "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
    $m = 1;
    while ($ARGV[$m] ne "-m") 
    {
        $m++; 
    }
    # check if message exists. Assume that the message is ascii and doesn't start with a '-'
    $#ARGV > $m and substr($ARGV[$m+1], 0, 1) ne "-" or print STDERR "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
    $i = 1;
    $update_index = 0;
    while ($i <= $#ARGV) 
    {
        $ARGV[$i] eq "-a" and $update_index = 1 and last;
        $i++;    
    }
    if ($update_index) 
    {
        foreach $index_file (glob ".legit/index/*") 
        {
            $index_file =~ m/^\.legit\/index\/(.+)$/g;
            $file = $1;
            open F, "<", $file or die;
            @arr = <F>;
            close F;
            open F, ">", "$index_file" or die;
            while (scalar @arr > 0) 
            {
                $line = shift @arr;
                print F "$line";
            }
            close F;
        }
    }
    $commit = 1; # Assume we do need to commit
    $commit_no = next_commit_num();
    $commit_message = $ARGV[$m+1];
    #print "Commit $commit_no message is $commit_message\n";
    # Save a copy of all files in the index to the repo or print "nothing to commit" if index hasn't changed compared to prev commit
    if ($commit_no > 0) 
    {
        $commit = 0;
        $prev_commit_no = $commit_no-1;
        foreach $index_file (glob ".legit/index/*") 
        {
            $index_file =~ m/^\.legit\/index\/(.+)$/g;
            $file = $1;
            # TODO account for remove here
            if (not -e ".legit/commit.$prev_commit_no/$file") 
            {
                $commit = 1;
            } 
            elsif (compare_files("$index_file", ".legit/commit.$prev_commit_no/$file")) 
            {
                $commit = 1;
                last;
            }
        }
        open $log, ">>", ".legit/log.txt" or die;
    } 
    else 
    {
        open $log, ">", ".legit/log.txt" or die;
    }
    if ( $commit ) 
    {
        $commit_dir = ".legit/commit.$commit_no";
        #printf("its time to COMMIT\n");
        mkdir "$commit_dir" or die;
        foreach $index_file (glob ".legit/index/*") 
        {
            $index_file =~ m/^\.legit\/index\/(.+)$/g;
            $file = $1;
            open F, "<", "$index_file" or die;
            while ( $line = <F> ) 
            {
                push @arr, $line;
            }
            close F;
            open F, ">", ".legit/commit.$commit_no/$file" or die;
            while ( scalar @arr > 0 ) 
            {
                $line = shift @arr;
                print F "$line";
            }
            close F;
            $commit=0;
        }
        print $log "$commit_no $commit_message\n";
        print "Commited as commit $commit_no\n";
    } else 
    {
        print STDERR "Nothing to commit\n";
    }
    close $log;

} elsif ($ARGV[0] eq "log") 
{
    -d ".legit/commit.0" or print STDERR "legit.pl: error: your repository does not have any commits yet\n";
    # use log.txt in .legit
    open F, "<", ".legit/log.txt" or die;
    @lines = reverse <F>;
    foreach $line (@lines) 
    {
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
        $path = ".legit/commit.$commit";
        $filename = $2;
    } 
    elsif ( $ARGV[1] =~ m/:(.+)$/g ) 
    {
        $path = ".legit/index";
        $filename = $1;
    } 
    else 
    {
        print STDERR "legit.pl: error: invalid filename''" and exit 1;
    }
    # Check if path exists
    -d $path or print STDERR "legit.pl: error: unknown commit '$commit'\n" and exit 1;
    $path = "$path/$filename";
    # Check if the file actually exists
    -e $path or print STDERR "legit.pl: error: '$filename' not found in commit $commit\n" and exit 1;
    # Print the file to stdout
    open F, "<", "$path" or die;
    while ( $line = <F> ) 
    {
        print "$line";
    }
} 
elsif ($ARGV[0] eq "rm") 
{ 
    ($#ARGV > 0) or print STDERR "usage: legit.pl rm [--force] [--cached] filenames\n" and exit 1;
    $i = 1;
    $is_forced = 0;
    $is_cached = 0;
    while ($i <= $#ARGV) 
    {
        $ARGV[$i] eq "--force" and $is_forced = 1;
        $ARGV[$i] eq "--cached" and $is_cached = 1;
        $i++;
    }
    # first check if all named files are in the repo (latest commit)
    $curr_commit = next_commit_num() - 1;
    $curr_commit >= 0 or print STDERR "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
    $commit_dir = ".legit/commit.$curr_commit";
    $i = 1;
    while ($i <= $#ARGV) {
        if (substr($ARGV[$i], 0, 1) ne "-")
        {
            -e "$commit_dir/$ARGV[$i]" or print STDERR "legit.pl: error: '$ARGV[$i]' is not in the legit repository\n" and exit 1;
            push @files, $ARGV[$i];
        }
        $i++;
    }
    if (not $is_forced) 
    {
        foreach $file (@files) 
        {
            # Check if file in CWD to be deleted is different to file in latest commit
            if (not $is_cached) 
            {
                if (-e $file) 
                {
                    compare_files($file, ".legit/index/$file") and print STDERR "legit.pl: error: '$file' in repository is different to working file\n" and exit 1;
                    #$test2 = compare_files(".legit/index/$file", $file);
                    $test2 = 0;
                } 
                else 
                { 
                    $test2 = 1;
                }
            }
            # Check if file in index is different to file in latest commit
            $test1 = compare_files(".legit/index/$file", "$commit_dir/$file");
            if ($test1 and $test2) 
            {
                print STDERR "legit.pl: error: '$file' in index is different to both working file and repository\n" and exit 1; 
            } 
            elsif ($test1) 
            {
                print STDERR "legit.pl: error: '$file' has changed staged in the index\n" and exit 1;
            }
        }
    }
    # now we actually remove the files
    foreach $file (@files) 
    {
        if (not $is_cached) 
        {
            -e "$file" and unlink "$file";
        }
        -e ".legit/index/$file" and unlink ".legit/index/$file";
    }



} 
elsif ($ARGV[0] eq "status") 
{
    # "file changed, Staged for commit" if in index and CWD is different to latest commit
    # "file changed, different changed staged for commit" if index, CWD and latest commit different
    # "file changes, changed not staged for commit if CWD diff to index and commit, index and commit same
    # "Added to index" if CWD == Index and doesnt exist in latest commit
    # "untracked' if exists in neither index nor commit
    # "same as repo" if everythings the same
    # "file deleted" if only deleted from CWD
    # "deleted" if deleted from index and CWD
    $curr_commit = next_commit_num() - 1;
    $curr_commit >= 0 or print STDERR "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
    $commit_dir = ".legit/commit.$curr_commit";
    $index_dir = ".legit/index";
    # Collate all unique files from index, CWD and repo
    foreach $file (glob "*") 
    {
        $files{$file} = 1;
    }
    foreach $file (glob "$commit_dir/*") 
    {
        $file =~ m/^\.legit\/commit.$curr_commit\/(.+)$/g;
        $file = $1;
        $file =~ s/\///g;
        if (not exists $files{$file}) 
        {
            $files{$file} = 1;
        }
    }  
    foreach $file (glob "$index_dir/*") 
    {
        $file =~ m/^\.legit\/index\/(.+)$/g;
        $file = $1;
        $file =~ s/\///g;
        if (not exists $files{$file}) 
        {
            $files{$file} = 1;
        }
    }
    foreach $file ( sort keys %files ) 
    {
        # deleted
        if ( not -e "$index_dir/$file" and 
             not -e "$file" )  
        {
            print "$file - deleted\n";

        } 
        # file deleted
        elsif ( not -e "$file" ) 
        {
            print "$file - file deleted\n";

        } 
        # untracked
        elsif ( not -e "$index_dir/$file" and not -e "$commit_dir/$file" )
        {
            print "$file - untracked\n";
        
        } 
        # same as repo
        elsif (compare_files("$index_dir/$file", "$file") == 0 and 
                 compare_files("$file", "commit_dir/$file") == 0) 
        {
            print "$file - same as repo\n";

        } 
        # added to index
        elsif ( not -e "$commit_dir/$file" and compare_files($file, "$index_dir/$file") == 0 ) 
        {
            print "$file - added to index\n";
        
        } 
        # changes not staged for commit
        elsif ( compare_files("$index_dir/$file","$commit_dir/$file") == 0 and 
                 compare_files("$index_dir/$file","$file") ) 
        {
            print "$file - file changed, changes not staged for commit\n";
        
        } 
        # changed staged for commit 
        elsif ( compare_files("$index_dir/$file","$file") == 0 and 
                 compare_files("$index_dir/$file","$commit_dir/$file") ) 
        {
            print "$file - file changed, changes staged for commit\n";
        
        } 
        # different changes staged for commit
        elsif ( compare_files("$index_dir/$file","$commit_dir/$file") and 
                 compare_files("$file","$commit_dir/$file") and
                 compare_files("$index_dir/$file","$file") ) 
        {
            print "$file - file changed, different changes staged for commit\n";
        }
    }

} 
else 
{
    print STDERR "legit.pl: error: unknown command $ARGV[0]\n";
    print_usage() and exit 1;
}


sub print_usage 
{
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

# 0 if same, 1 if diff
sub compare_files 
{
    my ( $file1, $file2 ) = @_;

    open my $F1, "<", $file1 or return 1;    
    my @arr1 = <$F1>;
    close $F1;
    open my $F2, "<", $file2 or return 1;
    my @arr2 = <$F2>;
    close $F2;
    
    scalar @arr1 == scalar @arr2 or return 1;

    foreach my $elem1 (@arr1) 
    {
        if (scalar @arr2 > 0) 
        {
            $elem2 = shift @arr2;
            $elem1 eq $elem2 and next;
            return 1;
        } 
        else 
        {
            return 1;
        }
    }

    return 0;
}

sub next_commit_num 
{
    my $commit_no = 0;
    my $commit_dir = ".legit/commit.$commit_no";
    if (-e $commit_dir) 
    {
        $commit_no++;
        $commit_dir = ".legit/commit.$commit_no";
    }
    return $commit_no;
}
