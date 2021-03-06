#! /usr/bin/perl 
# Architecture simulator for the ECE 554 Binary Evolution ISA # 2/11/2011 by Cody Hanson # If you don't like my code, TMTOWTDI 
use strict;
#use warnings;
use ISA_TOOLS;
use ISA_REGEX;
use Bit::Vector; # I <3 Bit::Vector
use IO::Tee; #write to stdout and file at the same time

my $DEBUGMODE = 0;
my $QUIET = 0;
my %program;
my @src_filenames;
my $data_filename;
my $fbdump_count = 1;

#args
my $outdir = shift @ARGV; 
#create the output dir
if (stat($outdir)) {
	print "Using existing directory for output $outdir\n";
}else {
	print "creating directory for output $outdir\n";
	mkdir $outdir or die "Could not create output directory $!";
}
foreach (@ARGV) {
	if (/^--.*/) { #found the option token 
		$DEBUGMODE = 1 if (/d/); #other option checks can go here 
		$QUIET = 1 if (/q/); 
	}
	else { # regular asm source file, not an option
		if (/\w+\.s/){
			push @src_filenames, $_; #assembly files that end in .s 
		}
		elsif (/.*\.data/ and !defined($data_filename)){ 
			#data file end in .data 	
			#also can only have one.datafile
			$data_filename = $_;
		}
		else {
			#was not a .s file, or .data file, or 2 .data files were specified
			die "USAGE: sim.pl <Destination output directory> <.s asm source files> <.data dmem initialization file> EXITING...\n";
		}
	}
}

#if no datafilename, error
die "USAGE: sim.pl <.s asm source files> <.data dmem initialization file> EXITING...\n" unless $data_filename;

%program = &readFiles(@src_filenames); 
&processDataFile($data_filename,"dontwriteme",0); #do not write to files, only populate the datastructure for dmem
&EQUreplace($program{$_}) foreach (@src_filenames); #perform macro substition.  
&FirstPass(\%program,\@src_filenames);
&computePseudoOps;

