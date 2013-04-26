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
	input clear,
	input kbd_data, kbd_clk,
	output rda,
	output reg [7:0] data
	);

	localparam WAIT_ZERO = 1'b0;
	localparam FOUND_ZERO = 1'b1;

	reg [10:0] shiftreg;
	wire [7:0] next_data;
	reg [3:0] cnt, next_cnt;
	reg state, next_state;
	reg pre_rda, clear_reg;
	wire next_rda, next_clear_reg;
	wire parity;

	// Shift in new data at the falling edge of the KEYBOARD CLK
	always @(negedge kbd_clk) begin
		if (rst) begin
			data <= 8'hFF;
			pre_rda <= 1'b0;
			shiftreg <= 11'hFFF;
			cnt <= 4'd10;
			state <= WAIT_ZERO;
		end else begin
			data <= next_data;
			pre_rda <= next_rda;
			shiftreg <= {kbd_data, shiftreg[10:1]};
			cnt <= next_cnt;
			state <= next_state;
			clear_reg <= 1'b0;
		end
	end

	always @(posedge clk) begin
		if (rst) begin
			clear_reg <= 1'b0;
		end else begin
			clear_reg <= next_clear_reg;
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

	// Parsing logic here to detect if shift reg has "start, data, parity, stop", don't set if clear is high
	assign valid_data = ( (state==FOUND_ZERO) && (cnt==0) && (shiftreg[0] == 1'b0) && (shiftreg[10]	== 1'b1) && (shiftreg[9] ^ parity) ) ? 1'b1 : 1'b0;

	assign next_clear_reg = clear || clear_reg;
	assign next_rda = ~clear && valid_data;
	assign rda = pre_rda && ~clear_reg;

	assign parity = (^shiftreg[8:1]);
	assign next_data = clear ? 8'hFF : (next_rda ? shiftreg[8:1] : data);
	
endmodule
