/*
Module: neighborOpController

Description: Module is responsible for stall logic for the AccumBytes instruction.  Module outputs a 4 cycle stall signal and counter. 
The stall signal will be used to hold the pipeline and the counter is used by the alu to select the correct data for each cycle.		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/

module neighborOpController(input clk, 
			  input rst,
			  input [4:0] controlInExControllerOpA,
			  input [4:0] controlInExControllerOpB,
			  input flush, input stall,
			  output controlOutExControllerStall,
			  output [4:0] controlOutExControllerOpA,
			  output [4:0] controlOutExControllerOpB,
			  output reg[2:0] controlOutExControllerCycleCnt);
			  
			  always@(posedge clk)begin
			  		if(rst)begin
			  		
						
						controlOutExControllerCycleCnt <= 0;
						
					end
				   else if(~flush && ~stall && controlInExControllerOpA == 5'b01000  && controlOutExControllerCycleCnt < 3) controlOutExControllerCycleCnt <= controlOutExControllerCycleCnt + 1;
					else if(~stall && controlOutExControllerCycleCnt >= 3) controlOutExControllerCycleCnt<=0;
					else if(~flush && ~stall && controlInExControllerOpA != 5'b01000 && controlOutExControllerCycleCnt > 0 && controlOutExControllerCycleCnt <5) controlOutExControllerCycleCnt <= controlOutExControllerCycleCnt + 1;
					else controlOutExControllerCycleCnt <= controlOutExControllerCycleCnt;
				end
				
				
				assign controlOutExControllerOpA = (controlOutExControllerCycleCnt > 0 && controlOutExControllerCycleCnt <4) ? 5'b01000 :controlInExControllerOpA; 
				assign controlOutExControllerOpB = (controlOutExControllerCycleCnt > 0 && controlOutExControllerCycleCnt <4) ? 5'b01000 :controlInExControllerOpB;
				assign controlOutExControllerStall = (controlInExControllerOpB == 5'b01000 |controlOutExControllerCycleCnt > 0 && ((controlOutExControllerCycleCnt <3)||(controlOutExControllerCycleCnt==3 && stall))) ? 1 : 0;
						
					
			  			

	

endmodule