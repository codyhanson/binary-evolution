`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: ECE 554
// Engineer: Cody Hanson, Ross Nordstrom
// 
// Create Date: Jan 31, 2011   
// Design Name: SPART
// Module Name:   spart
// Target Devices: Xilinx Virtex-2P
//
// This module is the  top level for the spart, instantiates rx, tx, brg, and implements
// tri state bus logic
//////////////////////////////////////////////////////////////////////////////////
module spart(
	input clk,
	input rst,
	input iocs,
	input iorw,
	output rda,
	output tbr,
	input [1:0] ioaddr,
	inout [7:0] databus,
	output txd,
	input rxd
	);

	wire [7:0] rx_databus;
	wire brg_en, brg_full;
	reg clear_rda;
	reg rx_tri_en, status_tri_en;

	// Instantiate sub-modules
	brg_spart brg(.databus(databus), .clk(clk), .rst(rst),
		.brg_en(brg_en),.brg_full(brg_full),.ioaddr(ioaddr));

	tx_spart tx(.databus(databus),.clk( clk),.rst( rst),.tbr(tbr),
		.brg_full(brg_full),.txd(txd),.ioaddr(ioaddr),.iorw(iorw));

	rx_spart rx(.databus(rx_databus), .clk(clk), .rst(rst),.rda(rda),
		.rxd(txd),.brg_en(brg_en),.clear_rda(clear_rda));

	/////////////////////
	// Bus Interface
	/////////////////////
	//enable tri states for RX and Status to drive the bus when appropriate
	always @(*) begin
		rx_tri_en = 1'b0;
		status_tri_en = 1'b0;
		clear_rda = 1'b0;

		if (ioaddr == 2'b00 && iorw == 1'b1) begin
			rx_tri_en = 1'b1;
			clear_rda = 1'b1;
		end
		if (ioaddr == 2'b01 && iorw == 1'b1) 
			status_tri_en = 1'b1;
	end

	assign databus = rx_tri_en ? rx_databus : 
		(status_tri_en ? {6'h00,tbr,rda}: 8'hzz);

	/////////////////////
	// End of Bus Interface
	/////////////////////



endmodule

