`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Company: ECE 554
// Engineer: Cody Hanson, Ross Nordstrom
// 
// Create Date: Jan 31, 2011   
// Design Name: SPART
// Module Name:  brg_spart
// Target Devices: Xilinx Virtex-2P
//
// This module can be configured with a 16 bit value that should be set to drive an
// enable signal high for 1/16th of the full baud rate, for 1 clock period. 
///////////////////////////////////////////////////////////////////////////////////
module brg_spart(
	input [7:0] databus,
	input clk,rst,
	input [1:0] ioaddr,
	output brg_en, brg_full //rate enable signals
	);

	reg [15:0] div_buffer, div_buffer_next;
	reg [3:0] full_cnt;
	wire [3:0] full_cnt_next;
	reg [15:0] cnt, cnt_next;
	wire zero;

	always @(posedge clk) begin
		if(rst == 1'b1) begin
			// Default DB to 100 MHz and 9600 baud
			div_buffer <= 16'd650;	// 100M/9600 - 1, rounded
			cnt <= 16'd650; // Gets DB
			full_cnt <= 4'hf; // Counts down from 15 to 0
		end
		else begin
			div_buffer <= div_buffer_next;
			cnt <= cnt_next;
			full_cnt <= full_cnt_next;
		end
	end

	always @(*) begin
		// Defaults
		div_buffer_next = div_buffer;
		cnt_next = cnt - 1;

		// Load DB(low)
		if(ioaddr == 2'b10)
			div_buffer_next = {div_buffer[15:8], databus};
		// Load DB(high)
		if(ioaddr == 2'b11)
			div_buffer_next = {databus, div_buffer[7:0]};

		// Roll <cnt> over to the contents od the DB
		if(zero == 1'b1)
			cnt_next = div_buffer;
	end

	assign zero = (cnt == 16'h0000) ? 1'b1 : 1'b0;
	assign full_cnt_next = full_cnt - zero; // Only dec's when <cnt> is 0

	assign brg_en = zero;
	assign brg_full = (full_cnt == 4'h0 && brg_en == 1'b1) ? 1'b1 : 1'b0;
endmodule
