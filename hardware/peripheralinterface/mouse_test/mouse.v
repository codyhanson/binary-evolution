/*
Module:				mouse

Description:		reads mouse input via ps/2 serial line

Hierarchy:			SYSTEM=>mouse


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	02/21/2011

*/

`timescale 1ns / 1ps
module mouse(
	input clk, input rst, 
	inout mouse_data, mouse_clk,
	output reg rda,
	output reg [7:0] data,
	input tbr,
	input [7:0] tx_data,
	output reg sent
	);

	localparam WAIT_ZERO = 2'b00;
	localparam READ_DATA = 2'b01;
	localparam HOLD_CLK_LOW = 2'b10;
	localparam SEND_DATA = 2'b11;

	reg [10:0] shiftreg, next_shiftreg;
	wire [7:0] next_data;
	reg [3:0] cnt, next_cnt;
	reg [1:0] state, next_state;
	wire next_rda, parity;
	reg drive_data, drive_clk, next_drive_clk, next_drive_data;
	reg rst_latch;

	// If processor clk is 100MHz, then each period is 1us
	// 		so use a 7-bit counter to wait 128us
	reg [6:0] hold_cnt, next_hold_cnt;	// Counter for 100us wait (8-bit to be safe)

	// Latch the reset signal so that the registers get reset
	always @(posedge clk) begin
		if (rst)
			rst_latch <= 1'b1;
		else if (~mouse_clk)
			rst_latch <= 1'b0;
		else
			rst_latch <= rst_latch;
	end

	// Some lines need to be on the processor clk, not the ps/2 clk
	always @(posedge clk) begin
		if (rst) begin
			hold_cnt <= 7'hFF;
			drive_data <= 1'b0;
			drive_clk <= 1'b0;
		end else begin
			hold_cnt <= next_hold_cnt;
			drive_data <= next_drive_data;
			drive_clk <= next_drive_clk;
		end
	end

	// Shift in new data at the falling edge of the ps/2 clk
	always @(negedge mouse_clk) begin
		if (rst_latch) begin
			data <= 8'hFF;
			rda <= 1'b0;
			shiftreg <= 11'hFFF;
			cnt <= 4'd10;
			state <= WAIT_ZERO;
		end else begin
			data <= next_data;
			rda <= next_rda;
			shiftreg <= next_shiftreg;
			cnt <= next_cnt;
			state <= next_state;
		end
	end

	always @(*) begin
		next_state = state;
		next_shiftreg = {mouse_data, shiftreg[10:1]};
		next_hold_cnt = 7'hFF;
		next_drive_data = 1'b0;
		next_drive_clk = 1'b0;
		next_cnt = cnt;
		sent = 1'b0;

		case (state)
			// Receive States
			WAIT_ZERO:begin
				next_cnt = 4'd10;

				// Over-ride all other processes if host wants to TX
				if (tbr) begin
					next_state = HOLD_CLK_LOW;
					next_shiftreg = {1'b1, (^tx_data)^1'b1, tx_data, 1'b0};
				end else begin
					if (shiftreg[10] == 1'b0) begin
						// Found start bit
						next_state = READ_DATA;
						next_cnt = cnt - 1;
					end
				end
			end

			READ_DATA:begin
				// Over-ride all other processes if host wants to TX
				if (tbr) begin
					next_state = HOLD_CLK_LOW;
					next_shiftreg = {1'b1, (^tx_data)^1'b1, tx_data, 1'b0};
				end else begin
					next_state = READ_DATA;
					next_cnt = cnt - 1;
					if (cnt == 0) begin
						next_state = WAIT_ZERO;
						next_cnt = 4'd10;
					end
				end
			end


			// Transmit States
			HOLD_CLK_LOW:begin
				// Hold the clock line low for > 100us
				next_shiftreg = shiftreg;
				next_hold_cnt = hold_cnt - 1;
				next_drive_clk = 1'b1;
				next_cnt = 4'd10;

				if (hold_cnt < 7'd8)
					next_drive_data = 1'b1;

				// Done holding clock low?
				if (hold_cnt == 7'h00) begin
					next_state = SEND_DATA;
					next_hold_cnt = hold_cnt;
					next_drive_data = 1'b1;	// Need to send data
					next_drive_clk = 1'b0;
					next_cnt = 4'd10;	// Will send 11 bits
					next_shiftreg = {1'b1, shiftreg[10:1]};
				end
			end

			SEND_DATA:begin
				next_cnt = cnt - 1;
				next_shiftreg = {1'b1, shiftreg[10:1]};
				next_drive_data = 1'b1;

				// Have we sent our 10 bits?
				if (cnt < 2) begin
					// Let mouse send stop/ack bits
					next_drive_data = 1'b0;
					sent = 1'b1;	// Tell controller we're done sending data
				end
				if (cnt == 0) begin
					// Should receive ACK bit here (data low)
					next_state = WAIT_ZERO;
					next_drive_data = 1'b0;
					next_cnt = 4'd10;
				end 
			end
		endcase
	end

	// Parsing logic to detect if shift reg has "start, data, parity, stop"
	assign parity = (^shiftreg[8:1]);
	assign valid_data = ( (state==READ_DATA) && (cnt==0) && (shiftreg[0] == 1'b0) && (shiftreg[10]	== 1'b1) && (shiftreg[9] ^ parity) ) ? 1'b1 : 1'b0;

	assign next_data = (valid_data ? shiftreg[8:1] : data);
	assign next_rda = valid_data;

	// Tri-state buffers for the mouse lines
	assign mouse_data = drive_data ? shiftreg[0] : 1'bZ;
	assign mouse_clk = drive_clk ? 1'b0 : 1'bZ;
	
endmodule
