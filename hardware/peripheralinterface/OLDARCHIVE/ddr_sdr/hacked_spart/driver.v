`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 554
// Engineer: Cody Hanson, Ross Nordstrom
// 
// Create Date: Jan 31, 2011   
// Design Name: SPART
// Module Name:    driver 
// Target Devices: Xilinx Virtex-2P
//
// This module is designed to echo back characters recieved from the Spart
//  back to the spart
//  hacked to write/read memory 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output reg iorw,
    input rda,	
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus,
	//ram signals to top level
    	output wire		sdr_clk,	//feedback
	output wire		sdr_clk_n, cke_q, we_qn, ras_qn, cas_qn, cs_qn,
	output wire[1:0]	ba_q,
	output wire[7:0]	dqs_q, dm_q,
	output wire[13:0]	a_q,
	inout wire[63:0]	 data
    );

    	//SPART regs
	reg [7:0] databus_reg;
	reg [1:0] state,state_next;
	reg [7:0] rcv_buf, rcv_buf_next; //latch value from rx here before sending out on databus to tx
	reg data_en;
	reg [7:0] brg_hi,brg_lo;


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


	//states
	localparam SETUPBRGHI = 3'b000;
	localparam SETUPBRGLO = 3'b001;
	localparam WAITFORRDA = 3'b010;
	localparam WAITFORTDR = 3'b011;
	localparam WAITRAMRD = 3'b100;
	localparam WAITRAMRDA = 3'b101;
	localparam WAITRAMWR = 3'b110;
	localparam WAITRAMTDR = 3'b111;


	//DRAM regs, params and instantiation
	localparam	DRAMNOP = 2'b00;
	localparam	DRAMRD = 2'b01;
	localparam	DRAMWR = 2'b10;
	// RAM iface 
	/*	declared as ports
	wire		sdr_clk;	//feedback
	wire		sdr_clk_n, cke_q, we_qn, ras_qn, cas_qn, cs_qn;
	wire[1:0]	dqs_q, ba_q,dm_q;
	wire[12:0]	a_q;
	wire[15:0]	 data;
	*/

	// user iface
	reg		cmd_vld, cmd_vld_next;
	reg[1:0]	cmd, cmd_next;
	wire[27:0]	useraddr;	//input to mem
	wire[127:0]	data_in;	//input to mem
	wire 		rambusy, data_req_q, data_vld_q;
	wire[127:0]	data_out_q;


	ddr_sdr ramctl(
	// Clock and RESET signals
		.rst_n(~rst),	         //| IN  |  external asynchronous reset, low active	
		.clk(clk),	           //| IN  |  system clock (e.g. 100MHz), from fpga pad
		.sys_rst_qn(),	    //| OUT |  sync reset low active, released after DCMs are locked,
		                           // may be used by other modules inside the FPGA                     
		.sys_clk_out(),	   //| OUT |  system clock, dcm output, may be used by other modules 
		                           // inside the FPGA as global clock                        
		.clk_fb(sdr_clk),	        //| IN  |  DCM feedback clock, must be external connected to ddr_sdr_clk !	
		// User Interface signals
		.cmd(cmd),	           //| IN  |  User command: READ, WRITE, NOP
		.cmd_vld(cmd_vld),	       //| IN  |  User command valid (if '1')
		.addr(useraddr),	          //| IN  |  User address, contains (ROW & BANK & COL), see Address Mapping 
		.busy_q(rambusy),	        //| OUT |  Controller busy flag, commands are ignored when active
		// Data Interface
		.data_in(data_in),	       //| IN  |  User input data (written to DDR SDRAM)
		.data_req_q(data_req_q),	    //| IN |  User data request, controls input data flow
		.data_out_q(data_out_q),	    //| OUT |  User data output (read from DDR SDRAM)
		.data_vld_q(data_vld_q),	    //| OUT |  data_out_q is valid when '1'
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
		.data(data),	          //| INOUT |  DDR SDRAM bidirectional data bus                    
		// Status signals
		.dcm_error_q()	   //| OUT |  Indicates DCM Errors
	);
	/*
	mt46v16m16 memsim(	//SIMULATION ONLY 
		    .dq(data),
		    .dqs(dqs_q),
		    .addr(a_q),
		    .ba(ba_q),
		    .clk(sdr_clk),
		    .clk_n(sdr_clk_n),
		    .cke(cke_q),
		    .cs_n(cs_qn),
		    .ras_n(ras_qn),
		    .cas_n(cas_qn),
		    .we_n(we_qn),
		    .dm(dm_q)
	);
	*/

	//RAM special input magic
	reg[7:0]	useraddrbottom, useraddrbottom_next;
	assign data_in={8{8'b01001100, rcv_buf}};
	assign useraddr={23'b0, useraddrbottom, 1'b0};



	always @(posedge clk) begin
		if (rst == 1'b1)begin
			state <= 2'b00;
			rcv_buf <= 8'h00;
			useraddrbottom <= 8'b0;
			cmd <= DRAMNOP;
			cmd_vld <= 1'b0;

		end
		else begin
			state <= state_next;
			rcv_buf <= rcv_buf_next;
			useraddrbottom <= useraddrbottom_next;
			cmd <= cmd_next;
			cmd_vld <= cmd_vld_next;
		end
	end	

	reg[1:0] count, count_next;	//counts >=2 clk cycles
	always @(*) begin
		//defaults
		rcv_buf_next = rcv_buf;
		iorw = 1'b1;
		ioaddr = 2'b01;
		databus_reg = 8'h00;

		count_next = 2'b0;
		cmd_vld_next = 1'b0;
		cmd_next = DRAMNOP;
		useraddrbottom_next = 8'hff;	//sentinel val


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
			if (rda == 1'b0) begin
				//RX not ready yet
				state_next = WAITFORRDA;

			end
			else begin
				if(databus > 8'h60) state_next = WAITRAMRD;	//lowercase input: read at this input
				else	state_next = WAITRAMWR;		//uppercase input: write self at lowercase value

				ioaddr = IOADDR_RXTX;
				iorw = 1'b1;//read
				rcv_buf_next = databus; //save byte that was just recieved.
			end
		end
		WAITFORTDR:begin
			if(tbr == 1'b0) begin
				//TX is busy
				state_next = WAITFORTDR;
			end
			else begin
				state_next = WAITFORRDA;
				ioaddr = IOADDR_RXTX;
				iorw = 1'b0;//write
				databus_reg = rcv_buf; //write byte out to TX
				//databus_reg = 8'h55;
			end

		end
		//DRAM states
		WAITRAMRD:begin
			if(rambusy == 1'b1) begin
				//RAM is busy
				state_next = WAITRAMRD;
			end
			else begin
				state_next = WAITRAMRDA;
				cmd_next = DRAMRD;
				useraddrbottom_next = rcv_buf;
				cmd_vld_next = 1'b1;
			end

		end
		WAITRAMRDA:begin
			if(data_vld_q == 1'b0) begin
				//RAM is still reading
				state_next = WAITRAMRDA;
			end
			else begin
				state_next = WAITFORTDR;
				rcv_buf_next <= data_out_q[7:0];
			end

		end

		WAITRAMWR:begin
			if(rambusy == 1'b1) begin
				//RAM is busy
				state_next = WAITRAMWR;
			end
			else begin
				state_next = WAITFORTDR;
				useraddrbottom_next = rcv_buf + 8'h60;
				cmd_next = DRAMWR;
				cmd_vld_next = 1'b1;
				//databus_reg = 8'h55;
			end

		end
		WAITRAMTDR:begin
			if(count != 2'b11) begin
				//RAM is still preparing to write
				state_next = WAITRAMTDR;
				count_next = count + 2'b01;
			end
			else begin
				state_next = WAITFORTDR;
				//controller has clocked in write data
				//rcv_buf still has received char
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
