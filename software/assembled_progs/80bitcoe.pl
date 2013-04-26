#! /usr/bin/perl
@lines = <>;
print shift @lines;
print shift @lines;
chomp @lines;
while (@lines) {
	for($i = 0; $i < 10; $i++) { 
 		$slice[$i] = shift(@lines);
	}
	print reverse @slice;
	print "\n"; 
}
