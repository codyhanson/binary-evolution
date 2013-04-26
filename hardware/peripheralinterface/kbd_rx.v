/*
Module:				kbd_rx

Description:		Reads keyboard input using <ps2_rx.v>. Uses <scan_to_ascii.v> to convert the values (ignores key holding down)

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/05/2011

*/

`timescale 1ns / 1ps
module kbd_rx(
    input clk,
    input rst,
	input rx_en,		// Enable receiving
	input ps2_data,		// Treating as IN only
	input ps2_clk,		// Treating as IN only
	output reg char_rda,		// Tick signalling ascii char ready
	output reg [7:0] char_out,	// Valid until replaced
	output reg toggle_caps		// Signal controller to change LED status
    );

	// FSM States
	localparam IDLE = 1'b0;	// Wait for break code (0xF0)
	localparam CONVERT = 1'b1;	// Grab next code and convert to ascii

	// KEYBOARD SCAN-CODES
	localparam BREAK = 8'hF0;	// Sent when key released, before key's code
	localparam SHIFT_L = 8'h12;	// Shift key
	localparam SHIFT_R = 8'h59;	// Shift key
	localparam CAPS = 8'h58;	// Shift key

	reg state, next_state;	// FSM State
	wire [7:0] scancode;	// Data read from keyboard. Needs to be converted
	wire [7:0] char_ascii;	// The converted value
	reg [7:0] next_char;
	wire ps2_rda;			// ps2 read ready tick
	wire shift;				// Shift key pressed?
	reg shift_l, shift_r;	// Left/Right shift keys
	reg next_shift_l, next_shift_r;
	reg caps, next_caps;	// Caps lock on?
	reg next_toggle;
	reg next_rda;

	// Shift if either left or right <shift> key pressed
	assign shift = shift_l | shift_r;

	// Instantiate Submodules
	ps2_rx ps2_RX1(clk, rst, ps2_data, ps2_clk, rx_en, ps2_rda, scancode);
	scan_to_ascii s_to_a0 (clk, rst, scancode, shift, caps, char_ascii);

	// Registers
	always @(posedge clk) begin
		if (rst == 1'b1)begin
			state <= IDLE;
			shift_l <= 1'b0;
			shift_r <= 1'b0;
			caps <= 1'b0;
			char_rda <= 1'b0;
			char_out <= 8'h00;
			toggle_caps <= 1'b0;
		end
		else begin
			state <= next_state;
			shift_l <= next_shift_l;
			shift_r <= next_shift_r;
			caps <= next_caps;
			char_rda <= next_rda;
			char_out <= next_char;
			toggle_caps <= next_toggle;
		end
	end	

	// Finite State Machine
	always @(*) begin
		//defaults
		next_state = state;
		next_shift_l = shift_l;
		next_shift_r = shift_r;
		next_caps = caps;
		next_rda = 1'b0;
		next_char = char_out;
		next_toggle = 1'b0;

		case (state)
			IDLE:begin
				// Only act when something is read
				if (ps2_rda) begin
					// Check if a key was released
					if (scancode == BREAK)
						next_state = CONVERT;

					if (scancode == SHIFT_L ) begin
						next_state = IDLE;
						next_shift_l = 1'b1;
					end else if (scancode == SHIFT_R) begin
						next_state = IDLE;
						next_shift_r = 1'b1;
					end
				end // (ps2_rda)
			end // IDLE

			CONVERT:begin
				if (ps2_rda) begin
					next_state = IDLE;

					if (scancode == SHIFT_L) begin
						next_shift_l = 1'b0;	// Left shift released
					end else if (scancode == SHIFT_R) begin
						next_shift_r = 1'b0;	// Right shift released
					end else if (scancode == CAPS) begin
						next_caps = ~caps;	// If <caps> is hit, toggle status
						next_toggle = 1'b1;	// Set the CAPS LED on the kbd
					end else begin
						next_char = char_ascii;
						next_rda = 1'b1;
					end
				end // (ps2_rda)
			end	// CONVERT
		endcase
	end // FSM
endmodule // kbd_cntrl.v
