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
    output txd,        // RS232 Transmit Data
    input rxd,         // RS232 Recieve Data
    input [1:0] br_cfg // Baud Rate Configuration, Tied to dip switches 2 and 3
    );
	
	wire iocs;
	wire iorw;
	wire rda;
	wire tbr;
	wire [1:0] ioaddr;
	wire [7:0] databus;
	
	// Instantiate your SPART here
	spart spart0( .clk(clk),
		.rst(rst),
		.iocs(iocs),
		.iorw(iorw),
		.rda(rda),
		.tbr(tbr),
		.ioaddr(ioaddr),
		.databus(databus),
		.txd(txd),
		.rxd(rxd)
		);

	// Instantiate your driver here
	driver driver0( .clk(clk),
		.rst(rst),
		.br_cfg(br_cfg),
		.iocs(iocs),
		.iorw(iorw),
		.rda(rda),
		.tbr(tbr),
		.ioaddr(ioaddr),
		.databus(databus)
		);
				 
endmodule