my @t = localtime();
(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime(time);
$year += 1900;
$mon += 1;

my $fname = "$outdir/simtrace.$hour.$min.$sec-$mon-$mday-$year.dump";
open (my $DUMP, ">",$fname) or die "could not open dumpfile $fname for writing $!";
open (my $DIFF, ">",$fname."diffable") or die "could not open dumpfile $fname.diffable for writing $!"; #the more simple, diffable with modelsim file

open(my $stdout_dup, ">&STDOUT") or die "couldnt do that thing with the dup $!";
my $tee = IO::Tee->new($DUMP,$stdout_dup); #this way we print to STDOUT and the dumpfile for the trace

if ($QUIET) {
	print $tee "Quiet mode enabled. Only RF and memory will be dumped.\n";
}

##############################################################################
#begin simulation
##############################################################################
#merge all code segments together

my @allcode = (@ex[ISA_TOOLS::EXBASE..ISA_TOOLS::ISRBASE-1],@isr[ISA_TOOLS::ISRBASE..ISA_TOOLS::CODEBASE-1],@code[ISA_TOOLS::CODEBASE..ISA_TOOLS::ENDOFIMEM]);
chomp (@allcode); 

# the magic number 40 is the bit width of our datapath
my %rf= ( "r0" => Bit::Vector->new_Dec(40,0), "r1" => Bit::Vector->new_Dec(40,0), "r2" => Bit::Vector->new_Dec(40,0), "r3" => Bit::Vector->new_Dec(40,0), 
		"r4" => Bit::Vector->new_Dec(40,0), "r5" => Bit::Vector->new_Dec(40,0), "r6" => Bit::Vector->new_Dec(40,0), "r7" => Bit::Vector->new_Dec(40,0), 
		"r8" => Bit::Vector->new_Dec(40,0), "r9" => Bit::Vector->new_Dec(40,0), "r10" => Bit::Vector->new_Dec(40,0), "r11" => Bit::Vector->new_Dec(40,0), 
		"r12" => Bit::Vector->new_Dec(40,0), "r13" => Bit::Vector->new_Dec(40,0), "r14" => Bit::Vector->new_Dec(40,0), "r15" => Bit::Vector->new_Dec(40,0), 
		"r16" => Bit::Vector->new_Dec(40,0), "r17" => Bit::Vector->new_Dec(40,0), "r18" => Bit::Vector->new_Dec(40,0), "r19" => Bit::Vector->new_Dec(40,0), 
		"r20" => Bit::Vector->new_Dec(40,0), "r21" => Bit::Vector->new_Dec(40,0), "r22" => Bit::Vector->new_Dec(40,0), "r23" => Bit::Vector->new_Dec(40,0), 
		"r24" => Bit::Vector->new_Dec(40,0), "r25" => Bit::Vector->new_Dec(40,0), "r26" => Bit::Vector->new_Dec(40,0), "r27" => Bit::Vector->new_Dec(40,0), 
		"r28" => Bit::Vector->new_Dec(40,0), "r29" => Bit::Vector->new_Dec(40,0), "r30" => Bit::Vector->new_Dec(40,0),
		 "r31" => Bit::Vector->new_Dec(40,ISA_TOOLS::CODEBASE)); 

my @dmem;
my $instr;  #the current instruction PC points to
my $label; #print the label of an instruction, if it exists
my $instr_cc;#instruction condition code
my %CC = ("Z" => 0, "C" => 0, "V" => 0, "N" => 0); #condition code storage
my $rm; my $rn; my $rd; my $carry; my $overflow; my $thirdarg; my $secondarg; my $firstarg;
my $rm2; my $rn2; my $rd2;
my $tmpvec1 = Bit::Vector->new(40);
my $tmpvec2 = Bit::Vector->new(40);
my $zerovec = Bit::Vector->new_Dec(40,0);

unless ($QUIET) {
print $tee "BEGIN SIMULATION TRACE FOR FILES:";
print  $tee "$_," foreach (@src_filenames);
print $tee " and datafile $data_filename\n";
}

#begin the perl implementation of Fetch Decode Execute
while (1) {

	$_ = $allcode[$rf{"r31"}->to_Dec()-1]; #for less typing
	s{^(?:(\w+):)?([^/\n]*?)(\s+//.*)$}{$2}; #get rid of whitespace
	$label = $1;	

	#default pc in by one.
	$rf{"r31"}->increment(); #increment the PC

	if (/$ISA_REGEX::regex_add/) {
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg);	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		($carry,$overflow) = $tmpvec1->add($rf{$rm},$thirdarg,0); #the actual add operation					

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex()); 
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified

	}elsif(/$ISA_REGEX::regex_bic/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec2 = $thirdarg->Clone();
		$tmpvec2->Flip();
		$tmpvec1->And($rf{$rm},$tmpvec2); #the actual BIC operation					

		unless ($QUIET) { 
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified

	}elsif(/$ISA_REGEX::regex_and/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1->And($rf{$rm},$thirdarg); #the actual AND operation					

		unless ($QUIET) {		
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}		
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 

	}elsif(/$ISA_REGEX::regex_or/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf  $tee ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1->Or($rf{$rm},$thirdarg); #the actual OR operation					

		unless ($QUIET) {		
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 

	}elsif(/$ISA_REGEX::regex_rsb/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		($carry,$overflow) = $tmpvec1->subtract($thirdarg,$rf{$rm},0); #the actual REVERSE subtract operation					

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 


	}elsif(/$ISA_REGEX::regex_sub/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		if ($thirdarg =~ /r\d\d?/) {
			$rn = $thirdarg; $thirdarg = $rf{$rn};
		}else { #decmimal literal
			$rn = "LITERAL"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		($carry,$overflow) = $tmpvec1->subtract($rf{$rm},$thirdarg,0); #the actual subtract operation					

		unless ($QUIET) {		
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 


	}elsif(/$ISA_REGEX::regex_swp/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3);
		$rn = $thirdarg; $thirdarg = $rf{$rn};

		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1 = $rf{$rn}->Clone();	
		$tmpvec2 = $rf{$rm}->Clone();	

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s New RD:%-4s = %s,New RN:%s = %s, RM: %s = %s, RN: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rn,$tmpvec2->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		printf $DIFF ("%s= %s\n",$rn,$tmpvec2->to_Hex());
		}

		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		$rf{$rn} = $tmpvec2->Clone(); #commit the change to the RF
		#Does Not Set Flags

	}elsif(/$ISA_REGEX::regex_branch/){
		$firstarg = lc($4);  $instr_cc = lc($3); my $opcode = lc($2); #for B vs BL
		 (my $ccresult) =&checkCC($instr_cc); 	
		if ($ccresult == 0) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET;; next; }	
	
		#opcode determines whether to set LR or not
		if ($opcode eq "bl"){
			#r30 gets incremented PC	
			$rf{"r30"} = $rf{"r31"}->Clone();
			printf $DIFF ("r30= %s\n",$rf{"r30"}->to_Hex()) unless $QUIET;;
		}

		if ($firstarg =~ /r\d\d?/) {
			$rd = $firstarg; $firstarg= $rf{$rd};
			$rf{"r31"} = $firstarg->Clone(); #setting the PC	
		}else { #decmimal literal
			$rd = "LITERAL"; 
			$firstarg = Bit::Vector->new_Dec(40,$firstarg); #sign extends to 40 bits	
			$rf{"r31"}->add($rf{"r31"},$firstarg,1); #add one for cin to offset the pc + 2 asm encoding for superscalar
		}

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s New PC: %s RDorLITERALPCOFFSET: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rf{"r31"}->to_Hex(),$rd,$firstarg->to_Hex());
		}
		#Does not set flags

	}elsif(/$ISA_REGEX::regex_cmp/){
		$rd = lc($4); $secondarg = lc($5); $instr_cc = lc($3);
		if ($secondarg =~ /r\d\d?/) {
			$rm = $secondarg; $secondarg = $rf{$rm};
		}else { #decmimal literal
			$rm = "LITERAL"; $secondarg = Bit::Vector->new_Dec(40,$secondarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET;; next; }	

		($carry,$overflow) = $tmpvec1->subtract($rf{$rd},$secondarg,0); #the actual CMP operation					

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s Result of CMP: %s RD:%-4s = %s, RMorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$tmpvec1->to_Hex(),$rd,$rf{$rd}->to_Hex(),$rm,$secondarg->to_Hex());
		}
		#DOES NOT WRITE TO THE RF
		&setCC($tmpvec1->Clone(),$carry,$overflow);#send a clone so the value is not modified 

	}elsif(/$ISA_REGEX::regex_not/){
		$rd = lc($4); $secondarg = lc($5); $instr_cc = lc($3);
		if ($secondarg =~ /r\d\d?/) {
			$rm = $secondarg; $secondarg = $rf{$rm};
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET;; next; }	

		$tmpvec1 = $secondarg->Clone();
		$tmpvec1->Flip();

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm,$secondarg->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		&setCC($tmpvec1->Clone(),$carry,$overflow);#send a clone so the value is not modified 


	}elsif(/$ISA_REGEX::regex_teq/){
		$rd = lc($4); $secondarg = lc($5); $instr_cc = lc($3);
		if ($secondarg=~ /r\d\d?/) {
			$rm = $secondarg; $secondarg = $rf{$rm};
		}else { #decmimal literal
			$rm = "LITERAL"; $secondarg = Bit::Vector->new_Dec(40,$secondarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1->Xor($rf{$rd},$secondarg,0); #the actual TEQ operation					

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s Result of TEQ: %s RD:%-4s = %s, RMorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$tmpvec1->to_Hex(),$rd,$rf{$rd}->to_Hex(),$rm,$secondarg->to_Hex());
		}
		#DOES NOT WRITE TO THE RF
		&setCC($tmpvec1->Clone(),$carry,$overflow);#send a clone so the value is not modified 


	}elsif(/$ISA_REGEX::regex_tst/){
		$rd = lc($4); $secondarg = lc($5); $instr_cc = lc($3);
		if ($secondarg=~ /r\d\d?/) {
			$rm = $secondarg; $secondarg = $rf{$rm};
		}else { #decmimal literal
			$rm = "LITERAL"; $secondarg = Bit::Vector->new_Dec(40,$secondarg); #sign extends to 40 bits	
		}
		if (!&checkCC($instr_cc)) { 
		printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET;
		 next; }	

		$tmpvec1->And($rf{$rd},$secondarg); #the actual TST operation					

		unless ($QUIET) {		
		printf $tee  ("PC:%s %-12s INSTR:%-20s Result of TST: %s RD:%-4s = %s, RMorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$tmpvec1->to_Hex(),$rd,$rf{$rd}->to_Hex(),$rm,$secondarg->to_Hex());
		}
		#DOES NOT WRITE TO THE RF
		&setCC($tmpvec1->Clone(),$carry,$overflow);#send a clone so the value is not modified 

	}elsif(/$ISA_REGEX::regex_mov/){
		$rd = lc($4); $secondarg = lc($5);  $instr_cc = lc($3); 
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		if ($secondarg=~ /r\d\d?/) {
			m/$ISA_REGEX::regex_mov/; #reset the match vars	
			$secondarg = lc($6); $thirdarg = lc($7); my $shift = lc($8);
			$rm = $secondarg; $secondarg= $rf{$rm};
			$rn = $thirdarg; $thirdarg= $rf{$rn};
			$tmpvec1 = $secondarg->Clone();
			if ($shift eq "lsl") { 
				$tmpvec1->Move_Left($thirdarg->to_Dec());
			}elsif ($shift eq "lsr"){ 
				$tmpvec1->Move_Right($thirdarg->to_Dec()); 
			}elsif ($shift eq "asr") {
				for (my $i=0; $i < $thirdarg->to_Dec(); $i++){
					$tmpvec1->Shift_Right($tmpvec1->msb()); 
				} 
			}
			unless ($QUIET) {
			printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
		 	$rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$thirdarg->to_Hex());
			printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex()); 
			}
			$rf{$rd} = $tmpvec1->Clone(); #put the shifted value into the RF

		}else { #decmimal literal no shifting required
			$rm = "LITERAL"; $secondarg = Bit::Vector->new_Dec(40,$secondarg);	
			$rf{$rd} = $secondarg->Clone(); #putting immediate value into the RF

			printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, LITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$rm ,$secondarg->to_Hex()) unless $QUIET;
		}

		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 

	}elsif(/$ISA_REGEX::regex_bwcmpl/){
		$rd = lc($4); $rm = lc($5); $instr_cc = lc($3);
		
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_); next; }	

		#break out each part of $rm and $rn into byte size chunks
		my @rm_bytes = $rf{$rm}->Chunk_List_Read(8);
		for (my $i = 0; $i < 5; $i++) {
			$tmpvec1 = Bit::Vector->new_Dec(8,$rm_bytes[$i]);
			$tmpvec1->Neg($tmpvec1);
			$rm_bytes[$i] = $tmpvec1->Clone();
		}
		$tmpvec1 = Bit::Vector->Concat_List(reverse @rm_bytes); #assemble back into a 40 bit word

		unless ($QUIET) {		
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex()); 
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF

		#Does not set flags
	}elsif(/$ISA_REGEX::regex_mxadd/ or m/$ISA_REGEX::regex_mxsub/ or m/$ISA_REGEX::regex_mxmul/){
		$rd = lc($4); $rm = lc($5); $rn = lc($6); $instr_cc = lc($3); my $opcode =lc($2);
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		my $newnum; #break out each part of $rm and $rn into byte size chunks
		$rm =~ /r(\d\d?)/; $newnum = 1 + $1; $rm2 = "r". $newnum; 
		$rn =~ /r(\d\d?)/; $newnum = 1 + $1; $rn2 = "r". $newnum; 
		$rd =~ /r(\d\d?)/; $newnum = 1 + $1; $rd2 = "r". $newnum; 

		my @rm_bytes = $rf{$rm}->Chunk_List_Read(8);
		my @rm2_bytes = $rf{$rm2}->Chunk_List_Read(8);
		my @rn_bytes = $rf{$rn}->Chunk_List_Read(8);
		my @rn2_bytes = $rf{$rn2}->Chunk_List_Read(8);
		my @rd_bytevecs;
		my @rd2_bytevecs;
		for (my $i = 4; $i >= 0; $i--) {
			$tmpvec2 = Bit::Vector->new_Dec(8,$rm_bytes[$i]);
			$tmpvec1 = Bit::Vector->new_Dec(8,$rn_bytes[$i]);
			$rd_bytevecs[$i] = Bit::Vector->new(8);
			if ($opcode eq "mxadd"){
				$rd_bytevecs[$i]->add($tmpvec2,$tmpvec1,0);
			} elsif ($opcode eq "mxsub")  { #sub
				$rd_bytevecs[$i]->subtract($tmpvec2,$tmpvec1,0);
			} else { #mult
				my $tmp = Bit::Vector->new(16);
				$tmp ->Multiply($tmpvec2,$tmpvec1); 
				$rd_bytevecs[$i]->Interval_Copy($tmp,0,0,8);
			}
			$tmpvec2 = Bit::Vector->new_Dec(8,$rm2_bytes[$i]);
			$tmpvec1 = Bit::Vector->new_Dec(8,$rn2_bytes[$i]);
			$rd2_bytevecs[$i] = Bit::Vector->new(8);
			if ($opcode eq "mxadd"){
				$rd2_bytevecs[$i]->add($tmpvec2,$tmpvec1,0);
			} elsif ($opcode eq "mxsub"){ #sub
				$rd2_bytevecs[$i]->subtract($tmpvec2,$tmpvec1,0);
			} else { #mult
				my $tmp = Bit::Vector->new(16);
				$tmp ->Multiply($tmpvec2,$tmpvec1); 
				$rd2_bytevecs[$i]->Interval_Copy($tmp,0,0,8); 
			}
	
		}
		$tmpvec2 = Bit::Vector->Concat_List(reverse @rd2_bytevecs);
		$tmpvec1 = Bit::Vector->Concat_List(reverse @rd_bytevecs);

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RD+1:%s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rd2,$tmpvec2->to_Hex());#,$rm ,$rf{$rm}->to_Hex(),$rn,$rf{$rn}->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		printf $DIFF ("%s= %s\n",$rd2,$tmpvec2->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF
		$rf{$rd2} = $tmpvec2->Clone(); #commit the change to the RF

		#Does not set flags
	}elsif(/$ISA_REGEX::regex_accumbytes/){
		$rd = lc($4); $rm = lc($5); $rn = lc($6); $instr_cc = lc($3);
		
		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		#break out each part of $rm and $rn into byte size chunks
		my @rm_bytes = $rf{$rm}->Chunk_List_Read(8);
		my @rn_bytes = $rf{$rn}->Chunk_List_Read(8);
		$tmpvec1->Empty();
		for (my $i = 0; $i < 5; $i++) {
			$tmpvec2 = Bit::Vector->new_Dec(8,$rm_bytes[$i]);
			$tmpvec2->Resize(40);
			$tmpvec1->add($tmpvec2,$tmpvec1,0);	
			$tmpvec2 = Bit::Vector->new_Dec(8,$rn_bytes[$i]);
			$tmpvec2->Resize(40);
			$tmpvec1->add($tmpvec2,$tmpvec1,0);	
		}
		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RM: %s = %s, RNorLITERAL: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$tmpvec1->to_Hex(),$rm ,$rf{$rm}->to_Hex(),$rn,$rf{$rn}->to_Hex());
		printf $DIFF ("%s= %s\n",$rd,$tmpvec1->to_Hex());
		}
		$rf{$rd} = $tmpvec1->Clone(); #commit the change to the RF

		&setCC($rf{$rd}->Clone(),$carry,$overflow);#send a clone so the value is not modified 
		#sets the Z flag

	}elsif(/$ISA_REGEX::regex_str/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3); my $opcode = lc($2);
		$rn = "OFFSET"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg);#NOT TECHNICALLY CORRECT. could allow for immediates larger than allowed in 13 bits

		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1->add($rf{$rm},$thirdarg,0); #value of tempvec1 is now the data address to store into	

		#Check if the address is an mmr, and print what mmr is being stored to
		#if address is 0xFFF in upper bits, it was anmmr
		if ($tmpvec1->to_Hex() ge "FFF0000000") {
			unless ($QUIET) {
				printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s ---> MMR MEMADDR: %s\n",
				 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$tmpvec1->to_Hex());
			}	
		}
		else {

			#decide to store byte, word, or half word, based on the opcode
			my @rd_bytes = $rf{$rd}->Chunk_List_Read(8);
			#BIGENDIAN
			if ($opcode =~/^str$/) { #40 bits
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 0 ] = Bit::Vector->new_Dec(8,$rd_bytes[4]);
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 1 ] = Bit::Vector->new_Dec(8,$rd_bytes[3]);
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 2 ] = Bit::Vector->new_Dec(8,$rd_bytes[2]);
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 3 ] = Bit::Vector->new_Dec(8,$rd_bytes[1]);
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 4 ] = Bit::Vector->new_Dec(8,$rd_bytes[0]);
			} elsif ($opcode =~ /^strh$/) { #16 bits
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 0 ] = Bit::Vector->new_Dec(8,$rd_bytes[1]);
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 1 ] = Bit::Vector->new_Dec(8,$rd_bytes[0]);
			} elsif ($opcode =~ /^strb$/) { #8 bits 
				$dmem_bytevecs[$tmpvec1->to_Dec()+ 0 ] = Bit::Vector->new_Dec(8,$rd_bytes[0]);
			} 

			unless ($QUIET) {
			printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s ---> MEMADDR: %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$tmpvec1->to_Hex());
			printf $DIFF ("STORE %s= %s -> %s\n",$rd,$rf{$rd}->to_Hex(),$tmpvec1->to_Hex());
			}
		}
		#Does not set flags

	}elsif(/$ISA_REGEX::regex_ld/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3); my $opcode = lc($2);
		$rn = "OFFSET"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #NOT TECHNICALLY CORRECT. could allow for immediates larger than allowed in 13 bits

		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		$tmpvec1->add($rf{$rm},$thirdarg,0); #value of tempvec1 is now the data address to load from into	
		if ($tmpvec1->to_Hex() ge "FFF0000000") {
			unless ($QUIET) {
				printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s <-- MMR MEMADDR: %s\n",
				 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$tmpvec1->to_Hex());
			}	
		}
		else {

			#decide to store byte, word, or half word, based on the opcode
			if ($opcode =~/^ldr$/) { #40 bits
				$rf{$rd} = Bit::Vector->Concat_List(
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 0],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 1],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 2],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 3],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 4]); 
			} elsif ($opcode =~ /^ldrh$/) { #16 bits
				$rf{$rd} = Bit::Vector->Concat_List(
					Bit::Vector->new_Dec(24,0),
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 0],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 1]); 
			} elsif ($opcode =~ /^ldrsh$/) { #16 bits
				my $sign = $dmem_bytevecs[$tmpvec1->to_Dec()+ 0]->msb();
				$rf{$rd} = Bit::Vector->Concat_List(
					Bit::Vector->new_Dec(24,-$sign),
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 0],
					$dmem_bytevecs[$tmpvec1->to_Dec()+ 1]); 
			} elsif ($opcode =~ /^ldrb$/) { #8 bits 
				$rf{$rd} = Bit::Vector->Concat_List( Bit::Vector->new_Dec(32,0), $dmem_bytevecs[$tmpvec1->to_Dec()+ 0]);
			} elsif ($opcode =~ /^ldrsb$/) { #8 bits 
				my $sign = $dmem_bytevecs[$tmpvec1->to_Dec()+ 0]->msb();
				$rf{$rd} = Bit::Vector->Concat_List( Bit::Vector->new_Dec(32,-$sign), $dmem_bytevecs[$tmpvec1->to_Dec()+ 0]);
			} 
			unless ($QUIET) {
			printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s <--- MEMADDR: %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$tmpvec1->to_Hex()); 
			printf $DIFF ("%s= %s\n",$rd,$rf{$rd}->to_Hex());
			}
			#Does not set flags
		}

	}elsif(/$ISA_REGEX::regex_ldnbh/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3); my $opcode = lc($2);
		$rn = "OFFSET"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #NOT TECHNICALLY CORRECT. could allow for immediates larger than allowed in 13 bits

		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		my $newnum; #break out each part of $rm and $rn into byte size chunks
		$rd =~ /r(\d\d?)/; $newnum = 1 + $1; $rd2 = "r". $newnum; 

		
		$tmpvec1->add($rf{$rm},$thirdarg,0); #value of tempvec1 is now the data address to load from 
		my $addr = $tmpvec1->to_Dec();
		my $grid_base;
		#do some checking with the constants to see which VGAFB we are in
		if( $addr > ISA_TOOLS::VGAFB1BASE && $addr < ISA_TOOLS::VGAFB2BASE) {
			$grid_base = ISA_TOOLS::VGAFB1BASE;
		} elsif ( $addr > ISA_TOOLS::VGAFB2BASE ) {
			$grid_base = ISA_TOOLS::VGAFB2BASE;
		}

		my ($A,$B,$C,$D,$E,$F,$G,$H,$I);
		my ($Aadr,$Badr,$Cadr,$Dadr,$Eadr,$Fadr,$Gadr,$Hadr,$Iadr);

		$Aadr = $addr - ISA_TOOLS::WIDTH - 1; 	
		$Badr = $addr - ISA_TOOLS::WIDTH;    	
		$Cadr = $addr - ISA_TOOLS::WIDTH + 1;	
		$Dadr = $addr - 1;
		$Eadr = $addr; #center of neighborhood
		$Fadr = $addr + 1;
		$Gadr = $addr + ISA_TOOLS::WIDTH - 1;	
		$Hadr = $addr + ISA_TOOLS::WIDTH;
		$Iadr = $addr + ISA_TOOLS::WIDTH + 1;

		#attempt to load bytes with appropriate values
		#bytes that are actually on the matrix get loaded here,or if a byte is
		#off the matrix, then it will be null for now, until it gets zeroed out in the next section
		$A = $dmem_bytevecs[$Aadr] if defined($dmem_bytevecs[$Aadr]);
		$B = $dmem_bytevecs[$Badr] if defined($dmem_bytevecs[$Badr]);
		$C = $dmem_bytevecs[$Cadr] if defined($dmem_bytevecs[$Cadr]);
		$D = $dmem_bytevecs[$Dadr] if defined($dmem_bytevecs[$Dadr]);
		$E = $dmem_bytevecs[$Eadr] if defined($dmem_bytevecs[$Eadr]);
		$F = $dmem_bytevecs[$Fadr] if defined($dmem_bytevecs[$Fadr]);
		$G = $dmem_bytevecs[$Gadr] if defined($dmem_bytevecs[$Gadr]);
		$H = $dmem_bytevecs[$Hadr] if defined($dmem_bytevecs[$Hadr]);
		$I = $dmem_bytevecs[$Iadr] if defined($dmem_bytevecs[$Iadr]); 

		#handle special cases for neighborhoods on the edge of the Matrix.
		#bytes off the grid get initialized to $off_grid_byte
		my $off_grid_byte = 0;
		if ($addr % ISA_TOOLS::WIDTH == 0) {
			#A, D, G are off the grid 
			$A = Bit::Vector->new_Dec(8,$off_grid_byte);
			$D = Bit::Vector->new_Dec(8,$off_grid_byte);
			$G = Bit::Vector->new_Dec(8,$off_grid_byte); 
		}
		if ($addr % ISA_TOOLS::WIDTH == ISA_TOOLS::WIDTH - 1) {
			#C, F, I are off the grid	
			$C = Bit::Vector->new_Dec(8,$off_grid_byte);
			$F = Bit::Vector->new_Dec(8,$off_grid_byte);
			$I = Bit::Vector->new_Dec(8,$off_grid_byte); 
		}
		if ($addr - $grid_base < ISA_TOOLS::WIDTH) {
			#on the very top, A, B, C are off the grid
			$A = Bit::Vector->new_Dec(8,$off_grid_byte);
			$B = Bit::Vector->new_Dec(8,$off_grid_byte);
			$C = Bit::Vector->new_Dec(8,$off_grid_byte); 

		}
		if ($addr - $grid_base >= (ISA_TOOLS::HEIGHT * ISA_TOOLS::WIDTH) - ISA_TOOLS::WIDTH) {
			#on the very bottom, G, H, I are off the grid
			$G = Bit::Vector->new_Dec(8,$off_grid_byte);
			$H = Bit::Vector->new_Dec(8,$off_grid_byte);
			$I = Bit::Vector->new_Dec(8,$off_grid_byte); 
		}

		$rf{$rd} = Bit::Vector->Concat_List(Bit::Vector->new_Dec(8,0),$A,$B,$C,$F);
		$rf{$rd2} = Bit::Vector->Concat_List($E,$D,$G,$H,$I); 

		unless ($QUIET) {

		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RD+1: %s = %s <--- Neighborhood at MEMADDR: %x\n",
		 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$rd2,$rf{$rd2}->to_Hex(),$addr); 

		printf $DIFF ("%s= %s\n",$rd,$rf{$rd}->to_Hex());
		printf $DIFF ("%s= %s\n",$rd2,$rf{$rd2}->to_Hex());
		}

		#Does not set flags
	}elsif(/$ISA_REGEX::regex_strnbh/){
		$rd = lc($4); $rm = lc($5); $thirdarg = lc($6); $instr_cc = lc($3); my $opcode = lc($2);
		$rn = "OFFSET"; $thirdarg = Bit::Vector->new_Dec(40,$thirdarg); #NOT TECHNICALLY CORRECT. could allow for immediates larger than allowed in 13 bits


		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	

		my $newnum; #break out each part of $rm and $rn into byte size chunks
		$rd =~ /r(\d\d?)/; $newnum = 1 + $1; $rd2 = "r". $newnum; 
		
		$tmpvec1->add($rf{$rm},$thirdarg,0); #value of tempvec1 is now the data address to load from 
		my $addr = $tmpvec1->to_Dec();

		#do some checking with the constants to see which VGAFB we are in
		my $grid_base = ISA_TOOLS::DMEMBASE;



		my ($A,$B,$C,$D,$E,$F,$G,$H,$I);
		my ($Aadr,$Badr,$Cadr,$Dadr,$Eadr,$Fadr,$Gadr,$Hadr,$Iadr);

		$Aadr = $addr - ISA_TOOLS::WIDTH - 1; 	
		$Badr = $addr - ISA_TOOLS::WIDTH;    	
		$Cadr = $addr - ISA_TOOLS::WIDTH + 1;	
		$Dadr = $addr - 1;
		$Eadr = $addr; #center of neighborhood
		$Fadr = $addr + 1;
		$Gadr = $addr + ISA_TOOLS::WIDTH - 1;	
		$Hadr = $addr + ISA_TOOLS::WIDTH;
		$Iadr = $addr + ISA_TOOLS::WIDTH + 1;

		#split out the bytes from the registers into $A - $F
		$A = Bit::Vector->new(8);
		$A->Interval_Copy($rf{$rd},0,24,8);
		$B = Bit::Vector->new(8);
		$B->Interval_Copy($rf{$rd},0,16,8);
		$C = Bit::Vector->new(8);
		$C->Interval_Copy($rf{$rd},0,8,8);
		$D = Bit::Vector->new(8);
		$D->Interval_Copy($rf{$rd},0,0,8);
		$E = Bit::Vector->new(8);
		$E->Interval_Copy($rf{$rd2},0,32,8);
		$F = Bit::Vector->new(8);
		$F->Interval_Copy($rf{$rd2},0,24,8);
		$G = Bit::Vector->new(8);
		$G->Interval_Copy($rf{$rd2},0,16,8);
		$H = Bit::Vector->new(8);
		$H->Interval_Copy($rf{$rd2},0,8,8);
		$I = Bit::Vector->new(8);
		$I->Interval_Copy($rf{$rd2},0,0,8);

		#handle special cases for neighborhoods on the edge of the Matrix.
		#bytes off the grid get addresses set to -1 to indicate not to store them
		#If ld and strnbh are being used properly this will only happen on the edges
		my $off_grid_byte = 0;
		if ($addr % ISA_TOOLS::WIDTH == 0) {
			#A, D, G are off the grid 
			$Aadr = -1; $Dadr = -1; $Gadr = -1;
		}
		if ($addr % ISA_TOOLS::WIDTH == ISA_TOOLS::WIDTH - 1) {
			#C, F, I are off the grid	
			$Cadr = -1; $Fadr = -1; $Iadr = -1;
		}
		if ($addr - $grid_base < ISA_TOOLS::WIDTH) {
			#on the very top, A, B, C are off the grid
			$Aadr = -1; $Badr = -1; $Cadr = -1; 
		}
		if ($addr - $grid_base >= (ISA_TOOLS::HEIGHT * ISA_TOOLS::WIDTH) - ISA_TOOLS::WIDTH) {
			#on the very bottom, G, H, I are off the grid
			$Gadr = -1; $Hadr = -1; $Iadr = -1;
		}
		$dmem_bytevecs[$Aadr] = $A->Clone() unless $Aadr == -1;
		$dmem_bytevecs[$Badr] = $B->Clone() unless $Badr == -1;
		$dmem_bytevecs[$Cadr] = $C->Clone() unless $Cadr == -1;
		$dmem_bytevecs[$Dadr] = $D->Clone() unless $Dadr == -1;
		$dmem_bytevecs[$Eadr] = $E->Clone() unless $Eadr == -1;
		$dmem_bytevecs[$Fadr] = $F->Clone() unless $Fadr == -1;
		$dmem_bytevecs[$Gadr] = $G->Clone() unless $Gadr == -1;
		$dmem_bytevecs[$Hadr] = $H->Clone() unless $Hadr == -1;
		$dmem_bytevecs[$Iadr] = $I->Clone() unless $Iadr == -1;

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s RD:%-4s = %s, RD+1: %s = %s ---> Neighborhood at MEMADDR: %x\n",
		 $rf{"r31"}->to_Hex(),$label,$_,$rd,$rf{$rd}->to_Hex(),$rd2,$rf{$rd2}->to_Hex(),$addr); 
		printf $DIFF ("STORENEIGHBOR %s= %s and %s= %s -> %x\n",$rd,$rf{$rd}->to_Hex(),$rd2,$rf{$rd2}->to_Hex(),$addr);
		}

		#Does not set flags
	}elsif(/$ISA_REGEX::regex_return/){
		$firstarg = lc($4);  $instr_cc = lc($3);  #for B vs BL 

		######################
		#special FB dump case
		######################
		if ($firstarg == 2) {
			&fbdump;
			next;
		} 
		######################
		#special FB dump case
		######################

		if (!&checkCC($instr_cc)) { printf $tee  ("PC:%s %-12s INSTR:%-20s CONDITIONAL NOOP\n",$rf{"r31"}->to_Hex(),$label,$_) unless $QUIET; next; }	
	
		$rf{"r31"} = $rf{"r30"}->Clone(); #setting the PC	

		unless ($QUIET) {
		printf $tee  ("PC:%s %-12s INSTR:%-20s New PC: %s RDorLITERALPCOFFSET: %s = %s\n",
			 $rf{"r31"}->to_Hex(),$label,$_,$rf{"r31"}->to_Hex(),$rd,$rf{$rd}->to_Hex());
	 	}

		#Does not set flags
	}elsif(/$ISA_REGEX::regex_halt/){ 
		print $tee  "HALT\n" unless $QUIET; &dump; last; 
	} else {
		#WUT?  
	}
} #while 1


