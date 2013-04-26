/*
Module:				mouse_tb

Description:		tests the mouse

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/04/2011

*/

`timescale 1ns / 1ps
module mouse_tb();

	reg clk,rst;
	reg clk2;
	reg [27:0] mouse_reg;
	wire mouse_data, mouse_clk;

	wire [1:0] state;
	wire [1:0] step;
	wire [7:0] data;

	wire [7:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9;

	assign mouse_data = DUT.m0.drive_data ? 1'bz : mouse_reg[0];
	assign mouse_clk = DUT.m0.drive_clk ? 1'bz : clk2;

	mouse_cntr DUT(clk, rst, mouse_data, mouse_clk, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, state, step);

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end
	initial begin
		clk2 = 1'b0;
		forever #75 clk2 = ~clk2;
	end

	initial begin
		mouse_reg = 28'he047d4d;	// Idle, start, 0x53, parity=1, stop, idle...., start, 0xFF, parity, stop
		forever @(posedge clk2) begin
			if (DUT.m0.drive_data) begin
				mouse_reg = {3'b110,8'h1C,1'b0, 2'b11, 14'hFFA5};	// stop,ack,idle, send 0xFA
			end else begin
				mouse_reg = {1'b1,mouse_reg[27:1]};
			end
		end
	end

	initial begin	
		rst = 1'b1;
		#100 rst = 1'b0;

		#500000;
		$stop;
	end	


endmodule
