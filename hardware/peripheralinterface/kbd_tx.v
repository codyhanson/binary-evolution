/*
Module:				kbd_tx

Description:		Empty interface. Just sends signals through to ps2_tx

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/06/2011

*/

`timescale 1ns / 1ps
module kbd_tx(
	input clk, rst,		// System clock and reset
	input tx_en,		// Enables PS/2 transmitting
	inout ps2_data,	// PS/2 data line -- we only drive it
	inout ps2_clk,		// PS/2 clock. Need to read and drive it
	input tbr,			// Signals data was received (1-clk tick)
	input [7:0] data,	// The data to transmit
	output sent,

	// DEBUG
	output [1:0] dbg1,
	output [3:0] dbg2
	);

	// Instantiate Submodules
	ps2_tx ps2_TX1(clk, rst, tx_en, ps2_data, ps2_clk, tbr, data, sent, dbg1, dbg2);

endmodule // kbd_cntrl.v
