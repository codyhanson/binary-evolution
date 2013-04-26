#! /usr/bin/perl
# ISA_TOOLS.pm supporting module for sim.pl and asm.pl for the Binary Evolution ECE 554 ISA
# Cody Hanson 3/8/2011
package ISA_TOOLS;
use ISA_REGEX;
use Exporter;
use strict;

#the @ISA array and the package name are merely coincidence.
our @ISA = qw(Exporter);
our @EXPORT = qw(%conditionals &readFiles &EQUreplace &FirstPass &computePseudoOps 
		%shiftcodes %csymtable %dsymtable %rf_address %opcode_encodings &processDataFile
		@code @ex @isr @dmem_bytevecs &immcheck);

#Important memory contants
use constant WIDTH => 256; #this is important to be defined correctly so that neighborhoods are interpreted correctly
use constant HEIGHT => 256; #this is important to be defined correctly so that neighborhoods are interpreted correctly
use constant VGAFB1BASE => 0; #65535 256x256 FB
use constant VGAFB2BASE => WIDTH*HEIGHT;#65537 256x256 FB
use constant DMEMBASE => 0;# byte addressable 
use constant DMEMSIZE => 4*256*256 + 200; #4 frame buffers + extra
use constant EXBASE=> 2000;
use constant ISRBASE => 2020; 
use constant CODEBASE=> 0;
use constant ENDOFIMEM => 2047;

our %csymtable; #for code 32 bit addresses
our %dsymtable; #for datamem 32 bit addresses

our %conditionals = (
	"_eq" => 0b0000, "_ne" => 0b0001, "_cs" => 0b0010, "_hs " => 0b0010, "_cc" => 0b0011, "_cl" => 0b0011, "_mi"=> 0b0100, "_pl"=> 0b0101,
	"_vs"=> 0b0110, "_vc"=> 0b0111, "_hi"=> 0b1000, "_ls"=> 0b1001, "_ge"=> 0b1010, "_lt" => 0b1011, "_gt" => 0b1100, "_le" => 0b1101,
	"_al" => 0b1111);

our %shiftcodes = ( "lsl" => 0b00, "lsr" => 0b01, "asr" => 0b10);

our %opcode_encodings = ("add" => 0b00000, "and" => 0b00001, "bic" => 0b00010, "noop" => 0b00011, "or" => 0b00100, "rsb" => 0b00101,
			"sub" => 0b00110, "swp" => 0b00111, "accumbytes" => 0b01000, "mxmul" => 0b01001, "mxadd" => 0b01010 ,"mxsub" => 0b01011,
			"b" => 0b01100, "bl" => 0b01101, "cmp" => 0b01110, "mov" => 0b01111, "not" => 0b10000, "teq" => 0b10001,
			"tst" => 0b10010, "bwcmpl" => 0b10011, "ldr" => 0b10100, "ldrb"=> 0b10101, "ldrh" => 0b10110, "ldrsb" => 0b10111, 
			"str" => 0b11001, "strb" => 0b11010, "strh" => 0b11011, "ldneighbor" => 0b11100, "strneighbor" => 0b11101,
			"return" => 0b11110, "halt" => 0b11111);


#run lc on args before indexing in
our %rf_address = ( "r0" => 0b00000, "r1" => 0b00001, "r2" => 0b00010, "r3" => 0b00011, "r4" => 0b00100, "r5" => 0b00101, 
		"r6" => 0b00110, "r7" => 0b00111, "r8" => 0b01000, "r9" => 0b01001, "r10" => 0b01010, "r11" => 0b01011, "r12" => 0b01100,
		 "r13" => 0b01101, "r14" => 0b01110, "r15" => 0b01111, "r16" => 0b10000, "r17" => 0b10001, "r18" => 0b10010, 
		"r19" => 0b10011, "r20" => 0b10100, "r21" => 0b10101, "r22" => 0b10110, "r23" => 0b10111, "r24" => 0b11000, 
		"r25" => 0b11001, "r26" => 0b11010, "r27" => 0b11011, "r28" => 0b11100,
		"r29" => 0b11101, "sp" => 0b11101, "r30" => 0b11110, "lr" => 0b11110, "r31" => 0b11111, "pc" => 0b11111 );

