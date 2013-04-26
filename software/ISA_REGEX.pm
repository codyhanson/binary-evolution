#! /usr/bin/perl
# Perl module for the Binary Evolution ISA asm and sim
# Cody Hanson 3/8/2011
package ISA_REGEX;

########################################################################################
#REGEXES, used by ISA_TOOLS.pm as well as sim.pl and asm.pl
#not going anywhere for awhile? try and read a regex. or grab a snickers
########################################################################################
our $regex_add = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(add)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_bic = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(bic)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_and = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(and)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_or = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(or)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_rsb = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(rsb)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_sub = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(sub)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #third arg, rn, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_swp = 		
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(swp)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d) #third arg, rn
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment


our $regex_cmp = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(cmp)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #second arg, rm, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_not = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(not)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d) #second arg, rm
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_teq = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(teq)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #second arg, rm, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_tst = 
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(tst)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+) #second arg, rm, hex literal, or decimal literal
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment


#$4 arg1, $5 whole second arg (use for literal)
#$6 rm
#$7 rn
#$8 shift type
our $regex_mov =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(mov)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*((?:(r\d|r[12]\d|r3[01])\s*,\s*(r\d|r[12]\d|r3[01])\s+(lsl|lsr|asr))|0x[0-9a-f]+|-?\d+) #second arg, rm with shift param,or  hex literal, or decimal literal 
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment


our $regex_bwcmpl =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(bwcmpl)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d) #second arg, rm
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_mxsub=
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(mxsub)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d) #third arg, rn
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_mxadd=
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(mxadd)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d) #third arg, rn
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_accumbytes=
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(accumbytes)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d) #third arg, rn
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_mxmul=
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(mxmul)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register
	\s*(r3[01]|r[12]\d|r\d) #third arg, rn
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment 

our $regex_str =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(str[bh]?)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(|r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register, this holds the address
	\s*(0x[0-9a-f]+|-?\d+) # hex literal, or decimal literal, offset
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_ld = #matches loads for different widths and signed and unsigned
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(ldrs?[bh]?)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(|r30|r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r3[01]|r[12]\d|r\d)\s*, #rm,any register, this holds the address
	\s*(0x[0-9a-f]+|-?\d+) # hex literal, or decimal literal, offset
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment 

our $regex_ldnbh =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(ldneighbor)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r[12]\d|r\d)\s*, #rd, any register except r31
	\s*(r\d|r[12]\d|r3[01])\s*, #rm,any register, this holds the address
	\s*(0x[0-9a-f]+|-?\d+) # hex literal, or decimal literal, offset
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_strnbh =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(strneighbor)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r[12]\d|r\d)\s*, #rd, any register except r31,R30
	\s*(r\d|r[12]\d|r3[01])\s*, #rm,any register, this holds the address
	\s*(0x[0-9a-f]+|-?\d+) # hex literal, or decimal literal, offset
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment



our $regex_return =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(return)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(1|0|2) #reenable interrupts on return?, the '2' is a special simulator case for dumping framebuffers
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_halt = qr/^(?:(\w+):)?\s+halt\s*(?:\/\/.*)?/ix;

#all the non pseudo op regexes,non directive regexes,
# check the pseudo op ones separately
our @regexes = ($regex_add ,$regex_bic, $regex_and, $regex_or, $regex_rsb,
		$regex_sub, $regex_swp, $regex_cmp, $regex_not, $regex_teq,$regex_tst,
		$regex_mov, $regex_bwcmpl, $regex_mxsub,$regex_mxmul,$regex_mxadd,
		$regex_accumbytes, $regex_return,$regex_ld,$regex_str, 
		$regex_ldnbh,$regex_strnbh, $regex_halt);

#these regexes are not in the huge @regexes array.
our $regex_region = qr/^\.region\s+(code|isr|ex)/i;

our $regex_ldadr =
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(ldadr)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r\d|r[12]\d|r30)\s*, #rd, any register except r31
	\s*<(\w+)> # label string is in dollar 4
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment

our $regex_blank_or_comment = qr#(^\s*//)|(^\s*$)#; 
our $regex_EQU = qr#^\.EQU\s+(\w+)\s+(\w+)\s*(//.*)?($)#;

our $regex_branch = 	
	qr/^(?:(\w+):)?\s+ #optional label and non optional whitespace
	(bl?)(_[a-zA-Z]{2})?\s+ #valid opcodes and optional conditional
	(r3[01]|r[12]\d|r\d|0x[0-9a-f]+|-?\d+|\<\w+\>) #for branch either literal offset,LABEL 
	#pseudo op, or register value. can't specify r31
	\s*(?:\/\/.*)?/ix; #optional whitespace and comment


1;
