/*
Module:			memctl

Description:		provides 2 simple interfaces to DRAM to VGA controller and cache.
			VGA gets priority for 1 buffered access at a time.

Hierarchy:		SYSTEM=>memctl


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		
Module interface by:	Eric Weisman, 021711

Date:			

*/

module memctl(
	input clk, input rst,
/*
	
*/	
	//cpu end
	input 		MemEnable,		//memory is generally active
	input 		RW,			//read or write from cpu
	input[31:0]	CpuAddr,
	inout[71:0]	CpuData,
	output		MemReadyCpu,		//memory ready to be accessed by cache
	//VGA end
	input		VgaRq,			//vga wants priority access - provisional signal
	input[31:0]	VgaAddr,
	output[71:0]	VgaData,
	output		MemReadyVga,		//memory ready to buffer a vga read
	
	//DRAM end
	inout[71:0]	MemData,
	output[1:0]	mode,			//byte(8b), halfword(16b), word(40b), neighborhood(discontiguous 72b)
	output		RW			//write when low
	//provisionally always enabled
);

	//PARAMETERS-------------------------------------------------------------------------
	'include "brammodes.inc"

	//INTERNAL ROUTING-------------------------------------------------------------------
	

	
	//OTHER STUFF------------------------------------------------------------------------

endmodule;
