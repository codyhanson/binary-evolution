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

module t_bramneigs;

	reg clk, fastclk, rst;
	//clocks blocks
	always begin
		#10 fastclk=~fastclk;
	end
	always begin
		#20 clk=~clk;
	end
	
	reg[15:0]	arraywidth;
	reg[39:0]	memaddr;
	reg[39:0]	memdata0, memdata1;
	wire[39:0]	memresult0, memresult1;
	reg[1:0] 	mode0, mode1;
	reg 		RW0;
	

	wire[39:0] memaddr1=memaddr+39'b100000;	//ignored in operation
	bramctl uut(
		.clk(clk),
		.rst(rst), 
		.fastclk(fastclk), 
		.arraywidth(arraywidth), 

		.MemAddr0(memaddr), 
		.MemDataIn0(memdata0), 
		.MemDataOut0(memresult0), 
		.mode0(mode0), 
		.RW0(RW0),

		.MemAddr1(memaddr1), 
		.MemDataIn1(memdata1), 
		.MemDataOut1(memresult1), 
		.mode1(mode1), 
		.RW1(1'b1)	//read only
	);
	

	`include "I:/Desktop/ece554/projectsvnwin/hardware/peripheralinterface/brammodes.inc"

	integer i;	//loop index
	always begin

	end
	initial begin
		clk=1'b0;
		fastclk=1'b1;
		rst=1'b1;
		#15;
		arraywidth=16'd3;
		memaddr=40'd40;
		memdata0=40'hdeadbeef23;
		memdata1=40'hfeedface45;
		mode0=NEIG;
		mode1=WORD;	//ignored
		RW0=1'b0;	//writing
		
		#30 rst=1'b0;
		
		for(i=0; i<6; i=i+1) begin
			//write neig a location
			RW0=1'b0;
			#40;
			//read neig of that location
			RW0=1'b1;
			mode0=BYTE;	//NOP
			#40;
			mode0=NEIG;
			#40;
			mode0=BYTE;	//NOP
			#40;
			mode0=NEIG;
			memaddr=memaddr+40'b1;
			arraywidth=arraywidth+16'd1;
		end

		
		
		
		
		$stop;
		
	end

endmodule