my $code_index = CODEBASE;
my $isr_index = ISRBASE;
my $ex_index = EXBASE;
our @code; our @isr; our @ex; #hold preprocessed code for each region
our @dmem_bytevecs; #used for simulation. process datafile sub pushes 8 bit Bit::Vectors onto this.
my @pseudo_op_locations; #stores from first pass what the offsets to the pseudo ops will be in the @code,@ex,@isr arrays 

#first argument is an array containing names of asm source files to read in
#returns a hash which has the filenames as keys and anonymous arrays of lines
#as the values.
sub readFiles {
	my @src_files = @_; my %program; 
	die "No assembly source files provided as arguments\n" if (@src_files == 0);
	foreach my $asmfile (@src_files) { 
		open (my $fh, '<', $asmfile) or die "Unable to open file $asmfile : $!\n";
		$program{$asmfile} = [ ]; 
		push @{$program{$asmfile}}, $_ while <$fh>;
	} 
	%program; #returns the program hash containing all the array references hashed on file names of the lines of each file
}

#makes sure condition codes are valid
sub ccodecheck{
	my $ccode = $_[0]; my $error=0;
	if ($ccode) { #if there was a conditional, make sure it is valid
		$error = 1 if(!defined($conditionals{lc($ccode)}));
	}
	return $error;
} 

#assembly gets put onto the appropriate stack depending on the label directive
#takes as an argument, the code hash reference
# and a reference to the filename array
sub FirstPass{
	my $coderef = $_[0];#reference to the data structure holding all the files	
	my $fnames= $_[1]; my $lines; my $line_num;
	my $waslabel; my $wasPseudo; my $code_offset = 1; #used to index into the code
	my $error = 0; #return value. return with 1 if error is present
	my $error_cnt = 0; my $label; my @expanded; 
	my $region_ref = 0; # a region should be specified before encountering any code
	my $index_ref = 0;
	my $region_code; #set to the string describing the region
	foreach my $file (@$fnames) {
		$line_num = 0;
		#default region is code 
		$region_ref = \@code;
		$index_ref = \$code_index; 
		$region_code = "code";
		foreach my $line (@{${$coderef}{$file}}) { 
			$line_num++;
			if ($line=~ /$ISA_REGEX::regex_blank_or_comment|$ISA_REGEX::regex_EQU/){
				next; #skip blank lines or just comment lines, and EQU lines
			} 
			#check which region of code we are in	
			#set array and index references appropriately
			if ($line =~ $ISA_REGEX::regex_region) {
				if (lc($1) eq "code") {
					$region_ref = \@code;
					$index_ref = \$code_index; 
					$region_code = "code";
				}elsif (lc($1) eq "isr") {
					$region_ref = \@isr;
					$index_ref = \$isr_index;
					$region_code = "isr";
				}elsif( lc($1) eq "ex") {
					$region_ref = \@ex;
					$index_ref = \$ex_index;
					$region_code = "ex";
				}
				next;
			} 
			($label,$wasPseudo,$error) = &SyntaxCheck($line);		
			print "syntax error in file $file at line:$line_num\n" if $error; 
			$error_cnt++ if $error;
			my $labelerror = &addToCSymTable($label,$$index_ref) if $label;
			print "duplicate label found in $file at line: $line_num\n" if $labelerror;
			$error_cnt++ if $labelerror;

			${$region_ref}[$$index_ref]= $line;

			if ($wasPseudo) {
				push @pseudo_op_locations, [$region_code,$$index_ref]; #pushing anonymous array ref 
				if ($line =~ /$ISA_REGEX::regex_ldadr/){
					#make room for the extra instructions
					$$index_ref += 6; #ldadr unrolls to 7 instructions
				}
				#if was a pseudo, still put it into the region array, but later on, will b expanded and spliced in
			}
			$$index_ref += 1; #one instruction word. we inc by 1 in either case 
		} #foreach line
	}#foreach my $file	
	
	if ($error_cnt > 0){ die "Errors present, EXITING\n"; }
} 

