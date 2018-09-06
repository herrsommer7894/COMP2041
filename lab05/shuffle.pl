
@file = <>;

$i = 0;
%hash = ();
while (scalar keys %hash < $#file) {
   $index = rand($#file);
   $index = int($index);
   if ($hash{$index} == 0) {
      $hash{$index}++;
      print "@file[$index]";
   }
}
