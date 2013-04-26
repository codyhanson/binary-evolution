#! /usr/bin/perl
use Bit::Vector;
print "number of bits, decimal literal\n>";

while(<>) { 
	/(\d+)\s*,(-?\d+)/; 
	$len = $1;
	$dec = $2;
	print "length = $len, val = $dec\n";
	$v = Bit::Vector->new_Dec($1,$2);
	if ($v->to_Dec() != $2) {
		print "Could not fit $2 into $1 bit vector:". $v->to_Dec() . " $2 \n>" ;
	} else {
		print "fit ok:". $v->to_Dec() . " $2 \n>";
	}
}
