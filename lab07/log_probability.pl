#!/usr/bin/perl -w


foreach $file (glob "lyrics/*.txt") {
    $file =~ m/\/(.+)\.txt/g;
    $artist = $1;
    $artist =~ s/[^a-zA-Z]/ /g; # turn all non alphabet chars into spaces
    my $count=0;
    my $word_count=1; #Additive smoothing
    open F, "<", $file or die;
    while (my $line = <F>) {
        $line = uc $line; 
        while ($line =~ m/([a-zA-Z]+)/g) {
            $count++;
            if ($1 eq uc $ARGV[0]) {
                $word_count++;
            }
        }
    }
    $artist_wc{$artist}{$ARGV[0]}=$word_count;
    $artist_c{$artist}{$ARGV[0]}=$count;
}
foreach $artist (sort keys %artist_wc) {
    $word_count = $artist_wc{$artist}{$ARGV[0]};
    $count = $artist_c{$artist}{$ARGV[0]};
    $frequency = log($word_count/ $count);
    $return = sprintf( "log((%d+1)/%6d) = %8.4f %s\n", --$word_count, $count, $frequency, $artist);
    print $return;
}
