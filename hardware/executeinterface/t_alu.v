

/*
Module: t_alu			

Description: Testbench for alu.  		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	
Edited by:		

Date:			

*/

module t_alu();
    
    reg [39:0] dataInALUa;
	 reg [39:0] dataInALUb;
	 reg[4:0] controlInALUop;
	 reg controlInALUshiftDir; 
	 wire reg[39:0] dataOutALU;
	 wire controlOutAluZ; 
	 wire controlOutAluC;
    wire controlOutAluV;
	 wire controlOutAluN;
    
    alu dut (dataInALUa,
			   dataInALUb,
			   controlInALUop,
			   controlInALUshiftDir, 
			   dataOutALU,
			   controlOutAluZ, 
			   controlOutAluC,
			   controlOutAluV,
			   controlOutAluN);
			   
	 initial begin
	     dataInALUa = 0; forever #10 dataInALUa = dataInALUa + 1;
	 end
	 initial begin
	     dataInALUb = 1; forever #10 dataInALUb = dataInALUb + 1;
	 end
	 initial begin
	     controlInALUop = 1; forever #10 controlInALUop = controlInALUop + 1;
	 end
	  initial begin
	     controlInALUshiftDir = 1; forever #10 controlInALUshiftDir = ~controlInALUshiftDir;
	 end
	 
			   
			   
			   
			   
			   
			   
endmodule
			   
			   
			   


