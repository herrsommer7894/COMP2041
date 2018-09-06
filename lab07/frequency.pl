#!/usr/bin/perl -w

foreach $file (glob "lyrics/*.txt") {
    $file =~ m/\/(.+)\.txt/g;
    $artist = $1;
    $artist =~ s/[^a-zA-Z]/ /g; # turn all non alphabet chars into spaces
    my $count=0;
    my $word_count=0;
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
    my $frequency = $word_count/ $count,;
    $return = sprintf( "%4d/%6d = %.9f %s\n", $word_count, $count, $frequency, $artist);
    print $return;
}
