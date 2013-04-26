`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:01 02/15/2008 
// Design Name: 
// Module Name:    tick_logic 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module tick_logic(clk, rst, tick_cycle, up, down, left, right, multiplier, multiplicand, product, mouse_data, mouse_clk);
    input clk;
    input rst;
    input tick_cycle;
	input up;
	input down;
	input left;
	input right;
    output [31:0] multiplier;
    output [31:0] multiplicand;
    output [31:0] product;
	inout mouse_data;
	inout mouse_clk;
  
	wire [7:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9;

	//DEBUG
	wire [1:0] state;
	wire [1:0] step;

	reg [7:0] ack;

	always @(posedge clk) begin
		if (rst)
			ack <= 8'h4F;
		else if (reg1 == 8'hF4)
			ack <= 8'hF4;
	end
			

	// FORMAT OF OUTPUT: ([]'s represent each hex digit)
	// [  0][state] [ tx][out] [reg][6] [reg][3]
	// [  0][ step] [reg][  8] [reg][5] [reg][2]
	// [ack][ yet?] [reg][  7] [reg][4] [reg][1]
	//
	// state => 1:SEND_RST, 2:SEND_ENABLE, 3:RECEIVE
	// step  => 0: need to reset, 1: need to enable,
	//			2: need to get ack, 3: done w/ setup

	assign multiplier = {6'd0, state, reg9, reg6, reg3};
	assign multiplicand = {6'd0, step, reg8, reg5, reg2};
	assign product = {ack, reg7, reg4, reg1};

	kbd_cntrl controller0(clk, rst, mouse_data, mouse_clk, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, state, step);

endmodule
