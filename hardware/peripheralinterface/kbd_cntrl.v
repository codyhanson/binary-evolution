/*
Module:				kbd_cntrl

Description:		

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom
Edited by:		
Module interface by:	

Date:	03/05/2011

*/

`timescale 1ns / 1ps
module kbd_cntrl(
    input clk,
    input rst,
	inout kbd_data,
	inout kbd_clk,
	output reg [7:0]	data_out,	// The data that was read from the kbd
	output reg			rda_out,	// Signal pulse that data is ready from the kbd
	output reg [7:0] 	tx_data	// Data to write to the keyboard
    );

	localparam SET_LED = 2'b00;
	localparam LED_VAL = 2'b01;
	localparam RECEIVE = 2'b10;

	reg [1:0] state;	// Controller state
    wire [7:0] rx_data;	// Ascii data from RX
    reg [7:0] next_tx_data;
	wire rda;			// RX data ready 
	reg tbr, next_tbr;	// Data ready for TX to write
	wire sent;			// TX data has been sent
	reg tx_rx;			// 1 - TX mode, 0 - RX mode
	reg caps;			// Capslock status

	reg ignore_rda;
	reg set_ignore, rst_ignore;
	reg [1:0] next_state;
	wire toggle_caps;	// RX signals TX to toggle capslock LED

	wire rx_enable, tx_enable;
	assign rx_enable = ~tx_rx;
	assign tx_enable = tx_rx;

	kbd_rx kbd_rx0(clk, rst, rx_enable, kbd_data, kbd_clk,
					rda, rx_data, toggle_caps);

	kbd_tx kbd_tx0(clk, rst, tx_enable, kbd_data, kbd_clk,
					tbr, tx_data, sent, dbg1, dbg2);

	always @(posedge clk) begin
		if (rst == 1'b1)begin
			state <= RECEIVE;
			tx_data <= 8'hFF;
			tbr <= 1'b0;
			caps <= 1'b0;
		end
		else begin
			state <= next_state;
			tx_data <= next_tx_data;
			tbr <= next_tbr;

			if (toggle_caps)
				caps <= ~caps;

			if (rda_out) begin
				data_out <= rx_data;
			end else begin
				data_out <= data_out;
			end
		end
	end	

	always @(posedge clk) begin
		if (rst == 1'b1)
			ignore_rda <= 1'b0;
		else if (set_ignore)
			ignore_rda <= 1'b1;
		else if (rst_ignore)
			ignore_rda <= 1'b0;
		else
			ignore_rda <= ignore_rda;
	end

	// FINITE STATE MACHINE
	always @(*) begin
		//defaults
		next_state = state;
		set_ignore = 1'b0;
		rst_ignore = 1'b0;
		rda_out = 1'b0;
		tx_rx = 1'b0;	// RX mode
		next_tx_data = tx_data;
		next_tbr = 1'b0;

		case (state)
			SET_LED:begin
				tx_rx = 1'b1;	// TX mode
				next_tx_data = 8'hED;	// Set status indicators
				next_tbr = 1'b1;

				// Wait until ps2_tx sees the ack bit
				if (sent) begin
					next_state = LED_VAL;
					next_tbr = 1'b0;
				end
			end

			LED_VAL:begin
				tx_rx = 1'b1;	// TX mode
				next_tx_data = {5'd0, ~caps, 1'b0, 1'b1};	// set/rst caps
				next_tbr = 1'b1;

				// Wait until ps2_tx sees the ack bit
				if (sent) begin
					next_state = RECEIVE;
					next_tbr = 1'b0;
				end
			end

			RECEIVE:begin
				tx_rx = 1'b0;	// RX mode

				// Check if caps was hit, and we need to set the LED
//				if (toggle_caps) begin
//					next_state = SET_LED;
//				end

				// Check if we've read anything
				if (rda == 1'b0) begin
					// No input from PS/2 yet
					rst_ignore = 1'b1;
				end
				else if(~ignore_rda) begin
					// Got input from PS/2 device
					set_ignore = 1'b1;
					rda_out = 1'b1;
				end
			end
		endcase
	end // FSM
endmodule // kbd_cntrl.v