#returns an 1 for error, 0 for everything ok
#checks a single line of code for syntax
#returns ($waslabel,$wasPseudo, $error)
sub SyntaxCheck {
	my $line = $_[0]; 
	my $error = 0; #return value. return with 1 if error is present
	my $waslabel = 0;
	my $wasPseudo = 0;
	foreach my $pattern (@ISA_REGEX::regexes) { 
		if ($line =~ /$pattern/i) {
			$waslabel = $1; #will set label to the value extracted
			$error  = $error || &ccodecheck($3); #ccode is always $3, this throws error if invalid CC	
			return ($waslabel,$wasPseudo,$error);
		}
		else {
			next; #try next pattern
		}
	} 
	if ($line =~ /$ISA_REGEX::regex_branch/) {
		$waslabel = $1; #will set label to the value extracted
		my $param = $4;
		#need additional check to see if this particular branch is pseudo op
		if ($param =~ /^\<\w+\>/){ 
			#means that this argument was a LABEL, which also means we now have a pseudo op branch 
			$wasPseudo = 1;	
		}
		$error = &ccodecheck($3); #ccode is always $3, this throws error if invalid CC	
		return ($waslabel,$wasPseudo,$error);
	}
	if ($line =~ /$ISA_REGEX::regex_ldadr/) { #need to check this one separately, to set wasPseudo flag
		$waslabel = $1; #will set label to the value extracted
		$wasPseudo = 1;	
		$error = &ccodecheck($3); #ccode is always $3, this throws error if invalid CC	
		return ($waslabel,$wasPseudo,$error);
	}

	$error = 1; 
	return ($waslabel,$wasPseudo,$error);
}

#args ($label,$code_offset)
#returns ($error = 1 if label exists already)
sub addToCSymTable{
	my $label = $_[0]; my $offset = $_[1]; #reminder, this is a decimal number
	return 1 if $csymtable{$label};
	$csymtable{$label} = $offset;
	return 0;
}

sub computePseudoOps{ 
	foreach my $op_ref (@pseudo_op_locations) { 
		#call expand
		#splice the resulting array into @code at $code[offset]
		#update %csymtable every value that is > offset+splice_length += splice_length
		#pseudo op referencing a non existant label is an error

		my $region = $$op_ref[0];	
		my $offset = $$op_ref[1];# + $extra_instr_offset; 
		#add in the offset because of shifting instructions down, in the case of LDADR
		my $region_ref; my @region_bounds;

		#first arg is the region string identifier
		#second is theoffset within the particular region
		my $line; my @expanded_instr; #my $number_of_new_instr; 
		
		#decide which region to splice code into
		if ($region eq "code"){
			$region_ref = \@code; @region_bounds = (CODEBASE,$offset,ENDOFIMEM);
		}elsif ($region eq "isr"){
			$region_ref = \@isr; @region_bounds = (ISRBASE,$offset,CODEBASE - 1);
		}elsif ($region eq "ex"){
			$region_ref = \@ex; @region_bounds = (EXBASE,$offset,ISRBASE - 1);
		}		

		$line = ${$region_ref}[$offset]; 
		if ($line =~ /$ISA_REGEX::regex_ldadr/){	
			@expanded_instr = &expandLDADR($line); 
			splice(@$region_ref,$offset,7,@expanded_instr); 
		}elsif ($line =~ /$ISA_REGEX::regex_branch/){
			#encode the jump in the immediate field of the branch
			$4 =~ m/(\w+)/;
			my $labeltarget = $1;	
			die "Trying to branch to unknown label $labeltarget" unless exists($csymtable{$labeltarget});
			my $labeladd = $csymtable{$labeltarget};
			my $imm = $labeladd - $offset - 2;#(DMEMBASE + $offset -2) should be the PC.
			$line =~ s/(.*?)<\w+>/$1 $imm/;
			#replace the branch instr in the array
			$$region_ref[$offset] = $line;
		} 
	
	} #foreach pseudo op expansion 
	return 1; #success 
} 

