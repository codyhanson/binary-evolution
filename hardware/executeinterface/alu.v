/*
Module: alu			

Description: Module is an alu.  		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/


module alu(input [39:0] dataInALUa,
			  input [39:0] dataInALUb,
			  input[4:0] controlInALUop,
			  input [1:0] controlInALUshiftDir, 
			  input[2:0] controlInALUCycleCnt,
			  output [39:0] dataOutALU,
			  output controlOutAluZ, 
			  output controlOutAluC,
			  output reg controlOutAluV,
			  output controlOutAluN);
			  
`include "opcodes.inc"		 


			 wire [40:0] dataInALUa_int, dataInALUb_int;
			 assign dataInALUa_int = {dataInALUa[39],dataInALUa};
			 assign dataInALUb_int = {dataInALUb[39],dataInALUb};
			 
          reg [40:0]localResult;
          wire add_sub;
			  always@(*)begin
			     localResult = {1'b0,40'bx};
			     case(controlInALUop)
			         ADD: localResult = dataInALUa_int + dataInALUb_int;     
			         AND: localResult = dataInALUa_int & dataInALUb_int;
			         BIC: localResult = dataInALUa_int & (~dataInALUb_int);
					   OR:  localResult = dataInALUa_int | dataInALUb_int;
			         RSB: localResult = dataInALUb_int - dataInALUa_int;
			         SUB: localResult = dataInALUa_int - dataInALUb_int;
			         SWP: localResult = dataInALUb_int;
			         ACCUMBYTES: begin 
			         					case(controlInALUCycleCnt) //Logic to determine what data to add
			         						3'd0: begin
			         						localResult[8:0] = dataInALUa_int[7:0] +  dataInALUb_int[7:0];
			         						localResult[17:9] = dataInALUa_int[15:8] +  dataInALUb_int[15:8];
			         						localResult[26:18] = dataInALUa_int[23:16] +  dataInALUb_int[23:16];
			         						localResult[39:27] = 0;
			      			         	end			         						
			         						3'd1: begin
			         						localResult[9:0] = dataInALUa_int[8:0] +  dataInALUb_int[8:0];
			         						localResult[19:10] = dataInALUa_int[17:9] +  dataInALUb_int[17:9];
			         						localResult[28:20] = dataInALUa_int[26:18];
			         						localResult[39:29] = 0;
			         						end
			         						3'd2:begin
			         						localResult[10:0] = dataInALUa_int[9:0] +  dataInALUa_int[19:10];
			         						localResult[19:11] = dataInALUa_int[28:20];
			         						localResult[39:20] = 0;
			         						end 
			         						3'd3:begin
			         						localResult[39:0] = dataInALUa_int[10:0] + dataInALUa_int[19:11];
			         						end
			         						
			         						default: localResult = 41'bx;
			         					endcase
			                      
			                      
			                      end
			         MXMUL: begin
			                       localResult[7:0] = dataInALUa_int[7:0] * dataInALUb_int[7:0];
			                       localResult[15:8] = dataInALUa_int[15:8] * dataInALUb_int[15:8];
			                       localResult[23:16] = dataInALUa_int[23:16] * dataInALUb_int[23:16];
			                       localResult[31:24] = dataInALUa_int[31:24] * dataInALUb_int[31:24];
			                       localResult[39:32] = dataInALUa_int[39:32] * dataInALUb_int[39:32];
			                    end
			         MXADD: begin
			                       localResult[7:0] = dataInALUa_int[7:0] + dataInALUb_int[7:0];
			                       localResult[15:8] = dataInALUa_int[15:8] + dataInALUb_int[15:8];
			                       localResult[23:16] = dataInALUa_int[23:16] + dataInALUb_int[23:16];
			                       localResult[31:24] = dataInALUa_int[31:24] + dataInALUb_int[31:24];
			                       localResult[39:32] = dataInALUa_int[39:32] + dataInALUb_int[39:32];
			                    end
			         MXSUB: begin
			                       localResult[7:0] = dataInALUa_int[7:0] - dataInALUb_int[7:0];
			                       localResult[15:8] = dataInALUa_int[15:8] - dataInALUb_int[15:8];
			                       localResult[23:16] = dataInALUa_int[23:16] - dataInALUb_int[23:16];
			                       localResult[31:24] = dataInALUa_int[31:24] - dataInALUb_int[31:24];
			                       localResult[39:32] = dataInALUa_int[39:32] - dataInALUb_int[39:32];
			                    end
			         B:     localResult = dataInALUa_int + dataInALUb_int;
			         BL:    localResult = dataInALUa_int + dataInALUb_int;
			         CMP:   localResult = dataInALUa_int - dataInALUb_int;
			         
			         MOV:   begin
			                     if(controlInALUshiftDir == 2'b00) localResult = dataInALUa_int << dataInALUb_int;//logical shift left
			                     if(controlInALUshiftDir == 2'b01) localResult = {1'b0,dataInALUa_int[39:0]} >> dataInALUb_int;//logical shift right
                              if(controlInALUshiftDir == 2'b10) localResult = dataInALUa_int >>> dataInALUb_int;//arithatic shift right
			                     if(controlInALUshiftDir == 2'b11) localResult = dataInALUa_int;
			                   
			                end 
			         NOT:   localResult = ~dataInALUa_int;
			         TEQ:   localResult = dataInALUa_int ^ dataInALUb_int;
			         TST:   localResult = dataInALUa_int & dataInALUb_int;
			         BWCMPL:localResult = {(~dataInALUa_int[39:32]+8'b1),(~dataInALUa_int[31:24]+8'b1),(~dataInALUa_int[23:16]+8'b1),(~dataInALUa_int[15:8]+8'b1),(~dataInALUa_int[7:0]+8'b1)};
			         LDR:   localResult = dataInALUa_int + dataInALUb_int;
			         LDRB:  localResult = dataInALUa_int + dataInALUb_int;
                  LDRH : localResult = dataInALUa_int + dataInALUb_int;
                  LDRSB :localResult = dataInALUa_int + dataInALUb_int;
                  LDRSH :localResult = dataInALUa_int + dataInALUb_int ;
                  STR :  localResult = dataInALUa_int + dataInALUb_int;
                  STRB : localResult = dataInALUa_int + dataInALUb_int;
                  STRH : localResult = dataInALUa_int + dataInALUb_int;
                  STRNEIGHBOR : localResult = dataInALUa_int + dataInALUb_int ;
                  LDNEIGHBOR : localResult = dataInALUa_int + dataInALUb_int ;
                  
                  default: localResult = 41'bx;

			    
			      
			      
			      endcase
			  end
			  
			  //overflow logic
			  always@(*)begin
			    
			      case({add_sub,dataInALUa_int[39],dataInALUb_int[39],dataOutALU[39]})
			                4'b0000:controlOutAluV = 0;
			                4'b0001:controlOutAluV = 1;
			                4'b0010:controlOutAluV = 0;
			                4'b0011:controlOutAluV = 0;
			                4'b0100:controlOutAluV = 0;
			                4'b0101:controlOutAluV = 0;
			                4'b0110:controlOutAluV = 1;
			                4'b0111:controlOutAluV = 0;
			                4'b1000:controlOutAluV = 0; 
			                4'b1001:controlOutAluV = 0;
			                4'b1010:controlOutAluV = 0;
			                4'b1011:controlOutAluV = 1;
			                4'b1100:controlOutAluV = 1;
			                4'b1101:controlOutAluV = 0;
			                4'b1110:controlOutAluV = 0;
			                4'b1111:controlOutAluV = 0;
			                default:controlOutAluV = 0;
			                
			      endcase
			  end
			  ////
			  
			  assign add_sub = ((controlInALUop == RSB)|(controlInALUop ==SUB)|(controlInALUop ==CMP)|(controlInALUop ==BWCMPL))? 1'b1 :1'b0; //bit to determine if an add or sub operation
			  assign controlOutAluZ =  ~|(dataOutALU); //If nor of dataOut = 1, then zero
			  assign controlOutAluN = localResult[39]; //if MSB of dataOut=1, then negative
			  assign controlOutAluC = localResult[40]; //if 1 then data carried
		     
		     assign dataOutALU = localResult[39:0];
		     
	

endmodule