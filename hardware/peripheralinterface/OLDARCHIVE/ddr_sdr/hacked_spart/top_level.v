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
    input [1:0] br_cfg, // Baud Rate Configuration, Tied to dip switches 2 and 3
	 	//DRAM signals to top level for ucf
	output wire		sdr_clk,
	output wire		sdr_clk_n, cke_q, we_qn, ras_qn, cas_qn, cs_qn,
	output wire[1:0]	ba_q,
	output wire[7:0]	dqs_q, dm_q,
	output wire[13:0]	a_q,
	inout wire[63:0]	 data
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
		.databus(databus),
		// DDR SDRAM external signals
		.sdr_clk(sdr_clk),	       //| OUT |  DDR SDRAM Clock
		.sdr_clk_n(sdr_clk_n),	     //| OUT |  Inverted DDR SDRAM Clock
		.cke_q(cke_q),	         //| OUT |  DDR SDRAM clock enable
		.cs_qn(cs_qn),	         //| OUT |  DDR SDRAM /chip select
		.ras_qn(ras_qn),	        //| OUT |  DDR SDRAM /ras
		.cas_qn(cas_qn),	        //| OUT |  DDR SDRAM /cas
		.we_qn(we_qn),	         //| OUT |  DDR SDRAM /write enable
		.dm_q(dm_q),	          //| OUT |  DDR SDRAM data mask bits, all set to "0"
		.dqs_q(dqs_q),	         //| OUT |  DDR SDRAM data strobe, used only for write operations
		.ba_q(ba_q),	          //| OUT |  DDR SDRAM bank select
		.a_q(a_q),	           //| OUT |  DDR SDRAM address bus 
		.data(data)	          //| INOUT |  DDR SDRAM bidirectional data bus   
	);

				 
endmodule