#########END OF MAIN PROGRAM##############


#############################################
# extra subs
#############################################
sub dump{
	print "Dumping RF and DMEM, as well as this simulation trace to $fname\n";
	print $DUMP "BEGIN REGISTER FILE DUMP\n";
	for (my $i = 0; $i < 32; $i++){
		my $k = "r".$i;
		printf $DUMP ("%-5s 0x%-12s 0b%-45s %15s\n",$k,$rf{$k}->to_Hex(),$rf{$k}->to_Bin(),$rf{$k}->to_Dec()); 
	} 
	my %inverse_dsymtable = reverse %dsymtable;
	print $DUMP "BEGIN DMEM DUMP\n";
	print $DUMP "Byte Addressable, Omitting null entries in the dmem_array (not the same as omitting 0x00)\n";
	for (my $i = 0; $i < scalar(@dmem_bytevecs); $i++){
	
		if (defined($dmem_bytevecs[$i])) {	
			$tmpvec1 = $dmem_bytevecs[$i]->Clone();
		}else { next; }#skip undefined mem locations, so that it doesnt clog up the logfile

		printf $DUMP ("ADDR:0x%x LABEL:%s\n",$i,$inverse_dsymtable{$i}) if defined($inverse_dsymtable{$i}); #was there a label at this address?
		printf $DUMP ("ADDR:0x%x 0x%-12s 0b%-45s \n",$i,$tmpvec1->to_Hex(),$tmpvec1->to_Bin()); 
	}

	&fbdump;
	$tee->close() or warn "did not close TEE properly\n";

	#`rm -fv ./dump/LATEST.dump`;
	#`cp $fname ./dump/LATEST.dump`;
	#unlink './dump/LATEST.dump';
	#`cp $fname ./dump/LATEST.dump`;
	#symlink($fname,'./dump/LATEST.dump');	

	print "Done.\n";
}