#when a pseudo op is detected, this sub is called and it unrolls it into the
#appropriate instructions.
#return an array of code to be spliced into the appropriate code region 
sub expandLDADR{
	#extract the label and opcode. it determines what we do
	my $line = $_[0];
	$line =~ /$ISA_REGEX::ldadr/;
	
	my $opcode = $2;
	my $cc = $3;	
	my $rd = $4; 
	my $target_label = $5;
	my $label_address;
	#check the csymtable, AND the dsymtable;
	if (defined($csymtable{$target_label})){
		$label_address =$csymtable{$target_label}; 
	}elsif (defined($dsymtable{$target_label})){
		$label_address =$dsymtable{$target_label};
	}else {
		die "Invalid Label: $target_label";	#illegal label
	}
	#get this decimal address into binary
	#OR bits 11:0 		
	#the immediates could be 12 bits, but we leave the 12th bit (index 11) as zero
	#to avoid the sign extension

	my $bits31_22; my $bits21_11; my $bits10_0; 
	$bits10_0 = $label_address & 0x07FF; 
	$bits21_11 = $label_address & 0x03F_F800;
	$bits21_11 = $bits21_11 >> 11; 
	$bits31_22 = $label_address & 0x0_FFC0_0000;
	$bits31_22 = $bits31_22 >> 11; 
	my $result = ($bits31_22 << 22) | ($bits21_11 << 11) |   $bits10_0; 
	my @expanded = (
		" and".$cc." $rd,$rd, 0", #clear rd 
		" add".$cc." R28,$rd, 11", #shift amount, uses R28
		" or".$cc." $rd,$rd, ". sprintf("%d", $bits31_22),
		" mov".$cc." $rd, $rd, R28 lsl", #do shift
		" or".$cc." $rd, $rd, ". sprintf("%d", $bits21_11),
		" mov".$cc." $rd, $rd, R28 lsl", #do shift
		" or".$cc." $rd, $rd, ". sprintf("%d", $bits10_0)); 
	return @expanded;
}


