/*
Module:			mmrcachemuxes

Description:		combinationally enables MMRs or the memory system depending on address

Hierarchy:		SYSTEM=>periphsyswrapper=>mmrcachemuxes

Notes:		does no direct bus control

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	Eric Weisman, 022711
Edited by:		
Module interface by:	Eric Weisman, 021711

Date:			

*/

module mmrcachemuxes(
	//cpu end
	input 		Enable0, Enable1, 
	input[31:0] 	CpuAddr0, CpuAddr1, 
	output		rda0, rda1,
	//mmrs end
	output[7:0] 	AddrMmr0, AddrMmr1, 
	output 		EnableMmr0, EnableMmr1, 
	//memory end
	output		EnableCache0, EnableCache1
	);


	assign EnableMmr0= (&CpuAddr0[31:19]) && Enable0;
	assign EnableCache0= (~(&CpuAddr0[31:19])) && Enable0;

	assign AddrMmr0=CpuAddr0[7:0];
	assign rda0=ASDFJJASBHLDFKJSADHILFJ


	assign EnableMmr1= (&CpuAddr1[31:19]) && Enable1;
	assign EnableCache1= (~(&CpuAddr1[31:19])) && Enable1;

	assign AddrMmr1=CpuAddr1[7:0];

endmodule;
