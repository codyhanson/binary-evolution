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

module tick_logic(clk, rst, tick_cycle, up, down, left, right, multiplier, multiplicand, product, kbd_data, kbd_clk);
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
	inout kbd_data;
	inout kbd_clk;
  
	wire [7:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9;

	//DEBUG
	wire [1:0] state;
	wire [1:0] dbg1;
	wire [3:0] dbg2;

	reg [7:0] ack;

	always @(posedge clk) begin
		if (rst)
			ack <= 8'haa;
		else if (reg1 == 8'hF4)
			ack <= 8'hF4;
	end

	kbd_cntrl controller0(clk, rst, kbd_data, kbd_clk,
						reg1, reg2, reg3, reg4, reg5,
						reg6, reg7, reg8, reg9, state,
						dbg1, dbg2);

	// FORMAT OF OUTPUT: ([]'s represent each hex digit)
	// [state][tx_st] [ tx][out] [reg][6] [reg][3]
	// [    0][txCnt] [reg][  8] [reg][5] [reg][2]
	// [  ack][ yet?] [reg][  7] [reg][4] [reg][1]
	//
	// state => 0:SET_LED, 1:LED_VAL, 2:RECEIVE
	// tx_st => 0:IDLE,    1:HOLD,    2:SEND
	// txCnt => bit # to send
			
	assign multiplier = {2'd0, state, 2'd0, dbg1, reg9, reg6, reg3};
	assign multiplicand = {4'd0, dbg2, reg8, reg5, reg2};
	assign product = {ack, reg7, reg4, reg1};

endmodule
