/*
Module: executetoplevel		

Description: Controls the top level of the execute cycle

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/


module executetoplevel(
           input clk,
           input rst,
			  input [4:0] controlInDecExOp1,
			  input [39:0] dataInDecExRm1,
			  input [39:0] dataInDecExRn1,
			  input [39:0] dataInDecExRo1,
			  input [3:0] controlInDecExCond1,
			  input [4:0] controlInDecExOp2,
			  input [39:0] dataInDecExRm2,
			  input [39:0] dataInDecExRn2,
			  input [39:0] dataInDecExRo2,
			  input [3:0] controlInDecExCond2,
			  input [39:0] dataInExMemRd1,
			  input [39:0] dataInExMemRd2,
			  input flush, input stall,
			  output [4:0] controlOutExMemOp1,
			  output [39:0] dataOutExMemRd1,
			  output [39:0] dataOutExMemRo1,
			  output [4:0] controlOutExMemOp2,
			  output [39:0] dataOutExMemRd2,
			  output [39:0] dataOutExMemRo2,	  
			  output controlOutExecuteStall,
			  output [2:0] cyclecnt);
			  
			  wire localReorderEnable, localAlu1Aen, localAlu1Ben, localAlu2en;
			  wire[4:0] localmulticycleOpA;
           wire[4:0] localmulticycleOpB;
			  wire[2:0] localExecuteCycleCnt;
			  wire[39:0] localReorderDataA;
			  wire[39:0] localReorderDataB ;
			  wire controlOutExecuteZ1;
			  wire controlOutExecuteC1;
			  wire controlOutExecuteV1;
			  wire controlOutExecuteN1;
			  wire controlOutExecuteZ2;
			  wire controlOutExecuteC2;
			  wire controlOutExecuteV2;
			  wire controlOutExecuteN2;
			  
			  wire [3:0] localnextFlags1; //{z,c,v,n}
			  reg [3:0] localcurFlags1; //{z,c,v,n}
			  wire [3:0] localnextFlags2; //{z,c,v,n}
			  reg [3:0] localcurFlags2; //{z,c,v,n}
			 
			  wire passCheck1,passCheck2;
			  
			  `include "opcodes.inc"
			  
			  alu alu1 (.dataInALUa(localAlu1Aen ? dataInExMemRd1: dataInDecExRm1), 
			              .dataInALUb(localAlu1Ben ? dataInExMemRd2: dataInDecExRn1),
			               .controlInALUop(localmulticycleOpA),
			               .controlInALUshiftDir(dataInDecExRo1[1:0]),.controlInALUCycleCnt(localExecuteCycleCnt), 
			  					.dataOutALU(dataOutExMemRd1),.controlOutAluZ(controlOutExecuteZ1),
			  					.controlOutAluC(controlOutExecuteC1),
			  					.controlOutAluV(controlOutExecuteV1),.controlOutAluN(controlOutExecuteN1));
			  					
			  alu alu2 (.dataInALUa(localAlu2en ? localReorderDataA:dataInDecExRm2 ), 
			               .dataInALUb(localAlu2en ? localReorderDataB:dataInDecExRn2),
			               .controlInALUop(localmulticycleOpB),
			               .controlInALUshiftDir(dataInDecExRo2[1:0]),.controlInALUCycleCnt(localExecuteCycleCnt), 
			  					.dataOutALU(dataOutExMemRd2),.controlOutAluZ(controlOutExecuteZ2),
			  					.controlOutAluC(controlOutExecuteC2),
			  					.controlOutAluV(controlOutExecuteV2),.controlOutAluN(controlOutExecuteN2));
			  
			  neighborOpController cont(.clk(clk),.rst(rst),.controlInExControllerOpA(controlInDecExOp1),
			                            .controlInExControllerOpB(controlInDecExOp2),
			                            .controlOutExControllerStall(controlOutExecuteStall),
			                            .controlOutExControllerOpA(localmulticycleOpA),
			                            .controlOutExControllerOpB(localmulticycleOpB),
			                            .controlOutExControllerCycleCnt(localExecuteCycleCnt), .flush(flush), .stall(stall));
			  reorder r1( .dataInReorder(dataInDecExRm1), 
			              .controlInReorderEnable(localReorderEnable), .dataOutReorder(localReorderDataA));
			  
			  reorder r2( .dataInReorder(dataInDecExRn1), 
			              .controlInReorderEnable(localReorderEnable), .dataOutReorder(localReorderDataB));

			  
			  ///////flag logic
			  reg [3:0] savedflags;
			  wire [3:0] nextsavedflags;
			  
			  condCheck p1(.controlInCond(controlInDecExCond1),.dataInZ(savedflags[3]),
			  .dataInC(savedflags[2]),.dataInV(savedflags[1]),
			  .dataInN(savedflags[0]),.dataOutCondMet(passCheck1));
			  
			  condCheck p2(.controlInCond(controlInDecExCond2),.dataInZ((passCheck1? controlOutExecuteZ1:savedflags[3])),
			  .dataInC((passCheck1 ? controlOutExecuteC1:savedflags[2])),.dataInV((passCheck1 ? controlOutExecuteV1:savedflags[1])),
			  .dataInN((passCheck1 ? controlOutExecuteN1:savedflags[0])),.dataOutCondMet(passCheck2));
			  
			  always @(posedge clk) begin
			     if (rst) begin savedflags <= 4'h0; end
			     else begin savedflags <= nextsavedflags; end  
			  end
			  
			  assign nextsavedflags = (stall) ? savedflags : 
			         ((!passCheck2||(controlInDecExOp2==NOOP))? (passCheck1&&(controlInDecExOp1!=NOOP) ? {controlOutExecuteZ1,controlOutExecuteC1,controlOutExecuteV1,controlOutExecuteN1} : savedflags) 
			         : {controlOutExecuteZ2,controlOutExecuteC2,controlOutExecuteV2,controlOutExecuteN2} );
			  
			  
			 
			 
			 
			  
			  
			 
			 
			 
			 
			  //Send noop to pipelin register if multi-cycle operation
			  assign controlOutExMemOp1 = ~passCheck1? 5'b00011:(controlInDecExOp1 == 5'b01000 | localExecuteCycleCnt >  3'd0 && localExecuteCycleCnt <  3'd3) ? 5'b00011 : localExecuteCycleCnt == 3'd3 ? 5'b01000 : controlInDecExOp1;
			  assign controlOutExMemOp2 = ~passCheck2? 5'b00011:(controlInDecExOp1 == 5'b01000 | localExecuteCycleCnt >  3'd0 && localExecuteCycleCnt <  3'd3) ? 5'b00011 : localExecuteCycleCnt == 3'd3 ? 5'b01000 : controlInDecExOp2;
			  
			  //Pass through Ro
			  assign dataOutExMemRo1 = dataInDecExRo1;
			  assign dataOutExMemRo2 = dataInDecExRo2;
			  
			  //Set up the enables to be used to select the data to input to alus
			  assign localReorderEnable = (controlInDecExOp1 == 5'b01000 && localExecuteCycleCnt == 3'b000) ? 1 : 0;
			  assign localAlu1Aen = (localExecuteCycleCnt >  3'd0) ? 1 : 0;
			  assign localAlu1Ben = (localExecuteCycleCnt == 3'd1) ? 1 : 0;
			  assign localAlu2en = (controlInDecExOp1 == 5'b01000 && localExecuteCycleCnt == 3'b000) ? 1 : 0;
			  assign cyclecnt = localExecuteCycleCnt;
			  
			  
			  
			 
	

endmodule