#do all processing for the datafile, and output it into dmem.bin
#also, populate a data structure that the simulator can use
sub processDataFile {

	my $fname = $_[0];
	my $outfname = $_[1];
	my $prnt = $_[2]; #if called by the asm.pl, it will tell this routine to output files
	my $line_num = 0;
	my $offset=0; #add to DMEMBASE to determine where to put symbols.  
	my $label; my $label_address; my $arg; my $vec; my @vec_bytes;
	my $bytecount = 0; #count how many bytes the dmem takes up

	#open output files
	my ($TXTOUT, $DBGOUT, $RMEMHOUT, $XILINXOUT, @XILINXOUT4BANK);	
	if ($prnt){
		open ($TXTOUT, '>',"$outfname.dmemhex") or die "Unable to open file for write $outfname.hex: $!\n"; 
		open ($DBGOUT, '>',"$outfname.dmemdebug") or die "Unable to open file for write $outfname.debug: $!\n"; 
		open ($RMEMHOUT, '>',"$outfname.readmemh") or die "Unable to open file for write $outfname.readmemh: $!\n"; 
		open ($XILINXOUT, '>',"$outfname.dmem.coe") or die "Unable to open file for write $outfname.dmem.coe: $!\n"; 
		open ($XILINXOUT4BANK[0], '>',"$outfname.dmem4bank0.coe") or die "Unable to open file for write $outfname.dmem4bank0.coe: $!\n"; 
		open ($XILINXOUT4BANK[1], '>',"$outfname.dmem4bank1.coe") or die "Unable to open file for write $outfname.dmem4bank1.coe: $!\n"; 
		open ($XILINXOUT4BANK[2], '>',"$outfname.dmem4bank2.coe") or die "Unable to open file for write $outfname.dmem4bank2.coe: $!\n"; 
		open ($XILINXOUT4BANK[3], '>',"$outfname.dmem4bank3.coe") or die "Unable to open file for write $outfname.dmem4bank3.coe: $!\n"; 
		
	}

	print $DBGOUT "THIS DATA MEMORY IS ORGANIZED BIG-ENDIAN\n" if $prnt;
	print $XILINXOUT "memory_initialization_radix = 16;\nmemory_initialization_vector =\n" if $prnt;
	foreach my $FHANDLE (@XILINXOUT4BANK){
		print $FHANDLE "memory_initialization_radix = 16;\nmemory_initialization_vector =\n" if $prnt;
	}

	open (my $fh, '<', $fname) or die "Unable to open file $fname\n";
	while  (<$fh>) {
		my $line = $_;
		$line_num++;
		next if ($line =~ /$ISA_REGEX::regex_blank_or_comment/); #skip blanks or comments

		if ($line =~ /^(?:(\w+):)?\s+\.space\s+(\d+)/i) {
			$arg = $2; $label = $1;	$label_address = $offset;
			printf $DBGOUT("ADDR:0x%x LABEL:%s DECLARED_AS:space (%s bytes)\n",$offset,$label,$arg) if $prnt;
			$bytecount += $arg;
			$vec = Bit::Vector->new_Dec(8,0);
			for (my $i = 0; $i < $arg; $i++) {
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt; 
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			} 
		}
		elsif ($line =~ /^(?:(\w+):)?\s+\.word40\s+((?:0x[0-9a-f]{10})|-?\d+)/i) {
			$arg = $2; $label = $1; $label_address = $offset;	
			if ($arg =~ m/^0x([0-9a-f]{10})/i){ $vec = Bit::Vector->new_Hex(40,$1);
			} else{ $vec = Bit::Vector->new_Dec(40,$arg); }	
			$bytecount += 5; #40 bit word
			printf $DBGOUT("ADDR:0x%x LABEL:%s DECVAL:%s DECLARED_AS:word40\n",$offset,$label,$vec->to_Dec()) if $prnt;
			@vec_bytes = $vec->Chunk_List_Read(8);	
			for (my $i = 4; $i >= 0; $i--) {
				$vec= Bit::Vector->new_Dec(8,$vec_bytes[$i]);
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt; 
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			} 
		}
		elsif ($line =~ /^(?:(\w+):)?\s+\.word16\s+(0x[0-9a-f]{4}|-?\d+)/i) {
			$arg = $2; $label = $1;	$label_address = $offset;
			if ($arg =~ m/^0x([0-9a-f]{4})/i){ $vec = Bit::Vector->new_Hex(16,$1);
			} else{ $vec = Bit::Vector->new_Dec(16,$arg); }	
			printf $DBGOUT("ADDR:0x%x LABEL:%s DECVAL:%s DECLARED_AS:word16\n",$offset,$label,$vec->to_Dec()) if $prnt;
			$bytecount += 2; #16 bit word
			@vec_bytes = $vec->Chunk_List_Read(8);	
			for (my $i = 1; $i >= 0; $i--) {
				$vec= Bit::Vector->new_Dec(8,$vec_bytes[$i]);
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			} 
		}
		elsif ($line =~ /^(?:(\w+):)?\s+\.word32\s+(0x[0-9a-f]{8}|-?\d+)/i) {
			$arg = $2; $label = $1;	$label_address = $offset;
			if ($arg =~ m/^0x([0-9a-f]{8})/i){ $vec = Bit::Vector->new_Hex(32,$1);
			} else{ $vec = Bit::Vector->new_Dec(32,$arg); }	
			$bytecount += 4; #32 bit word
			printf $DBGOUT("ADDR:0x%x LABEL:%s DECVAL:%s DECLARED_AS:word32\n",$offset,$label,$vec->to_Dec()) if $prnt;
			@vec_bytes = $vec->Chunk_List_Read(8);	
			for (my $i = 3; $i >= 0; $i--) {
				$vec= Bit::Vector->new_Dec(8,$vec_bytes[$i]);
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			} 
		}
		elsif ($line =~ /^(?:(\w+):)?\s+\.byte\s+(0x[0-9a-f]{2}|-?\d+)/i) {
			$arg = $2; $label = $1;	$label_address = $offset;
			if ($arg =~ m/^0x([0-9a-f]{2})/i){ $vec = Bit::Vector->new_Hex(8,$1);
			} else{ $vec = Bit::Vector->new_Dec(8,$arg); }	
			$bytecount += 1; 
			printf $DBGOUT("ADDR:0x%x LABEL:%s DECVAL:%s DECLARED_AS:byte\n",$offset,$label,$vec->to_Dec()) if $prnt;
			printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
			printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
			printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
			printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
			my $bankfh = $XILINXOUT4BANK[$offset % 4];
			printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
			$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone(); 
		}
		elsif ($line =~ m{^(\w+):\s+\.file\s+([\w./]+)}i) {
			$label = $1; $label_address = $offset;	
			my $fname = $2;
			open (my $FH, "<", $fname) or die "Could not open $fname for datafile processing $!";

			printf $DBGOUT("ADDR:0x%x LABEL:%s DECLARED_AS: Ascii Hex file %s\n",$offset,$label,$fname) if $prnt;
			my @bytes;
			while (<$FH>){
				next if /$ISA_REGEX::regex_blank_or_comment/;
				push @bytes, split(/\s+/,$_); 	
			}
			foreach my $byte (@bytes){
				$bytecount += 1; 
				$vec = Bit::Vector->new_Hex(8,$byte);
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				#printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
				printf $DBGOUT("%s",$vec->to_Hex()) if $prnt;
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			}
			print $DBGOUT("\n") if $prnt; 
		}
		elsif ($line =~ m{^(\w+):\s+\.filebin\s+([\w./]+)}i) {
			$label = $1; $label_address = $offset;	
			my $fname = $2;
			open (my $FH, "<", $fname) or die "Could not open $fname for datafile processing $!";
			binmode ($FH);

			printf $DBGOUT("ADDR:0x%x LABEL:%s DECLARED_AS: binary file %s\n",$offset,$label,$fname) if $prnt;
			my $linecount = 0;
			my $channel = 0;
			while (read($FH,my $byte,1)){ #read raw byte data from the file
				$bytecount += 1; 
				$vec = Bit::Vector->new_Dec(8,ord($byte));
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				#printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
				printf $DBGOUT("%s",$vec->to_Hex()) if $prnt; 
				print $DBGOUT(" ") if $prnt and ($channel++ == 2);
				print $DBGOUT("\n") if $prnt and ($linecount++ == 255);
				$linecount = 0 if $linecount == 256;
				$channel = 0 if $channel == 3;
				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf  $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			}
			print $DBGOUT("\n") if $prnt; 
		}elsif ($line =~ m{^(\w+):\s+\.filebincolor\s+([\w./]+)}i) { #this routine assumes a binary {(RGB),(RGB),...} format file
			$label = $1; $label_address = $offset;	
			my $fname = $2;
			open (my $FH, "<", $fname) or die "Could not open $fname for datafile processing $!";
			binmode ($FH);

			printf $DBGOUT("ADDR:0x%x LABEL:%s DECLARED_AS: color binary file %s\n",$offset,$label,$fname) if $prnt;
			my $linecount = 0;
			my ($byteR,$byteG,$byteB);
			while (read($FH,$byteR,1) and read($FH,$byteG,1) and  read($FH,$byteB,1)){ #read 3 raw byte data from the file
				$byteR = ord($byteR);
				$byteG = ord($byteG);
				$byteB = ord($byteB);
				$vec = &colorEncode($byteR,$byteG,$byteB); #encode the 3 bytes down to a single byte
				printf $TXTOUT ("%s", $vec->to_Hex()) if $prnt;
				#printf $DBGOUT("ADDR:0x%x VAL: 0x%s %s\n",$offset,$vec->to_Hex(),$vec->to_Bin()) if $prnt;
				printf $DBGOUT("%s",$vec->to_Hex()) if $prnt;
				print $DBGOUT("\n") if $prnt and ($linecount++ == 255);
				$linecount = 0 if $linecount == 256;
				$bytecount += 1; 

				printf $RMEMHOUT ("@%x %s\n", $offset,$vec->to_Hex()) if $prnt; 
				printf $XILINXOUT ("%s\n", $vec->to_Hex()) if $prnt; 
				my $bankfh = $XILINXOUT4BANK[$offset % 4];
				printf  $bankfh ("%s\n", $vec->to_Hex()) if $prnt; 
				$dmem_bytevecs[DMEMBASE+$offset++] = $vec->Clone();
			}
			print $DBGOUT("\n") if $prnt; 
		} 
		else{ die "Malformed expression in .data file on line: $line_num\nEXITING..."; }

		#update %dsymtable if a label was specified
		if ($label) {
			if (defined($dsymtable{$label})){
				die "Duplicate label $label in .data file on line: $line_num\nEXITING..."; 
			}
			$dsymtable{$label} = DMEMBASE + $label_address;	
		}
	} 
	#terminate the coe file
	print $XILINXOUT ";" if $prnt;
	foreach my $fh (@XILINXOUT4BANK){
		print $fh ";" if $prnt;
	}

	#print dmem stats
	printf ("Dmem usage summary:\n%d bytes.\n%d 40-bit words.\n",$bytecount,$bytecount/5);	
	printf ("%f framebuffers.\n",$bytecount/(256*256));

}

