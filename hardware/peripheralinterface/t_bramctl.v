/*
Module:			t_bramctl

Description:		tests 1cycle rw to bram
Hierarchy:		t_bramctl=>bramctl


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	Eric Weisman
Edited by:		
Module interface by:	Eric Weisman

Date:			

*/

module t_bramctl;

	reg clk, fastclk, rst;
	//clocks blocks
	always begin
		#10 fastclk=~fastclk;
	end
	always begin
		#20 clk=~clk;
	end
	
	reg[15:0]	arraywidth;
	reg[39:0]	memaddr0, memaddr1;
	reg[39:0]	memdata0, memdata1;
	wire[39:0]	memresult0, memresult1;
	reg[1:0] 	mode0, mode1;
	reg 		RW0, RW1;
	
	bramctl uut(
		.clk(clk),
		.rst(rst), 
		.fastclk(fastclk), 
		.arraywidth(arraywidth), 

		.MemAddr0(memaddr0), 
		.MemDataIn0(memdata0), 
		.MemDataOut0(memresult0), 
		.mode0(mode0), 
		.RW0(RW0),

		.MemAddr1(memaddr1), 
		.MemDataIn1(memdata1), 
		.MemDataOut1(memresult1), 
		.mode1(mode1), 
		.RW1(RW1)
	);
	

	`include "I:/Desktop/ece554/projectsvnwin/hardware/peripheralinterface/brammodes.inc"

	initial begin
		clk=1'b0;
		fastclk=1'b1;
		rst=1'b1;
		#15;
		arraywidth=16'd64;
		memaddr0=40'b0;
		memaddr1=40'b0;
		memdata0=40'hdeadbeef23;
		memdata1=40'hfeedface45;
		mode0=BYTE;
		mode1=WORD;	//perhaps start easier?
		RW0=1'b0;	//writing
		RW1=1'b1;	//harmless read
		
		#30 rst=1'b0;

		
		//SIMPLE OPS
		
		//write a byte
		#25;
		//read halfword of that location
		mode0=HALF;
		RW0=1'b1;
		#40;
		
		//write halfword next aligned
		memaddr0=40'd5;
		RW0=1'b0;
		#40;
		//read word of that location
		mode0=WORD;
		RW0=1'b1;
		#40;
		
		//read unaligned overlapping word
		// result should be 40'hf0xxxf0
		memaddr0=40'd3;
		#40;


		//SPECIAL WORDOPS TEST #260 definitely
		//write word a location
		memaddr0=40'd8;
		RW0=1'b0;
		#40;
		//read word of that location
		RW0=1'b1;
		#40;

		
		
		//NEIGHBORHOOD OPS #340
		
		//read neighborhood of a location
		//for self initializing memory
		arraywidth=40'd6;
		memaddr0=40'd80 + arraywidth + 40'd1;
		mode0=NEIG;
		RW0=1'b1;
		#40;	

		//write neighborhood beginning aligned
		RW0=1'b0;
		#40;
		
		//read neighborhood of that location
		RW0=1'b1;
		#40;		
		
		//read first word of neighborhood
		mode0=WORD;
		memaddr0=memaddr0-arraywidth-1'b1;
		#40;
		//read middle word of neighborhood
		memaddr0=memaddr0 + arraywidth;
		#40;
		//read last word of neighborhood
		memaddr0=memaddr0 + arraywidth;
		#40;
		
		
		#40 $stop;
		
	end

endmodule
