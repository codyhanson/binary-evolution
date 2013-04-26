/*
Module:			periphsyswrapper

Description:		wrapper for memory mapped peripheral interface

Hierarchy:		SYSTEM=>periphsyswrapper


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	Eric Weisman, 022711
Edited by:		Eric Harris 032111
Module interface by:	Eric Weisman, 021711

Date:			

*/

module periphsyswrapper(
	input clk, input rst, 
	//from CPU
   input cpuRdEn0,cpuRdEn1,cpuWrEn0,cpuWrEn1,
	input[39:0]	cpuAddr0, cpuAddr1,	//address from cpu
	inout[39:0]	cpuData, cpuData,	//data to/from the pipe
	//Below Interv
	inout[63:0]	MemData,		//data bus from memory
	output[31:0]	MemAddr			//address to memory
	output		MemRW0, MemRW1,		//whether to Read(1) or Write(0) the memory
	//else
	input		VgaBusy,		//VGA controller is accessing memory
	output[31:0]	VgaAddrBase			//current vga offset
	);


	//mmr system



endmodule