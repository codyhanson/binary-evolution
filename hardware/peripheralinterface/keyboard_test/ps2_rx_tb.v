/*
Module:				ps2_rx_tb

Description:		tests the ps2_rx

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	02/23/2011

*/

`timescale 1ns / 1ps
module ps2_rx_tb();

	reg clk,ps2_clk,rst;
	reg [27:0] ps2_reg;
	wire ps2_data;
	reg clear;
	reg error;

	wire [7:0] data;
	reg rx_en;

	ps2_rx DUT(clk, rst, ps2_data, ps2_clk, rx_en, rda, data);

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end
	initial begin
		ps2_clk = 1'b0;
		forever #75 ps2_clk = ~ps2_clk;
	end

	initial begin
		ps2_reg = 28'he047d4d;	// Idle, start, 0x53, parity=1, stop, idle...., start, 0xFF, parity, stop
		forever @(posedge ps2_clk) ps2_reg = {ps2_reg[0],ps2_reg[27:1]};
	end

	assign ps2_data = ps2_reg[0];

	initial begin	
		rst = 1'b1;
		rx_en = 1'b1;
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
