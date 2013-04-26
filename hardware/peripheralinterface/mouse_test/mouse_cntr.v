/*
Module:				driver

Description:		drives the SPART/Keyboard interaction logic for sending
					received keyboard inputs to the terminal via a SPART

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom, Cody Hanson
Edited by:		
Module interface by:	

Date:	02/25/2011

*/

`timescale 1ns / 1ps
module mouse_cntr(
    input clk,
    input rst,
	inout mouse_data,
	inout mouse_clk,
	output reg [7:0] reg1,
	output reg [7:0] reg2,
	output reg [7:0] reg3,
	output reg [7:0] reg4,
	output reg [7:0] reg5,
	output reg [7:0] reg6,
	output reg [7:0] reg7,
	output reg [7:0] reg8,
	output reg [7:0] tx_data,
	output reg [1:0] state,
	output reg [1:0] step,

	//DEBUG
	output [7:0] dbg
    );

	localparam SEND_RST = 2'b01;
	localparam SEND_VAL = 2'b10;
	localparam RECEIVE = 2'b11;

    wire [7:0] data;
	wire rda, sent;

	reg ignore_rda;
	reg set_ignore, rst_ignore;
	reg [1:0] next_state;
	reg shift_val_in;	// Shift in new data
	reg tbr, next_tbr;	// Signal mouse to send tx_data
	reg [7:0] next_tx_data;
	reg [1:0] next_step;	// 0 - sending RST, 1 - sending ENABLE

	// DEBUG
	reg [6:0] rdn, next_rdn;

	ps2_rx mouse_rx0(clk, rst, mouse_data, mouse_clk, 1'b1, rda, data, dbg);

	always @(posedge clk) begin
		if (rst == 1'b1)begin
			reg1 <= 8'h11;
			reg2 <= 8'h22;
			reg3 <= 8'h33;
			reg4 <= 8'h44;
			reg5 <= 8'h55;
			reg6 <= 8'h66;
			reg7 <= 8'h77;
			reg8 <= 8'h88;
			state <= RECEIVE;
			tx_data <= 8'hFF;
			tbr <= 1'b0;
			step <= 2'd0;
		end
		else begin
			state <= next_state;
			tx_data <= next_tx_data;
			tbr <= next_tbr;
			step <= next_step;

			if (shift_val_in) begin
				reg8 <= reg7;
				reg7 <= reg6;
				reg6 <= reg5;
				reg5 <= reg4;
				reg4 <= reg3;
				reg3 <= reg2;
				reg2 <= reg1;
				reg1 <= data;
			end else begin
				reg1 <= reg1;
				reg2 <= reg2;
				reg3 <= reg3;
				reg4 <= reg4;
				reg5 <= reg5;
				reg6 <= reg6;
				reg7 <= reg7;
				reg8 <= reg8;
			end
		end
	end	

	always @(posedge clk) begin
		if (rst == 1'b1)
			ignore_rda <= 1'b0;
		else if (set_ignore)
			ignore_rda <= 1'b1;
		else if (rst_ignore)
			ignore_rda <= 1'b0;
		else
			ignore_rda <= ignore_rda;
	end

	// DEBUG
	always @(negedge mouse_clk) begin
		if (rst)
			rdn <= 7'hFF;
		else
			rdn <= next_rdn;
	end

	// FINITE STATE MACHINE
	always @(*) begin
		//defaults
		next_state = state;
		set_ignore = 1'b0;
		rst_ignore = 1'b0;
		next_tbr = 1'b0;
		next_step = step;
		shift_val_in = 1'b0;
		next_tx_data = tx_data;

		next_rdn = 7'hFF;

		case (state)
			SEND_RST:begin
				next_tx_data = 8'hFF;	// RESET
				next_tbr = 1'b1;

				if (sent) begin
					next_state = RECEIVE;
					rst_ignore = 1'b1;
				end
			end

			SEND_VAL:begin
				next_tbr = 1'b1;

				if (sent) begin
					next_state = RECEIVE;
					rst_ignore = 1'b1;
				end
			end

			RECEIVE:begin
//				// DEBUG: Stay in RECEIVE for a while, then send something
//				if (rdn == 7'h00) begin
//					next_state = SEND_VAL;
//					next_step = step + 1;
//					if (~step[0])
//						next_tx_data = 8'hED;	// 0xED = Set caps keys
//					if (step[0])
//						next_tx_data = 8'h02;	// caps lock
//				end 
//
//				next_rdn = rdn - 1;

				// Check if we've read anything
				if (rda == 1'b0) begin
					// No input from PS/2 yet
					rst_ignore = 1'b1;
				end
				else if(~ignore_rda) begin
					// Got input from PS/2 device
					set_ignore = 1'b1;
					shift_val_in = 1'b1;
				end
			end
		endcase
	end
endmodule
