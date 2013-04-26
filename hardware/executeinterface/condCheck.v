/*
Module: condCheck.v

Description: Module checks to see if the flag meets the condition.  If condition is met, then output is 1 else 0		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/

module condCheck(input [3:0] controlInCond,
                 input dataInZ,
                 input dataInC,
                 input dataInV,
                 input dataInN,
                 output reg dataOutCondMet);

      always@(*)begin
          case(controlInCond)
			        4'b0000: begin
			               if(dataInZ)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0001: begin
			             if(~dataInZ)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0010: begin
			            if(dataInC)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0011: begin
			            if(~dataInC)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0100:begin
			            if(dataInN)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0101: begin
			            if(~dataInN)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0110: begin
			            if(dataInV)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b0111: begin
			            if(~dataInV)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1000: begin
			            if(~dataInZ && dataInC)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1001: begin
			            if(dataInZ || ~dataInC)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1010: begin
			            if(dataInN == dataInV)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1011:begin
			            if(dataInN != dataInV)dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1100: begin
			            if(~dataInZ && (dataInN == dataInV) )dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			        4'b1101:begin
			            if(dataInZ || (dataInN != dataInV) )dataOutCondMet = 1;
			               else dataOutCondMet = 0;
			            end
			   		 4'b1110: begin
			            dataOutCondMet = 0;
			            end
			        4'b1111: begin
			            dataOutCondMet = 1;
			            end
			     endcase  
			end       



                 
endmodule
                 

