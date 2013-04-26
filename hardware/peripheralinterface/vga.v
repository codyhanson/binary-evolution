/*
Module:			vga

Description:		reads memory directly at intervals and outputs via DACs to the screen.

Hierarchy:		SYSTEM=>vga


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		
Module interface by:	Eric Weisman, 021711

Date:			

*/

module vga(
	input clk, input rst, 
	//memory end
	input		MemReady,		//memory ready to be accessed
	input[71:0]	Data,			//block of color values read from memory - 3 sets of values
	output[31:0]	Addr,			//address of left pixel red
	output		VgaRq,			//priority request an access from memory
	//output end
	output[7:0]	R, G, B		//output to DAC pins -- how?
	);

	//ideas- schedule vga accesses? via arbitration module?  give vga request priority?
	//use DRAM burst mode (too hard)?  vgarq is redundant? 

endmodule;