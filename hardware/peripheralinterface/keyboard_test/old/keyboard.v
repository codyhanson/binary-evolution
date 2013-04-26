/*
Module:				keyboard

Description:		reads keyboard input via ps/2 serial line

Hierarchy:			SYSTEM=>keyboard


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	02/21/2011

*/

`timescale 1ns / 1ps
module keyboard(
	input clk, input rst, 
	input kbd_data, kbd_clk,
	output reg rda,
	output reg [7:0] data
	);

	localparam WAIT_ZERO = 1'b0;
	localparam FOUND_ZERO = 1'b1;

	reg [10:0] shiftreg;
	wire [7:0] next_data;
	reg [3:0] cnt, next_cnt;
	reg state, next_state;
	wire next_rda, parity;

	// Shift in new data at the falling edge of the KEYBOARD CLK
	always @(negedge kbd_clk) begin
		if (rst) begin
			data <= 8'hFF;
			rda <= 1'b0;
			shiftreg <= 11'hFFF;
			cnt <= 4'd10;
			state <= WAIT_ZERO;
		end else begin
			data <= next_data;
			rda <= next_rda;
			shiftreg <= {kbd_data, shiftreg[10:1]};
			cnt <= next_cnt;
			state <= next_state;
		end
	end

	always @(*) begin
		case (state)
			WAIT_ZERO:begin
				if (shiftreg[10] == 1'b0) begin
					next_state = FOUND_ZERO;
					next_cnt = cnt - 1;
				end else begin
					next_state = WAIT_ZERO;
					next_cnt = 4'd10;
				end
			end
			FOUND_ZERO:begin
				next_state = FOUND_ZERO;
				next_cnt = cnt - 1;
				if (cnt == 0) begin
					next_state = WAIT_ZERO;
					next_cnt = 4'd10;
				end
			end
		endcase
	end

	// Parsing logic here to detect if shift reg has "start, data, parity, stop"
	assign valid_data = ( (state==FOUND_ZERO) && (cnt==0) && (shiftreg[0] == 1'b0) && (shiftreg[10]	== 1'b1) && (shiftreg[9] ^ parity) ) ? 1'b1 : 1'b0;

	assign next_rda = valid_data;

	assign parity = (^shiftreg[8:1]);
	assign next_data = (next_rda ? shiftreg[8:1] : data);
	
endmodule
