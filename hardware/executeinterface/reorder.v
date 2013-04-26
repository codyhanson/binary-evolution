/*
Module: reorder		

Description: Module reorders data on the bus to be used in the multi-cycle execute logic. 
It simply reverses the order of the 5 bytes.  		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/


module reorder(input [39:0] dataInReorder,
			  input controlInReorderEnable,
			  output reg[39:0] dataOutReorder);
			  
			  always @(*) begin
			  		if(controlInReorderEnable) begin
			  			dataOutReorder[7:0] = dataInReorder[39:32];
			  			dataOutReorder[15:8] = dataInReorder[31:24];
			  			dataOutReorder[23:16] = dataInReorder[23:16];
			  			dataOutReorder[31:24] = dataInReorder[15:8];
			  			dataOutReorder[39:32] = dataInReorder[7:0];
			  		end
			  		else dataOutReorder = dataInReorder;
			  	end
			 
	

endmodule