#argument is 3 8 bit Bit::Vector
#returns a single 8 bit Bit::Vector, encoded
sub colorEncode {
	my ($rval, $gval, $bval) = @_; 
	my ($rvalv, $gvalv, $bvalv);
	$rvalv = Bit::Vector->new(3);
	$gvalv = Bit::Vector->new(2);
	$bvalv = Bit::Vector->new(2);

	if ($rval < 13) {
		$rvalv->from_Bin("000");	
	} elsif ($rval >= 13 && $rval < 49) {
		$rvalv->from_Bin("001");	
	} elsif ($rval >= 49 && $rval < 85) {
		$rvalv->from_Bin("010");	
	} elsif ($rval >= 85 && $rval < 121) { 
		$rvalv->from_Bin("011");	
	} elsif ($rval >= 121 && $rval < 157) {
		$rvalv->from_Bin("100");	
	} elsif ($rval >= 157 && $rval < 193) {
		$rvalv->from_Bin("101");	
	} elsif ($rval >= 193 && $rval < 229) {
		$rvalv->from_Bin("110");	
	} else { $rvalv->from_Bin("111");}


	if ($gval < 32) {
		$gvalv->from_Bin("00");
	} elsif ($gval >= 32 && $gval < 96) {
		$gvalv->from_Bin("01"); 
	} elsif ($gval >= 96 && $gval < 160) {
		$gvalv->from_Bin("10"); 
	} else { $gvalv->from_Bin("11");}

	if ($bval < 32) {
		$bvalv->from_Bin("00");
	} elsif ($bval >= 32 && $bval < 96) {
		$bvalv->from_Bin("01"); 
	} elsif ($bval >= 96 && $bval < 160) {
		$bvalv->from_Bin("10"); 
	} else { $bvalv->from_Bin("11");}

	my $alive = Bit::Vector->new_Bin(1,"1"); 
	my $enc = Bit::Vector->Concat_List(($bvalv,$gvalv,$rvalv,$alive)); 
	return $enc;			
}



