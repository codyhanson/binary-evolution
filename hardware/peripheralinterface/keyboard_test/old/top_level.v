`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    top_level 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_level(
    input clk,         // 100mhz clock
    input rst,         // Asynchronous reset, tied to dip switch 0
	input kbd_clk,		// Keyboard's clock
	input kbd_data,		// Keyboard's serial data line
    output txd,        // RS232 Transmit Data
    input rxd,         // RS232 Recieve Data
    input [1:0] br_cfg // Baud Rate Configuration, Tied to dip switches 2 and 3
    );
	
	wire iocs;
	wire iorw;
	wire rda;
	wire kbd_rda;
	wire tbr;
	wire [1:0] ioaddr;
	wire [7:0] databus;
	wire [7:0] kbd_databus;
	wire clear;
	
	// Instantiate KEYBOARD I/O here
	kbd_rx kbd0 (clk, rst, kbd_clk, kbd_data, kbd_rda, kbd_databus);

	// Instantiate your SPART here
	spart spart0( clk, rst, iocs, iorw, rda, tbr, ioaddr, databus, txd, rxd);

	// Intantiate driver here
	driver driver0(clk, rst, br_cfg, iocs, iorw, kbd_rda,
					clear, tbr, ioaddr, databus, kbd_databus);
endmodule
