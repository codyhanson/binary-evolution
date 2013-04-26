`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 554
// Engineer: Cody Hanson, Ross Nordstrom
// 
// Create Date:   
// Design Name: SPART Miniproject
// Module Name:   tx_spart 
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

module tx_spart_parity(
	output txd,
	output reg tbr,
	input clk,rst,
	input iorw,
	input brg_full, //goes high once every baud
	input [7:0] databus,
	input [1:0] ioaddr);

	reg [10:0] tx_shift_reg,tx_shift_reg_next; 

	localparam IDLE = 1'b0;
	localparam TRANSMITTING = 1'b1;

	reg state, state_next;

	//count to 10
	reg [3:0] tx_count,tx_count_next;

	always @(posedge clk) begin
		if (rst == 1'b1) begin
			state <= 1'b0;
			tx_count <= 4'h0;
			tx_shift_reg <= 11'hFFF;
		end
		else begin
			state <= state_next;
			tx_count <= tx_count_next;
			tx_shift_reg <= tx_shift_reg_next;
		end

	end

	always @(*) begin
		//defaults
		tx_count_next = tx_count;
		tx_shift_reg_next = tx_shift_reg;
		
	
		case (state) 
			IDLE: begin
				tbr = 1'b1; //ready to transmit again	
				tx_count_next = 4'd0;
				if (ioaddr == 2'b00 && iorw == 1'b0) begin 
					state_next = TRANSMITTING;
					// parity bit, data, start bit
					tx_shift_reg_next = {^databus[7:0],databus,2'b01};
					tx_count_next = 4'h0;
				end
				else begin
					//stay in idle state
					state_next = IDLE;
				end
			end
			TRANSMITTING: begin
				tbr = 1'b0;//busy	
				if (tx_count == 4'd12) begin
					state_next = IDLE;
				end
				else begin
					//remain in state, not done yet.
					state_next = TRANSMITTING;
				end
				if (brg_full == 1'b1)begin
					//we've waited a full baud! send out another bit! they'll be so excited.
					//1 bit shift right, shifting in 1 to MSB
					tx_shift_reg_next = {1'b1,tx_shift_reg[10:1]};
					tx_count_next = tx_count + 1;
				end
			end
		endcase
	end

	
	assign txd = tx_shift_reg[0];

endmodule
