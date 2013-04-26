`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 554
// Engineer: Cody Hanson, Ross Nordstrom
// 
// Create Date:   
// Design Name: SPART Miniproject
// Module Name:   rx_spart 
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

module rx_spart_parity(
	output reg rda,
	input clk,rst,
	input brg_en,// 1/16th of a baud
	input rxd, // the Asynchronous input rxd signal
	input clear_rda,
	output [7:0] databus) ;


	localparam IDLE = 1'b0; //this state continuously samples the line looking for a start bit
	localparam RECIEVING = 1'b1;

	reg state, state_next;

	//count to 8 bits
	reg [3:0] rx_count, rx_count_next;
	reg [3:0] sample_count, sample_count_next;
	reg [3:0] sample_accum,sample_accum_next;
	reg [7:0] rx_shift_reg,rx_shift_reg_next;

	reg rda_next;
	reg rxd_sync,rxd_flop1;

	always @(posedge clk) begin
		if(rst == 1'b1) begin
			rx_shift_reg <= 8'd0;
			state <= 1'b0;
			rx_count <= 4'h0;
			sample_count <= 4'h0;
			sample_accum <= 4'h0;
			rxd_flop1 <= 1'b1;
			rxd_sync <= 1'b1;
			rda <= 1'b0;
		end
		else begin
			rx_shift_reg <= rx_shift_reg_next;
			state <= state_next;
			rx_count <= rx_count_next;
			sample_count <= sample_count_next;
			sample_accum <= sample_accum_next;
			rda <= rda_next;

			//synchronize the rxd line
			//double flop it.
			rxd_flop1 <= rxd;
			rxd_sync <= rxd_flop1;	
			
		end
	end


	always @(*) begin
		//defaults
		sample_accum_next = sample_accum;
		rx_shift_reg_next = rx_shift_reg;
		rx_count_next = rx_count;
		rda_next = rda;
		sample_count_next = sample_count;

		case (state) 
		IDLE: begin
			state_next = IDLE;
			if (clear_rda)
				rda_next = 1'b0;
			if (brg_en) begin
				//Sample the bit. If we haven't detected a negedge, don't accumulate
				if (sample_count == 4'h0) begin
					// Have NOT begun accumulating
					if (rxd_sync == 1'b0) begin
						// MIGHT have found START bit... begin accum
						sample_count_next = 4'h1;
						state_next = IDLE;
						sample_accum_next = 4'h0;
					end
					else begin
						// NO start bit yet...
						sample_count_next = 4'h0;
						state_next = IDLE;
						sample_accum_next = 4'h0;
					end
				end
				else if (sample_count == 4'hF) begin
					sample_accum_next = 4'h0;
					sample_count_next = 4'h0;

					if (sample_accum[3] == 1'b0) begin
						state_next= RECIEVING;
						rx_shift_reg_next = 8'h00;
						rx_count_next = 4'h0;
					end
					else 
						state_next = IDLE;
				end
				
				else begin
					// ACCUMULATE
					sample_count_next = sample_count + 1;
					//sample rxd 16 times/digit, and avg (take MSb)
					sample_accum_next = sample_accum + rxd_sync;
					state_next = IDLE;
				end
			end
		end
		RECIEVING: begin
			rda_next = 1'b0; //byte not ready 

			if (brg_en) begin
				//sample rxd 16 times/digit, and avg (take MSb)
				sample_accum_next = sample_accum + rxd_sync;						
				sample_count_next = sample_count + 1;
			end

			if(brg_en && sample_count == 4'hf) begin
				//acquired a digit - if accum[3] is 1, 1 is majority
				//			else, 0 is majority
				if (rx_count == 4'd9) begin
					// This is the PARITY bit
					// DO NOTHING
				end
				else begin
					//shift it into the rx_shift_reg
					rx_shift_reg_next = {sample_accum[3],rx_shift_reg[7:1]};
				end

				sample_accum_next = 4'h0;
				rx_count_next = rx_count + 1;
			end
				
			if (rx_count == 4'd9)begin
				//have all of our bits
				state_next = IDLE;
				sample_accum_next = 4'h0;
				sample_count_next = 4'h0;

				// Check the parity
				if (sample_accum[3] == (^rx_shift_reg[7:0]))
					rda_next = 1'b1;
				else	// invalid parity... don't accept the data
					rda_next = 1'b0;
			end
			else begin
				//keep sampling and shifting bits in
				state_next = RECIEVING;
			end

		end//RECIEVING
		endcase
	end
	assign databus = rx_shift_reg;
endmodule
