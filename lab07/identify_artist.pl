#!/usr/bin/perl -w
# For every file, 
# for every word in that file,
# for every artist,
# calculate the log probability of that artist using that word. (previous exercise)

%artist_wc = (); # Stores the wprd count for each word for every artist
%artist_tc = ();
foreach $artist_file (glob "lyrics/*.txt") { # For every artist
    $artist_file =~ m/\/(.+)\.txt/g;
    $artist = $1;  
    $artist =~ s/[^a-zA-Z]/ /g; # Turn all non alphabet chars into spaces
    push @artists, $artist;
    my $count=0;
    my $word_count=1; # Additive smoothing
    open F1, "<", $artist_file or die;
    while (my $artist_line = <F1>) {
        $artist_line = lc $artist_line; 
        while ($artist_line =~ m/([a-zA-Z]+)/g) {
            $count++;
            if (not exists $artist_wc{$artist}{$1}) {
                $artist_wc{$artist}{$1} = 2;
            } else {
               $artist_wc{$artist}{$1}++;  
           }
        }
    }
    close F1;
    $artist_tc{$artist} = $count;
    #$frequency = log($word_count/ $count);
    #$global_artist_word_stats{$artist}{$word} = $frequency;
}

foreach $file (@ARGV) { # For every file...
    %artist_word_freq = ();
    open F, "<", $file or die;
    while ($line = <F>) {
        $line = lc $line;
        while ($line =~ m/([a-zA-Z]+)/g) {  # For every word...
            $word = $1;
            #print "$word\n";
            foreach $artist (@artists) {
                if (exists $artist_wc{$artist}{$word}) {
                    $artist_word_freq{$artist}{$word} += log ($artist_wc{$artist}{$word}/$artist_tc{$artist});
                } else {
                    $artist_word_freq{$artist}{$word} += log (1/$artist_tc{$artist});

                }
            }
        }
    }
    close F;
    # Calculate who has the highest log probability
    $max = -999999; 
    foreach $artist (sort keys %artist_word_freq) {
        $sum = 0;
        foreach $word (keys %{$artist_word_freq{$artist}}) {
            $sum += $artist_word_freq{$artist}{$word};
        }
        #print "log probability of $sum for $artist\n";
        if ($sum > $max) {
            $max = $sum;
            $max_artist = $artist;
        }
    }
    $return = sprintf("$file most resembles the work of $max_artist (log-probability=%.1f)\n", $max);
    print "$return";
}


