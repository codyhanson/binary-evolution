`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:18 02/17/2008 
// Design Name: 
// Module Name:    draw_logic 
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
`define PADDLE_WIDTH 10'd8
`define PADDLE_HEIGHT 10'd48
`define BALL_WIDTH 10'd16
`define BALL_HEIGHT 10'd16

`define PLAY_TOP 10'd8
`define PLAY_BOTTOM 10'd471
`define PLAY_LEFT 10'd8
`define PLAY_RIGHT 10'd631

module draw_logic(clk, rst, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b,multiplier, multiplicand, product);
    input clk;
    input rst;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
	 input [31:0] multiplier;
    input [31:0] multiplicand;
	 input [31:0] product;
	 
    output reg [7:0] pixel_r;
    output reg [7:0] pixel_g;
    output reg [7:0] pixel_b;
	 
	 reg [3:0] cur_prod_digit;
	 reg [3:0] cur_multiplier_digit;
	 reg [3:0] cur_multiplicand_digit;
	 wire [11:0] rom_addr;
	 wire [23:0] rom_color;
	 
	 always@(*)
		case(pixel_x[6:4]) 
			3'h0: begin
			      cur_prod_digit = product[31:28];
					cur_multiplier_digit = multiplier[31:28];
					cur_multiplicand_digit = multiplicand[31:28];
			      end
			3'h1: begin
			      cur_prod_digit = product[27:24];
					cur_multiplier_digit = multiplier[27:24];
					cur_multiplicand_digit = multiplicand[27:24];
			      end
			3'h2: begin
			      cur_prod_digit = product[23:20];
					cur_multiplier_digit = multiplier[23:20];
					cur_multiplicand_digit = multiplicand[23:20];
			      end
			3'h3: begin
			      cur_prod_digit = product[19:16];
					cur_multiplier_digit = multiplier[19:16];
					cur_multiplicand_digit = multiplicand[19:16];
			      end
			3'h4: begin
			      cur_prod_digit = product[15:12];
					cur_multiplier_digit = multiplier[15:12];
					cur_multiplicand_digit = multiplicand[15:12];
			      end
			3'h5: begin
			      cur_prod_digit = product[11:8];
					cur_multiplier_digit = multiplier[11:8];
					cur_multiplicand_digit = multiplicand[11:8];
			      end
			3'h6: begin 
			      cur_prod_digit = product[7:4];
					cur_multiplier_digit = multiplier[7:4];
					cur_multiplicand_digit = multiplicand[7:4];
			      end
			3'h7: begin
			      cur_prod_digit = product[3:0];
					cur_multiplier_digit = multiplier[3:0];
					cur_multiplicand_digit = multiplicand[3:0];
			      end
			default: begin 
			         cur_prod_digit = 0;
						cur_multiplier_digit = 0;
					   cur_multiplicand_digit = 0;
			         end
	   endcase
		
		
    wire [3:0] next_pixy;
	 wire [3:0] next_pixx;
	 wire [3:0] cur_digit;
	 
	 assign next_pixy = pixel_y+4'h1;
	 assign next_pixx = pixel_x+4'h1;
    
	 assign cur_digit = (pixel_y<15) ? cur_multiplier_digit : ( pixel_y<31 ? cur_multiplicand_digit : cur_prod_digit); 
	 assign rom_addr = {next_pixy,cur_digit,next_pixx};
	 
    simple_rom #(12,24,"numbers.mem") num_rom(clk, rom_addr, rom_color);

    always@(*) begin
	   pixel_r = 8'h00;
		pixel_g = 8'h00;
		pixel_b = 8'h00;
		if(~rst) begin
		  if(pixel_x < 128 && pixel_y==31) begin
				pixel_r = 8'hC0;
				pixel_g = 8'hC0;
				pixel_b = 8'hFF;
		  end else if(pixel_x<128 && pixel_y <48) begin
				pixel_r = rom_color[23:16];
				pixel_g = rom_color[15:8];
				pixel_b = rom_color[7:0];
		  end
		end
	 end
	 
	 
endmodule
