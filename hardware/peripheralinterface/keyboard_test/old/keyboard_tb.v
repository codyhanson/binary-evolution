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
module keyboard_tb();

	reg clk,kbd_clk,rst;
	reg [27:0] kbd_reg;
	wire kbd_data;
	reg clear;
	reg error;

	wire [7:0] data;


	keyboard DUT(.clk(clk),.rst(rst),
		.kbd_data(kbd_data),
		.kbd_clk(kbd_clk),.rda(rda),
		.data(data));

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end
	initial begin
		kbd_clk = 1'b0;
		forever #75 kbd_clk = ~kbd_clk;
	end

	initial begin
		kbd_reg = 28'he047d4d;	// Idle, start, 0x53, parity=1, stop, idle...., start, 0xFF, parity, stop
		forever @(posedge kbd_clk) kbd_reg = {kbd_reg[0],kbd_reg[27:1]};
	end

	assign kbd_data = kbd_reg[0];

	initial begin	
		rst = 1'b1;
		error = 1'b0;
		clear = 1'b0;
		#10 rst = 1'b0;

		@(posedge rda)
		if (data != 8'h53) begin
			error = 1'b1;
		end

		@(posedge rda)
		if (data != 8'h04) begin
			error = 1'b1;
		end

		@(posedge rda)
		if (data != 8'h53) begin
			error = 1'b1;
		end

		@(posedge rda)
		if (data != 8'h04) begin
			error = 1'b1;
		end

		@(posedge rda)
		if (data != 8'h53) begin
			error = 1'b1;
		end

		#100;
		$stop;
	end	


endmodule
