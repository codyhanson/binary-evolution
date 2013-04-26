#! /usr/bin/perl



#example: 0xCF @ addr Mem[5555]
#would get stored as [22220]
#aka mem_addr LSL by 2
#and then the bottom 2 bits get the following encoding:
#color = 0x00, encoded to 2_00
#color = 0xCF, encoded to 2_10
#color = 0xF0, encoded to 2_11
#this will make it easier for me to initialize the main menu
#and it'll take a lot less space (1500 words or so i think)
use Bit::Vector;

open ($OUT, '>', "main_menu_processed.hex") or die "couldnt open output file for write";

$address = Bit::Vector->new_Dec(40,0);
$x00 = Bit::Vector->new_Hex(8,"00");
$xCF = Bit::Vector->new_Hex(8,"CF");
$xF0 = Bit::Vector->new_Hex(8,"F0");

$x00_enc = Bit::Vector->new_Bin(8,"00000000");
$xCF_enc = Bit::Vector->new_Bin(8,"00000001");
$xF0_enc = Bit::Vector->new_Bin(8,"00000010"); 

while (<>) {
	@bytes = split(/\s+/,$_);	
	foreach $b (@bytes) {
		$bv = Bit::Vector->new_Hex(8,$b);	
		if ($x00->equal($bv)) {
			$enc = Bit::Vector->Concat_List(($address,$x00_enc)); #42 bits
			$enc->Resize(40); #trim top two bits	
			@encbytes = $enc->Chunk_List_Read(8);	
			#printf $OUT ("%02x %02x %02x %02x %02x  #address %s value %s\n",$encbytes[4],$encbytes[3],$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
			printf $OUT ("%02x %02x %02x \n//address %s value %s\n\n",$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
		} elsif($xCF->equal($bv)) {
			$enc = Bit::Vector->Concat_List(($address,$xCF_enc)); #42 bits
			$enc->Resize(40); #trim top two bits	
			@encbytes = $enc->Chunk_List_Read(8);	
			#printf $OUT ("%02x %02x %02x %02x %02x  #address %s value %s\n",$encbytes[4],$encbytes[3],$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
			printf $OUT ("%02x %02x %02x \n//address %s value %s\n\n",$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
		} elsif($xF0->equal($bv)) {
			$enc = Bit::Vector->Concat_List(($address,$xF0_enc)); #42 bits
			$enc->Resize(40); #trim top two bits	
			@encbytes = $enc->Chunk_List_Read(8);	
			#printf $OUT ("%02x %02x %02x %02x %02x  #address %s value %s\n",$encbytes[4],$encbytes[3],$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
			printf $OUT ("%02x %02x %02x \n//address %s value %s\n\n",$encbytes[2],$encbytes[1],$encbytes[0],$address->to_Dec(),$bv->to_Hex());
		} 
		#else, do nothing
		$address->increment();
	}
}
