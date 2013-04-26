`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:18:41 02/11/2008 
// Design Name: 
// Module Name:    game_logic 
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
module main_logic(clk, rst, up, down, left, right, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b);
    input clk;
    input rst;
    input up;
    input down;
	 input left;
	 input right;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
    output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 
	 wire tick_cycle;
	 wire [19:0] tick_counter;
	 
	 wire [31:0] debug0;
	 wire [31:0] debug1;
	 wire [31:0] debug2;
	 
	 draw_logic draw1(clk, rst, pixel_x, pixel_y,  
	                  pixel_r, pixel_g, pixel_b,debug0, debug1, debug2);
							
		toplevel DUT(.clk(clk), .rst(rst));					
     


endmodule