sub fbdump {
	use encoding "ascii";
	if (ISA_TOOLS::WIDTH < 20){
		print $DUMP "BEGIN VGA DISPLAY DUMP. ONLY USEFUL FOR SMALL NBH SIZES\n";
		print $DUMP "FB1\n";
		for (my $i = 0; $i < ISA_TOOLS::HEIGHT*ISA_TOOLS::WIDTH; $i += ISA_TOOLS::WIDTH) {
		for (my $j = 0; $j < ISA_TOOLS::WIDTH; $j++) { 
			#my $val = defined($dmem_bytevecs[$i+$j]) ?: "00"; 
			print $DUMP $dmem_bytevecs[ISA_TOOLS::DMEMBASE + $i+$j]->to_Hex()." ";

		}	
			print $DUMP "\n";
		} 
		print $DUMP "FB2\n";
		for (my $i = ISA_TOOLS::VGAFB2BASE; $i < ISA_TOOLS::VGAFB2BASE + ISA_TOOLS::HEIGHT*ISA_TOOLS::WIDTH; $i += ISA_TOOLS::WIDTH) {
		for (my $j = 0; $j < ISA_TOOLS::WIDTH; $j++) { 
			#my $val = defined($dmem_bytevecs[$i+$j]) ?: "00"; 
			print $DUMP $dmem_bytevecs[ISA_TOOLS::DMEMBASE + $i+$j]->to_Hex()." ";

		}	print $DUMP "\n"; }
	} else {
		#print to separatefile
		print "Dumping Frame Buffers. Generation $fbdump_count\n";
		open(my $FB1, '>',"$outdir/FB1_RAWIMG" . "$fbdump_count".".raw") or die "could not open FB1_RAWIMG";
		open(my $FB2, '>',"$outdir/FB2_RAWIMG" . "$fbdump_count".".raw") or die "could not open FB2_RAWIMG";
		for (my $i = 0; $i < ISA_TOOLS::VGAFB2BASE; $i++) {
			print $FB1 pack("C",$dmem_bytevecs[$i]->to_Dec());
			print $FB2 pack( "C",$dmem_bytevecs[ISA_TOOLS::VGAFB2BASE + $i]->to_Dec());
		} 
		close($FB1); close($FB2);

		open(my $FB1H, '>',"$outdir/FB1_HEXIMG" . "$fbdump_count".".hex") or die "could not open FB1_HEXIMG";
		open(my $FB2H, '>',"$outdir/FB2_HEXIMG" . "$fbdump_count".".hex") or die "could not open FB2_HEXIMG";
		for (my $i = 0; $i < ISA_TOOLS::HEIGHT*ISA_TOOLS::WIDTH; $i += ISA_TOOLS::WIDTH) {
		for (my $j = 0; $j < ISA_TOOLS::WIDTH; $j++) { 
			#my $val = defined($dmem_bytevecs[$i+$j]) ?: "00"; 
			print $FB1H $dmem_bytevecs[ISA_TOOLS::DMEMBASE + $i+$j]->to_Hex()." ";
			print $FB2H $dmem_bytevecs[ISA_TOOLS::DMEMBASE + ISA_TOOLS::VGAFB2BASE + $i + $j]->to_Hex()." ";

		}	
			print $FB1H "\n";
			print $FB2H "\n";
		}	
		close($FB1H); close($FB2H); 
	}
	#increment the dump number for next time
	$fbdump_count++;
	no encoding;
}

