/*
Module:				ps2_tx

Description:		writes to ps2 serial data. can be enabled or disabled

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/06/2011

Note:   Keyboard instantiates it as ps2_TX1
		Mouse    instantiates it as ps2_TX0
*/

`timescale 1ns / 1ps
module ps2_tx(
	input clk, rst,		// System clock and reset
	input tx_en,		// Enables PS/2 transmitting
	inout ps2_data,	// PS/2 data line -- we only drive it
	inout ps2_clk,		// PS/2 clock. Need to read and drive it
	input tbr,			// Signals data was received (1-clk tick)
	input [7:0] data,	// The data to transmit
	output reg sent,	// Signals controller that we are done sending

	// DEBUG
	output [1:0] dbg1,
	output [3:0] dbg2
	);


	localparam IDLE = 2'b00;	// Wait for tx_en and tbr
	localparam HOLD = 2'b01;	// Hold the clock line low for > 100us
	localparam SEND = 2'b10;	// Send the data

	reg [9:0] shiftreg, next_shiftreg;	// Shift out to ps2_data
	reg [1:0] state, next_state;		// FSM States
	reg [15:0] hold_cnt, next_hold;		// 10000+ count @ 100MHz  > 128us
	reg [3:0] cnt, next_cnt;			// Counts the bits we've sent
	reg data_out, clk_out;				// Desired outputs
	reg next_sent;
	reg [2:0] clk_buf;	// Shifts in the ps2 clk for synch'd edge detection
	wire fall_edge;		// 1-clk tick at falling edge of ps2_clk 

	// Shift in new data at the falling edge of the KEYBOARD CLK
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			shiftreg <= 10'hFFF;
			cnt <= 4'd11;
			state <= IDLE;
			hold_cnt <= 16'hFFFF;
			clk_buf <= 3'b000;
			sent <= 1'b0;
		end else begin
			shiftreg <= next_shiftreg;
			cnt <= next_cnt;
			state <= next_state;
			hold_cnt <= next_hold;
			clk_buf <= {clk_buf[1:0], ps2_clk};
			sent <= next_sent;
		end
	end

	// Finite State Machine
	always @(*) begin
		// Defaults
		next_shiftreg = shiftreg;
		next_state = state;
		next_hold = hold_cnt;
		next_cnt = cnt;
		data_out = 1'b1;
		clk_out = 1'b1;
		next_sent = sent;

		if (~tx_en)
			next_state = IDLE;
		else begin
			case (state)
				IDLE:begin
					next_sent = 1'b0;
					if (tbr) begin
						// Grab the data, and add parity and start bits
						next_shiftreg = {~(^data),data,1'b0};
						next_state = HOLD;
						next_hold = 16'hFFFF;	// Initialize hold_cnt
					end // (tbr)
				end // IDLE

				HOLD:begin
					clk_out = 1'b0;

					if (hold_cnt < 32)
						data_out = 1'b0;//shiftreg[0];

					// Have we waited atleast 100us?
					if (hold_cnt == 16'h0000) begin
						next_state = SEND;
						next_cnt = 4'd11;
					end else begin
						next_state = HOLD;
						next_hold = hold_cnt - 1;
					end
				end // HOLD

				SEND:begin
					data_out = shiftreg[0];
					next_cnt = cnt;

					// Only change things at falling edge ps2_clk
					if (fall_edge) begin
						next_shiftreg = {1'b1, shiftreg[9:1]};
						next_cnt = cnt - 1;

						// Let pullup's take care of stop bit
						if (cnt == 1) begin
							next_state = IDLE;
							data_out = 1'b1;
							next_sent = 1'b1;
						end
						// Should get ACK bit now
						if (cnt == 0) begin
							next_state = IDLE;
							data_out = 1'b1;	// Hi-Z
							next_sent = 1'b1;
							next_cnt = 4'd0;
						end // ack
					end // (fall_edge)
				end // SEND
			endcase // case (state)
		end // (tx_en)
	end

	// PS/2 I/O logic. Never drive 1'b1, let pullups do that
	assign ps2_data = data_out ? 1'bZ : 1'b0;
	assign ps2_clk = clk_out ? 1'bZ : 1'b0;

	// Falling edge detection
	assign fall_edge = (clk_buf == 3'b110) ? 1'b1 : 1'b0;

	// DEBUG
	assign dbg1 = state;
	assign dbg2 = cnt;

endmodule
