#!/usr/bin/perl -w

if ($ARGV[0] eq "save") {
    # Save copies of all files in current directory
    save();
} elsif ($ARGV[0] eq "load") {
    save();
    load($ARGV[1]);
}


sub save {
    $n = 0;
    $backup_dir=".snapshot.$n";
    while (-e $backup_dir) {
        $n++;
        $backup_dir=".snapshot.$n";
    }
    print "Creating snapshot $n\n";
    mkdir $backup_dir;
    foreach $file (glob "*") {
        #print "file is $file\n";
        if (substr($file, 0, 1) eq '.' or $file eq "snapshot.pl") {continue};
        open F, "<", $file or die;
        while ($line = <F>) {
            push @arr, $line;
        }
        close F;
        $backup = "$backup_dir/$file";
        open F, ">", $backup or die;
        while (scalar @arr > 0) {
            $line = shift @arr;
            print F "$line";
        }
        close F;
    }
}

sub load {
    my $n = shift @_;
    my $backup_dir = ".snapshot.$n";
    print "Restoring snapshot $n\n";
    foreach $file (glob "$backup_dir/*") {
        $file=~/\/(.+)$/;
        my $filename = $1;
        open F, "<", $file or die;
        while (my $line = <F>) {
            push @arr, $line;
        }
        close F;
        open F, ">", $filename or die;
        while (scalar @arr > 0) {
            $line = shift @arr;
            print F "$line";
        }
        close F;
    }
}
