#!/usr/bin/perl -w
# For every file, 
# for every word in that file,
# for every artist,
# calculate the log probability of that artist using that word. (previous exercise)

foreach $file (@ARGV) { # For every file...
    %artist_word_stats = ();
    open F, "<", $file or die;
    while ($line = <F>) {
        while ($line =~ m/([a-zA-Z]+)/g) { ; # For every word...
            $word = $1;
            #print "$word\n";
            foreach $artist_file (glob "lyrics/*.txt") { # For every artist
                $artist_file =~ m/\/(.+)\.txt/g;
                $artist = $1;  
                $artist =~ s/[^a-zA-Z]/ /g; # Turn all non alphabet chars into spaces
                my $count=0;
                my $word_count=1; # Additive smoothing
                open F1, "<", $artist_file or die;
                while (my $artist_line = <F1>) {
                    $artist_line = uc $artist_line; 
                    while ($artist_line =~ m/([a-zA-Z]+)/g) {
                        $count++;
                        if ($1 eq uc $word) {
                            $word_count++;
                        }
                    }
                }
                close F1;
                $frequency = log($word_count/ $count);
                $artist_word_stats{$artist}{$word}+=$frequency;
            }
           
        }
    }
    # Calculate who has the highest log probability
    $max = -999999; 
    foreach $artist (sort keys %artist_word_stats) {
        $sum = 0;
        foreach $word (keys %{$artist_word_stats{$artist}}) {
            $sum += $artist_word_stats{$artist}{$word};
        }
        #    print "log probability of $sum for $artist\n";
        if ($sum > $max) {
            $max = $sum;
            $max_artist = $artist;
        }
    }
    $return = sprintf("$file most resembles the work of $max_artist (log-probability=%.1f)\n", $max);
    print "$return";
    close F;
}