sub max {
	my $max;
	$max = $_ > $max ?  $_ : $max foreach (@_); 
	return $max;
}

#replaces each instance of the search term with the replacement
#term (but not in comments)
#EQU's must be at the start of the file (besides // comments)
#once code starts an EQU directive is illegal and aborts the assembly
#expects an array reference containing all the lines within a file
#EQU's are local to their file
sub EQUreplace {
	my $lines = $_[0]; my $incode = 0;
	my %equ; #keys are the search, values are the replace	
	my $line_num = 0;	
	foreach my $line ( @$lines) {
		$line_num++;
		if (!$incode) {
		#still searching for equ's	
			next if $line =~ m[$ISA_REGEX::regex_blank_or_comment]; # a comment or blank line 
			if ($line =~ m[$ISA_REGEX::regex_EQU]) {			
				$equ{$1} = $2; next;
			}
			else { #not a comment, and not an equ line, must be code
				#check if it was an equ line, but formatted wrong
				die "Malformed EQU statement at line: $line_num\n"."Exiting\n" if $line =~ m[^\.EQU.*];
				$incode = 1;
			}
		}
		#can fall out of this if to here, not lines are code. should not see .EQU
		die "Illegal .EQU statement once code starts. line: $line_num\n"."Exiting\n" if $line =~ m[^\.EQU.*]; 
		#do replaces
		foreach my $searchterm (keys %equ) {
			$line =~ s/$searchterm/$equ{$searchterm}/g;
		}	
	}
	#this code modified a reference to the array, so no return value is needed
	return 1;
} 

#first arg, number of bits, second arg initilization value
sub immcheck {
	my ($numbits,$init) = @_;
	my $v = Bit::Vector->new_Dec($numbits,$init);
	if ($v->to_Dec() == $init) {
		return 1;
	} else {
		die "Could not fit $init into $numbits vector, check your immediates";
	}
}


1; #needed by pm import
