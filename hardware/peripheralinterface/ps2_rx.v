/*
Module:				ps2_rx

Description:		reads in ps2 serial data. can be enabled or disabled

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/05/2011

Note:   Keyboard instantiates it as ps2_RX1
		Mouse    instantiates it as ps2_RX0
*/

`timescale 1ns / 1ps
module ps2_rx(
	input clk, rst,				// System clock and reset
	input ps2_data, ps2_clk,	// PS/2 lines. Read data on falling edge
	input rx_en,				// Enables PS/2 receiving
	output reg rda,					// Signals data was received (1-clk tick)
	output reg [7:0] data		// The data that was read. Stable until new data
								//		is read in, which replaces the old
	);

	localparam IDLE = 1'b0;		// Wait for a start bit (0)
	localparam READ = 1'b1;		// Read 8 data, parity, and stop bits

	reg [7:0] next_data;
	reg [9:0] shiftreg, next_shiftreg;	// Shift in ps2_data
	reg [3:0] cnt, next_cnt;	// Counts the bits we've read
	reg state, next_state;		// FSM States
	reg [2:0] clk_buf;	// Shifts in the ps2 clk for synch'd edge detection
	reg next_rda;
	wire fall_edge;				// 1-clk tick at falling edge of ps2_clk 
	wire parity;				// Checks parity
	wire valid;					// Checks if data in shiftreg is valid

	// Shift in new data at the falling edge of the KEYBOARD CLK
	always @(posedge clk) begin
		if (rst) begin
			data <= 8'hFF;
			shiftreg <= 10'hFFF;
			rda <= 1'b0;
			cnt <= 4'd9;
			state <= IDLE;
			clk_buf <= 3'b000;
		end else begin
			data <= next_data;
			shiftreg <= next_shiftreg;
			rda <= next_rda;
			cnt <= next_cnt;
			state <= next_state;
			clk_buf <= {clk_buf[1:0], ps2_clk};
		end
	end

	// Finite State Machine
	always @(*) begin
		// Defaults
		next_rda = 0;	// Default to not ready
		next_data = data;
		next_shiftreg = shiftreg;
		next_cnt = cnt;
		next_state = state;

		if (rx_en) begin
			// Receiver is enabled

			// Only do things on the falling edge
			if (fall_edge) begin
				next_shiftreg = {ps2_data, shiftreg[9:1]};
				case (state)
					IDLE:begin
						if (shiftreg[9] == 1'b0) begin
							next_state = READ;
							next_cnt = cnt - 1;
						end else begin
							next_state = IDLE;
							next_cnt = 4'd9;
						end
					end // IDLE

					READ:begin
						next_state = READ;
						next_cnt = cnt - 1;
						if (cnt == 0) begin
							next_state = IDLE;
							next_cnt = 4'd9;
							if (valid) begin
								next_rda = 1'b1;
								next_data = shiftreg[8:1];
							end
						end
					end // READ
				endcase
			end // (fall_edge)
		end else begin
			// Receiver disabled. Return to initial state
			next_data = data;
			next_shiftreg = 10'hFFF;
			next_cnt = 4'd9;
			next_state = IDLE;
		end // (~rx_en)
	end

	// Parsing logic to detect if data is valid
	assign parity = (^shiftreg[8:1]);
	assign valid = ( (shiftreg[0] == 1'b0) && (shiftreg[9] ^ parity) ) ? 1'b1 : 1'b0;

	// Falling edge detection
	assign fall_edge = (clk_buf == 3'b110) ? 1'b1 : 1'b0;
endmodule
