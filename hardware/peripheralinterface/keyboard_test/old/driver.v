/*
Module:				driver

Description:		drives the SPART/Keyboard interaction logic for sending
					received keyboard inputs to the terminal via a SPART

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:		Ross Nordstrom, Cody Hanson
Edited by:		
Module interface by:	

Date:	02/25/2011

*/

`timescale 1ns / 1ps
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output reg iorw,
    input kbd_rda,
	output reg clear_kbd,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus,
    inout [7:0] kbd_databus
    );

	reg [7:0] databus_reg;
	reg [1:0] state,state_next;
	reg [7:0] rcv_buf, rcv_buf_next; //latch value from rx here before sending out on databus to tx
	reg data_en;
	reg [7:0] brg_hi,brg_lo;
	reg next_clear_kbd;

	//states
	localparam SETUPBRGHI = 2'b00;
	localparam SETUPBRGLO = 2'b01;
	localparam WAITFORRDA = 2'b10;
	localparam WAITFORTDR = 2'b11;

	//values defined for 100MHz operation
	//100M/(16*4800)-1, rounded = 1301_10 = 0x0515
	localparam BRG_HI_4800 =  8'h05; 
	localparam BRG_LO_4800 =  8'h15;

	//100M/(16*9600)-1, rounded = 650_10 = 0x028a
	localparam BRG_HI_9600 = 8'h02;
	localparam BRG_LO_9600 = 8'h8a;

	//100M/(16*19200)-1, rounded = 325_10 = 0x0145
	localparam BRG_HI_19200 = 8'h01;
	localparam BRG_LO_19200 = 8'h45;

	//100M/(16*38400)-1, rounded = 162_10 = 0x00a2
	localparam BRG_HI_38400 = 8'h00;
	localparam BRG_LO_38400 = 8'ha2;

	//DIP switch configuration codes
	localparam BRG_CFG_4800 = 2'b00;
	localparam BRG_CFG_9600 = 2'b01;
	localparam BRG_CFG_19200 = 2'b10;
	localparam BRG_CFG_38400 = 2'b11;

	//IO addressing for SPART
	localparam IOADDR_RXTX = 2'b00;
	localparam IOADDR_STATUS = 2'b01;
	localparam IOADDR_BRG_DB_LO = 2'b10;
	localparam IOADDR_BRG_DB_HI = 2'b11;


	always @(posedge clk) begin
		if (rst == 1'b1)begin
			state <= 2'b00;
			rcv_buf <= 8'h00;
			clear_kbd <= 1'b0;
		end
		else begin
			state <= state_next;
			rcv_buf <= rcv_buf_next;
			clear_kbd <= next_clear_kbd;
		end
	end	

	always @(*) begin
		//defaults
		rcv_buf_next = rcv_buf;
		iorw = 1'b1;
		ioaddr = 2'b01;
		databus_reg = 8'h00;
		next_clear_kbd = 1'b0;

		case (state) 
		SETUPBRGHI:begin
			//write to the brg_hi
			ioaddr = IOADDR_BRG_DB_HI;
			databus_reg = brg_hi;
			state_next = SETUPBRGLO;
		end
		SETUPBRGLO:begin
			//write to the brg_lo
			ioaddr = IOADDR_BRG_DB_LO;
			databus_reg = brg_lo;
			state_next = WAITFORRDA; //transmit first
	
		end
		WAITFORRDA:begin
			if (kbd_rda == 1'b0) begin
				// No input from keyboard yet
				state_next = WAITFORRDA;
			end
			else begin
				state_next = WAITFORTDR;
				ioaddr = IOADDR_RXTX;
				iorw = 1'b1;//read

				rcv_buf_next = kbd_databus;

			end

		end
		WAITFORTDR:begin
			if(tbr == 1'b0) begin
				//TX is busy
				state_next = WAITFORTDR;
			end
			else begin	// TX is done
				state_next = WAITFORRDA;
				ioaddr = IOADDR_RXTX;
				next_clear_kbd = 1'b1;

				// Ignore Ack/Key Released / etc... commands for now
				if(1) begin
					iorw = 1'b0;//write
//					databus_reg = rcv_buf; //echo keyboard input to terminal

					if (rcv_buf == 8'hF0)	// Break code (used whenever you release a key)
						databus_reg = 8'h21;	// '!'
					else
						databus_reg = 8'h2d; //default to '-'
					// Decode the keys
					case (rcv_buf)
						8'h1d:begin		// 'w'
							databus_reg = 8'h77;
						end
						8'h1c:begin		// 'a'
							databus_reg = 8'h61;
						end
						8'h1b:begin		// 's'
							databus_reg = 8'h73;
						end
						8'h23:begin		// 'd'
							databus_reg = 8'h64;
						end
						8'h12:begin		// <shift>
							databus_reg = 8'h5f;	// '_'
						end
						default:begin	
							databus_reg = 8'h2d;	// '-'
						end
					endcase

				end

			end
		end
		endcase
	end

	//Decode dip switch input to determine baud rate
	always @(*) begin
		case (br_cfg) 
		BRG_CFG_4800: begin
			brg_hi = BRG_HI_4800;			
			brg_lo = BRG_LO_4800;
		end
		BRG_CFG_9600: begin
			brg_hi = BRG_HI_9600;			
			brg_lo = BRG_LO_9600;
		end
		BRG_CFG_19200: begin
			brg_hi = BRG_HI_19200;			
			brg_lo = BRG_LO_19200;
		end
		BRG_CFG_38400: begin
			brg_hi = BRG_HI_38400;			
			brg_lo = BRG_LO_38400;
		end
		endcase
	end

	//bus tristate logic
	always @(*) begin
		data_en = 1'b0;
		//enable if writing out a byte to the spart
		//or are writing to the brg
		if(iorw == 1'b0 || ioaddr[1] == 1'b1)
			data_en = 1'b1;
	end

	assign databus = data_en ? databus_reg : 8'hzz;
	assign iocs = 1'b1;

endmodule
