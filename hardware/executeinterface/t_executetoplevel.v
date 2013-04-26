

/*
Module: t_executetoplevel			

Description: Testbench for execute stage.  		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/

module t_executetoplevel();
    
           reg clk;
           reg rst;
			  reg [4:0] controlInDecExOp1;
			  reg [39:0] dataInDecExRm1;
			  reg [39:0] dataInDecExRn1;
			  reg [39:0] dataInDecExRo1;
			  reg [3:0] controlInDecExCond1;
			  reg [4:0] controlInDecExOp2;
			  reg [39:0] dataInDecExRm2;
			  reg [39:0] dataInDecExRn2;
			  reg [39:0] dataInDecExRo2;
			  reg [3:0] controlInDecExCond2;
			  reg [39:0] dataInExMemRd1;
			  reg [39:0] dataInExMemRd2;
			  wire [4:0] controlOutExMemOp1;
			  wire [39:0] dataOutExMemRd1;
			  wire [39:0] dataOutExMemRo1;
			  wire [4:0] controlOutExMemOp2;
			  wire [39:0] dataOutExMemRd2;
			  wire [39:0] dataOutExMemRo2;
			  wire controlOutExecuteStall;

         executetoplevel dut(
           .clk(clk),
           .rst(rst),
			  .controlInDecExOp1(controlInDecExOp1),
			  .dataInDecExRm1(dataInDecExRm1),
			  .dataInDecExRn1(dataInDecExRn1),
			  .dataInDecExRo1(dataInDecExRo1),
			  .controlInDecExOp2(controlInDecExOp2),
			  .dataInDecExRm2(dataInDecExRm2),
			  .dataInDecExRn2(dataInDecExRn2),
			  .dataInDecExRo2(dataInDecExRo2),
			  .dataInExMemRd1(dataInExMemRd1),
			  .dataInExMemRd2(dataInExMemRd2),
			  .controlOutExMemOp1(controlOutExMemOp1),
			  .dataOutExMemRd1(dataOutExMemRd1),
			  .dataOutExMemRo1(dataOutExMemRo1),
			  .controlOutExMemOp2(controlOutExMemOp2),
			  .dataOutExMemRd2(dataOutExMemRd2),
			  .dataOutExMemRo2(dataOutExMemRo2),
			  .controlOutExecuteStall(controlOutExecuteStall),
			  .controlInDecExCond1(controlInDecExCond1),
			  .controlInDecExCond2(controlInDecExCond2));	
			 
			  initial begin
			     
	           clk = 0; forever #5 clk = ~clk;
	          
	       end
		/*
			 initial begin
			     
	           controlInDecExOp1 = 0; forever #10 controlInDecExOp1 = controlInDecExOp1 + 1;

	       end
	       initial begin
			     
	           dataInDecExRn1 = 0; forever #10 dataInDecExRn1 = dataInDecExRn1 + 1;
	
	       end
	       initial begin
			     
	           dataInDecExRm1 = 0; forever #10 dataInDecExRm1 = dataInDecExRm1 + 2;
	
	       end
	       initial begin
			     
	           controlInDecExOp2 = 1; forever #10 controlInDecExOp2 = controlInDecExOp2 + 1;

	       end
	       initial begin
			     
	           dataInDecExRn2 = 3; forever #10 dataInDecExRn2 = dataInDecExRn2 + 3;
	
	       end
	       initial begin
			     
	           dataInDecExRm2 = 2; forever #10 dataInDecExRm2 = dataInDecExRm2 + 2;
	
	       end
			 initial begin
			    rst = 1;
			    #20;
			    rst = 0; 
			 end 
	/////////////////////////////
	/*
			initial begin
			   rst = 1;
			   #20;
			   rst = 0;
			   controlInDecExOp1 = 5'b00000;
			   dataInDecExRn1 = 40'h000000000A;
			   dataInDecExRm1 = 40'h000000000B;
			   #20;   
			   dataInDecExRn1 = 40'hFFFFFFFFFF;
			   dataInDecExRm1 = 40'hFFFFFFFFFF;
			end
			   
	*/	
	//////////////////////////////
	initial begin
	      rst = 1;
	      #20;
	      rst = 0;
	      
	end
	initial begin
			     
	           controlInDecExCond1 = 1; forever #10 controlInDecExCond1 = controlInDecExCond1 + 1;

	end
	initial begin
			     
	           controlInDecExCond2 = 0; forever #10 controlInDecExCond2 = controlInDecExCond2 + 1;

	end
	initial begin
			     
	           controlInDecExOp1 = 0; forever #10 controlInDecExOp1 = controlInDecExOp1 + 1;

	       end
	       initial begin
			     
	           dataInDecExRn1 = 0; forever #10 dataInDecExRn1 = dataInDecExRn1 + 1;
	
	       end
	       initial begin
			     
	           dataInDecExRm1 = 0; forever #10 dataInDecExRm1 = dataInDecExRm1 + 2;
	
	       end
	       initial begin
			     
	           controlInDecExOp2 = 1; forever #10 controlInDecExOp2 = controlInDecExOp2 + 1;

	       end
	       initial begin
			     
	           dataInDecExRn2 = 3; forever #10 dataInDecExRn2 = dataInDecExRn2 + 3;
	
	       end
	       initial begin
			     
	           dataInDecExRm2 = 2; forever #10 dataInDecExRm2 = dataInDecExRm2 + 2;
	
	       end
	


	     	   
			   
endmodule
			   
			   
			   


