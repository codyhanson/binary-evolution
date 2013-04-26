/*
Module:				keyboard_tb

Description:		tests the keyboard

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	02/23/2011

*/

`timescale 1ns / 1ps
module top_level_tb();

	reg clk,kbd_clk,rst;
	reg [11:0] kbd_reg;
	wire kbd_data;
	reg error, err2;

	reg [1:0] br_cfg;
   reg rxd;
   
	assign kbd_data = kbd_reg[0];
	
	top_level DUT( .clk(clk), .rst(rst), .kbd_clk(kbd_clk), .br_cfg(br_cfg),
				.kbd_data(kbd_data), .txd(txd), .rxd(rxd)
				);

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end

	initial begin	
		kbd_clk = 1'b1;
		forever #50 kbd_clk = ~kbd_clk;
	end

	initial begin
		br_cfg = 2'b11;
		rxd = 1'b1;
	end

	initial begin
		kbd_reg = 12'hd4d;	// Idle, start, 0x53, parity=1, stop
		forever @(posedge kbd_clk) kbd_reg = {kbd_reg[0],kbd_reg[11:1]};
	end

	initial begin	
		rst = 1'b1;
		error = 1'b0;
		err2 = 1'b0;
		#10 rst = 1'b0;

		#1000000;
		$stop;
	end	


endmodule