#set the CC based on the result of the intstruction passed in
sub setCC {
	(my $result_vec,my $carry_bit, my $overflow_bit) = @_;

	# set Z
	if ($result_vec->Compare($zerovec) ==  0) { $CC{"Z"} = 1; }
	else { $CC{"Z"} = 0; }

	#set N
	if ($result_vec->Compare($zerovec) == -1) { $CC{"N"} = 1; }
	else { $CC{"N"} = 0; }	

	#set V
	$CC{"V"} = $overflow_bit; 
	#set C
	$CC{"C"} = $carry_bit; 
}

#return true if the instruction should execute based on %CC
sub checkCC{
	my $instr_cc = $_[0]; #the CC of the instruction
	#check all the codes
	if (!$instr_cc){ return 1}; #by default always execute

	if ($instr_cc eq "_eq") {
		return 1 if $CC{"Z"} == 1; 
	}elsif ($instr_cc eq "_ne") {
		return 1 if $CC{"Z"} == 0; 
	}elsif ($instr_cc eq "_cs" or $instr_cc eq "_hs") {
		return 1 if $CC{"C"} == 1; 
	} elsif ($instr_cc eq "_cc" or $instr_cc eq "_LO") {
		return 1 if $CC{"C"} == 0; 
	} elsif ($instr_cc eq "_mi") {
		return 1 if $CC{"N"} == 1; 
	} elsif ($instr_cc eq "_pl") {
		return 1 if $CC{"N"} == 0; 
	} elsif ($instr_cc eq "_vs") {
		return 1 if $CC{"V"} == 1; 
	} elsif ($instr_cc eq "_vc") {
		return 1 if $CC{"V"} == 0; 
	} elsif ($instr_cc eq "_hi") {
		return 1 if $CC{"C"} == 1 and $CC{"Z"} == 0; 
	} elsif ($instr_cc eq "_ls") {
		return 1 if $CC{"C"} == 0 or $CC{"Z"} == 1; 
	} elsif ($instr_cc eq "_ge") {
		return 1 if $CC{"V"} == $CC{"N"};
	} elsif ($instr_cc eq "_lt") {
		return 1 if $CC{"V"} != $CC{"N"}; 
	} elsif ($instr_cc eq "_gt") {
		return 1 if $CC{"N"} == $CC{"V"} and $CC{"Z"} == 0; 
	} elsif ($instr_cc eq "_le") {
		return 1 if $CC{"N"} != $CC{"V"} or $CC{"Z"} == 1; 
	}else {
		return 0;#do not execute this instr
	} 
} 
 
