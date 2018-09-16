#!/usr/bin/perl -w

scalar @ARGV > 0 or die;

open F, "<", $ARGV[0] or die;
# store the contents of file 1
while ($line = <F>) {
    push @arr, $line;
}
close F;

$i = 1;
while ($i <= $#ARGV) {
    @arr_cpy = @arr;
    undef @arr; @arr = ();
    open F, "<", $ARGV[$i] or die;
    # Compare with stored arr using shift
    while ($line = <F>) {
        push @arr, $line;
        $cmp = shift @arr_cpy;
        if (!defined $cmp or "$cmp" ne "$line") {
            print "$ARGV[$i] is not identical\n";
            close F;
            exit;
        }   
    }
    close F;
    $i++;
}

# check if arr_cpy is empty to determine whether it was successful
if (scalar @arr_cpy == 0) {

    print "All files are identical\n";
} else {
    print "$ARGV[--$i] is not identical\n";
    exit;
}









