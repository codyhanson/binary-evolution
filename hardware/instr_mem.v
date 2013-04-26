/*
Module:	Instruction Memory		

Description:		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by: Eric H.
Edited by:		
Module interface by:	

Date:			

*/

module instr_mem(clk, rst, addrIn, instr0, instr1);
input clk, rst;
input [29:0] addrIn;
output [31:0] instr0, instr1;
wire [31:0] rawinstr0, rawinstr1;
`include "opcodes.inc"



//FOR SIMULATION:
//instr_mem_bram_sim imem(.clka(clk),.addra(addrIn[9:0]),.douta(rawinstr0),.clkb(clk),.addrb(addrIn[9:0]+1'b1),.doutb(rawinstr1));

//FOR SYNTHESIS:
instr_mem_bram imem(.clka(clk),.addra(addrIn[10:0]),.douta(rawinstr0),.clkb(clk),.addrb(addrIn[10:0]+1'b1),.doutb(rawinstr1));


 assign instr0 = (rst) ? ({NOOP,26'bX}) : rawinstr0;
 assign instr1 = (rst) ? ({NOOP,26'bX}) : rawinstr1;
  

endmodule