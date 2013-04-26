/*
Module:				scan_to_ascii

Description:		Converts a keyboard scan code to ascii. Does conversion
					depending on status of <shift> and <caps>. Signals that conversion
					is complete with <char_rda)

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/05/2011

*/

`timescale 1ns / 1ps
module scan_to_ascii(
    input clk,
    input rst,
	input [7:0] scancode,
	input shift,
	input caps,
	output reg [7:0] char_ascii		// Result of conversion
    );

	// Conversion table
	always @(*) begin
		// Default - ignore unknown keys
		char_ascii = 8'h00; // (null)

		// Only upper case is one of shift/caps hit
		if (shift ^ caps) begin
			case (scancode)
				8'h1c: char_ascii = 8'h41;	// A
				8'h32: char_ascii = 8'h42;	// B
				8'h21: char_ascii = 8'h43;	// C
				8'h23: char_ascii = 8'h44;	// D
				8'h24: char_ascii = 8'h45;	// E
				8'h2b: char_ascii = 8'h46;	// F
				8'h34: char_ascii = 8'h47;	// G
				8'h33: char_ascii = 8'h48;	// H
				8'h43: char_ascii = 8'h49;	// I
				8'h3b: char_ascii = 8'h4a;	// J
				8'h42: char_ascii = 8'h4b;	// K
				8'h4b: char_ascii = 8'h4c;	// L
				8'h3a: char_ascii = 8'h4d;	// M
				8'h31: char_ascii = 8'h4e;	// N
				8'h44: char_ascii = 8'h4f;	// O
				8'h4d: char_ascii = 8'h50;	// P
				8'h15: char_ascii = 8'h51;	// Q
				8'h2d: char_ascii = 8'h52;	// R
				8'h1b: char_ascii = 8'h53;	// S
				8'h2c: char_ascii = 8'h54;	// T
				8'h3c: char_ascii = 8'h55;	// U
				8'h2a: char_ascii = 8'h56;	// V
				8'h1d: char_ascii = 8'h57;	// W
				8'h22: char_ascii = 8'h58;	// X
				8'h35: char_ascii = 8'h59;	// Y
				8'h1a: char_ascii = 8'h5a;	// Z
			endcase
		end else begin // Lower case letters
			case (scancode)
				8'h1c: char_ascii = 8'h61;	// a
				8'h32: char_ascii = 8'h62;	// b
				8'h21: char_ascii = 8'h63;	// c
				8'h23: char_ascii = 8'h64;	// d
				8'h24: char_ascii = 8'h65;	// e
				8'h2b: char_ascii = 8'h66;	// f
				8'h34: char_ascii = 8'h67;	// g
				8'h33: char_ascii = 8'h68;	// h
				8'h43: char_ascii = 8'h69;	// i
				8'h3b: char_ascii = 8'h6a;	// j
				8'h42: char_ascii = 8'h6b;	// k
				8'h4b: char_ascii = 8'h6c;	// l
				8'h3a: char_ascii = 8'h6d;	// m
				8'h31: char_ascii = 8'h6e;	// n
				8'h44: char_ascii = 8'h6f;	// o
				8'h4d: char_ascii = 8'h70;	// p
				8'h15: char_ascii = 8'h71;	// q
				8'h2d: char_ascii = 8'h72;	// r
				8'h1b: char_ascii = 8'h73;	// s
				8'h2c: char_ascii = 8'h74;	// t
				8'h3c: char_ascii = 8'h75;	// u
				8'h2a: char_ascii = 8'h76;	// v
				8'h1d: char_ascii = 8'h77;	// w
				8'h22: char_ascii = 8'h78;	// x
				8'h35: char_ascii = 8'h79;	// y
				8'h1a: char_ascii = 8'h7a;	// z
			endcase
		end // Upper vs. Lower case letters

		// Special characters if shift is pressed
		if (shift) begin
			case (scancode)
				8'h16: char_ascii = 8'h21;	// !
				8'h52: char_ascii = 8'h22;	// "
				8'h26: char_ascii = 8'h23;	// #
				8'h25: char_ascii = 8'h24;	// $
				8'h2e: char_ascii = 8'h25;	// %
				8'h3d: char_ascii = 8'h26;	// &
				8'h46: char_ascii = 8'h29;	// (
				8'h45: char_ascii = 8'h2a;	// )
				8'h3e: char_ascii = 8'h2b;	// *
				8'h55: char_ascii = 8'h2c;	// +
				8'h4c: char_ascii = 8'h3a;	// :
				8'h41: char_ascii = 8'h3c;	// <
				8'h49: char_ascii = 8'h3e;	// >
				8'h4a: char_ascii = 8'h3f;	// ?
				8'h1e: char_ascii = 8'h40;	// @
				8'h36: char_ascii = 8'h5e;	// ^
				8'h4e: char_ascii = 8'h5f;	// _
				8'h54: char_ascii = 8'h7b;	// {
				8'h5d: char_ascii = 8'h7c;	// |
				8'h5b: char_ascii = 8'h7d;	// }
				8'h0e: char_ascii = 8'h7d;	// ~
			endcase
		end else begin // Nums / no-shift special characters
			case (scancode)
				8'h45: char_ascii = 8'h30;	// 0
				8'h16: char_ascii = 8'h31;	// 1
				8'h1e: char_ascii = 8'h32;	// 2
				8'h26: char_ascii = 8'h33;	// 3
				8'h25: char_ascii = 8'h34;	// 4
				8'h2e: char_ascii = 8'h35;	// 5
				8'h36: char_ascii = 8'h36;	// 6
				8'h3d: char_ascii = 8'h37;	// 7
				8'h3e: char_ascii = 8'h38;	// 8
				8'h46: char_ascii = 8'h39;	// 9

				8'h52: char_ascii = 8'h27;	// '
				8'h55: char_ascii = 8'h3d;	// =
				8'h4c: char_ascii = 8'h3b;	// ;
				8'h41: char_ascii = 8'h2c;	// ,
				8'h49: char_ascii = 8'h2e;	// .
				8'h4a: char_ascii = 8'h2f;	// /
				8'h4e: char_ascii = 8'h2d;	// -
				8'h54: char_ascii = 8'h5b;	// [
				8'h5d: char_ascii = 8'h5c;	// \
				8'h5b: char_ascii = 8'h5d;	// ]
				8'h0e: char_ascii = 8'h60;	// `
			endcase
		end // Nums/special characters w/ and w/o shift

		case (scancode)
			8'h76: char_ascii = 8'h1b;	// (esc)
			8'h5a: char_ascii = 8'h0d;	// (enter)
			8'h29: char_ascii = 8'h20;	// (space)
			8'h66: char_ascii = 8'h08;	// (backspace)
			8'h0d: char_ascii = 8'h09;	// (tab)

			8'h75: char_ascii = 8'h11;	// (up arrow)
			8'h6b: char_ascii = 8'h12;	// (left arrow)
			8'h72: char_ascii = 8'h13;	// (down arrow)
			8'h74: char_ascii = 8'h14;	// (right arrow)
		endcase // case(scancode)
	end // conversion table
endmodule // scan_to_ascii.v
