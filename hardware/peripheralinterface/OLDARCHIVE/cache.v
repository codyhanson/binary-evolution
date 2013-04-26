/*
Module:			cache

Description:		Cache module for all communication cpu <==> datamem

Hierarchy:		SYSTEM=>periphsyswrapper=>cache


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		
Module interface by:	Eric Weisman, 021711

Date:			

*/

module cache(
	input clk, input rst, 
	//cpu end
	input		CacheEnable,		//Cache is active
	input		CpuRW0, CpuRW1,		//whether to Read(1) or Write(0) the cache
	input[1:0]	mode0, mode1,		//cache pattern mode for each address
	input[31:0]	CpuAddr0, CpuAddr1,	//address from cpu
	inout[39:0]	CpuData0, CpuData1,	//data bus from cpu
	//memory end
	input		MemReady,		//memory is ready to be accessed
	inout[72:0]	MemData,		//data bus from memory
	output[31:0]	MemAddr			//address to memory
	output		MemRW0, MemRW1,		//whether to Read(1) or Write(0) the memory
	);

	

endmodule;