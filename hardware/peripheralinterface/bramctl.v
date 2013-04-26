/*
Module:			bramctl

Description:		provides 1cycle rw to bram
Hierarchy:		SYSTEM=>memctl=>bramctl


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	Eric Weisman
Edited by:		
Module interface by:	Eric Weisman

Date:			

*/

/*		TODO
	*
	*	reIMPLEMENT? PRIORITY
	*		@addr, r0 w1 => get old val		automatic
	*		@addr, r1 w0 => get new val
	*		@addr, w1 w0 => write w1 val
	*		can this be done in slow fsm?neighborhoods
	*		whole vs. partial addressing conflicts, must deal with both!
			ex. w0W@x, r1B@(x+4).   how implement this forwarding?
	*
	*	IMPLEMENT arraywidth MMR
	* 
	*	FIX
	*		neig writes (reads?)	
	*
*/

module bramctl(
	input clk, input rst,
	input fastclk,				//4x system clk speed, synchronized.
	//controller end
	input[15:0]	arraywidth,		//for neighborhood calculations. from a MMR.
	input[39:0]	MemAddr0, MemAddr1,
	input[1:0]	mode0, mode1,			//byte(8b), halfword(16b), word(40b), neighborhood(discontiguous 72b)
	input		RW0, RW1,			//write when low
	//provisionally always enabled
	input[39:0]	MemDataIn0, MemDataIn1,
	output[39:0]	MemDataOut0, MemDataOut1
	);


	//PARAMETERS-------------------------------------------------------------------------
	`include "brammodes.inc"


	//BRAM INSTANTIATED ---------------------------------------------------------------
	/*
	 when simult read and write, old data is read. read-before-write.
	 always enabled, reads by default.	 
	 rising edge active.
	*/
	
	reg[7:0]	nextwritedata0[3:0], nextwritedata1[3:0];
	reg[39:0]	nextbram0addr[3:0], nextbram1addr[3:0];
	wire[7:0]	bram0data[3:0], bram1data[3:0];
	reg[3:0]	nextbram0we, nextbram1we;
	

//	dmem_bram_simulator #(40,8) daram0( //For Simulation Only
	dmem0 daram0( //Synthesis Only
		.dina(nextwritedata0[0]),
		.addra(nextbram0addr[0]),
		.wea(nextbram0we[0]),
		.clka(fastclk),
		.douta(bram0data[0]),
		
		.dinb(nextwritedata1[0]),
		.addrb(nextbram1addr[0]),
		.web(nextbram1we[0]),
		.clkb(fastclk),
		.doutb(bram1data[0])
	);
	
//	dmem_bram_simulator #(40,8) daram1( //For Simulation Only
	dmem1 daram1( //Synthesis Only
		.dina(nextwritedata0[1]),
		.addra(nextbram0addr[1]),
		.wea(nextbram0we[1]),
		.clka(fastclk),
		.douta(bram0data[1]),
		
		.dinb(nextwritedata1[1]),
		.addrb(nextbram1addr[1]),
		.web(nextbram1we[1]),
		.clkb(fastclk),
		.doutb(bram1data[1])
	);
	
//	dmem_bram_simulator #(40,8) daram2( //For Simulation Only
	dmem2 daram2( //Synthesis Only
		.dina(nextwritedata0[2]),
		.addra(nextbram0addr[2]),
		.wea(nextbram0we[2]),
		.clka(fastclk),
		.douta(bram0data[2]),
		
		.dinb(nextwritedata1[2]),
		.addrb(nextbram1addr[2]),
		.web(nextbram1we[2]),
		.clkb(fastclk),
		.doutb(bram1data[2])
	);
	
	
//	dmem_bram_simulator #(40,8) daram3( //For Simulation Only
	dmem3 daram3( //Synthesis Only
		.dina(nextwritedata0[3]),
		.addra(nextbram0addr[3]),
		.wea(nextbram0we[3]),
		.clka(fastclk),
		.douta(bram0data[3]),
		
		.dinb(nextwritedata1[3]),
		.addrb(nextbram1addr[3]),
		.web(nextbram1we[3]),
		.clkb(fastclk),
		.doutb(bram1data[3])
	);
	


	//SLOW STATE MACHINE - captures input values ---------------------------------------
	
	reg[1:0]	captmode0, captmode1;
	reg		captRW0, captRW1;
	reg[39:0] 	captdata0, captdata1;	//ignored later iff a read
	reg[39:0] 	captaddr0, captaddr1;
	
	always@(posedge clk) begin
		captmode0 <= mode0;
		captmode1 <= mode1;
		captRW0 <= RW0;
		captRW1	<= RW1;
		captdata0 <= MemDataIn0;
		captdata1 <= MemDataIn1;
		captaddr0 <= MemAddr0;
		captaddr1 <= MemAddr1;
		//arraywidth change assumed to be slow, uncaptured.
	end
	

	//COMBINATIONAL SIGGEN -------------------------------------------------------

	// data outputs
	reg[39:0]	outdata0, outdata1, currentoutdata0, currentoutdata1;
	assign MemDataOut0 = (captmode0==NEIG) ? {8'b0, outdata0[31:0]} : outdata0;	//complete neighborhood formatting combinationally
	assign MemDataOut1 = (captmode0==NEIG) ? {outdata1[39:24], currentoutdata1[23:0]} : currentoutdata1;  //also here if neighborhood read	

	//special neighborhood addresses
	wire[39:0]	MemAddr0minus=MemAddr0-arraywidth;
	wire[39:0]	captaddr0minus=captaddr0-arraywidth;
	wire[39:0]	captaddr0plus=captaddr0+arraywidth;


	//FAST STATE MACHINE- handles all write combining -----------------------------------
	
	reg 	addrsame;	//for priority calcs

	always@(posedge fastclk) begin
		outdata0 <= currentoutdata0;
		outdata1 <= currentoutdata1;
	end
	
	always@(
	 clk, rst,
	 captmode0, captaddr0, captmode1, captaddr1,
	 outdata0, captaddr0plus, captaddr0minus, MemAddr0minus,
	 MemAddr0, mode0, RW0, captRW0, captRW1,
	 MemDataIn0, MemDataIn1, captdata1,
	 bram0data[0], bram0data[1], bram0data[2], bram0data[3], 
	 bram1data[0], bram1data[1], bram1data[2], bram1data[3]
	) begin	//rest filled in by synth, use * for sim
		//defaults
		currentoutdata0 = outdata0;
		currentoutdata1 = 40'hx;
		nextwritedata0[0] = 8'bx;
		nextwritedata0[1] = 8'bx;
		nextwritedata0[2] = 8'bx;
		nextwritedata0[3] = 8'bx;
		nextwritedata1[0] = 8'bx;
		nextwritedata1[1] = 8'bx;
		nextwritedata1[2] = 8'bx;
		nextwritedata1[3] = 8'bx;
		
		nextbram0addr[0] = 8'bx;
		nextbram0addr[1] = 8'bx;
		nextbram0addr[2] = 8'bx;
		nextbram0addr[3] = 8'bx;
		nextbram1addr[0] = 8'bx;
		nextbram1addr[1] = 8'bx;
		nextbram1addr[2] = 8'bx;
		nextbram1addr[3] = 8'bx;	

		//read is harmless
		nextbram0we[3:0]= 4'b0000;
		nextbram1we[3:0]= 4'b0000;
		
		//data and enables massage
		case(clk)
			//PATH 0
			1'b0: begin				
				//read path 1 logic - from this cycle
				//combinational output will use nextvalue directly
				if(captmode0==NEIG) begin
					//neighborhood high part - on bank 0
					case(captaddr0plus[1:0])
					2'b00 : begin
						currentoutdata1[23:16]=bram0data[3];
						currentoutdata1[15:8]=bram0data[0];
						currentoutdata1[7:0]=bram0data[1];
					end
					2'b01 : begin
						currentoutdata1[23:16]=bram0data[0];
						currentoutdata1[15:8]=bram0data[1];
						currentoutdata1[7:0]=bram0data[2];
					end
					2'b10 : begin
						currentoutdata1[23:16]=bram0data[1];
						currentoutdata1[15:8]=bram0data[2];
						currentoutdata1[7:0]=bram0data[3];
					end
					2'b11 : begin
						currentoutdata1[23:16]=bram0data[2];
						currentoutdata1[15:8]=bram0data[3];
						currentoutdata1[7:0]=bram0data[0];
					end
					endcase
				end
				else begin
					case((captmode1))
						WORD : begin
							case(captaddr1[1:0])
								2'b00 : begin
									currentoutdata1={bram0data[0],bram0data[1],bram0data[2],bram0data[3],bram1data[0]};
								end
								2'b01 : begin
									currentoutdata1={bram0data[1],bram0data[2],bram0data[3],bram0data[0],bram1data[1]};
								end
								2'b10 : begin
									currentoutdata1={bram0data[2],bram0data[3],bram0data[0],bram0data[1],bram1data[2]};
								end
								2'b11 : begin
									currentoutdata1={bram0data[3],bram0data[0],bram0data[1],bram0data[2],bram1data[3]};
								end
							endcase
						end
						HALF : begin
							case(captaddr1[1:0])
								2'b00 : begin
									currentoutdata1[15:0]={bram0data[0],bram0data[1]};	//order of indices matters
								end
								2'b01 : begin
									currentoutdata1[15:0]={bram0data[1],bram0data[2]};
								end
								2'b10 : begin
									currentoutdata1[15:0]={bram0data[2],bram0data[3]};
								end
								2'b11 : begin
									currentoutdata1[15:0]={bram0data[3],bram0data[0]};
								end
							endcase
						end
						BYTE : begin
							currentoutdata1[7:0]=bram0data[captaddr1[1:0]];	//still captured from last access!
						end
						//default: begin end //$display("bad0 neighborhood switching");
					endcase
				end
				//setup path 0 logic - for next cycle
				//new values not yet captured. preset combinational for slow clk edge.
				//values will be present before edge.  (enough?)
				
				//setup addresses for modes other than neighborhood
				case(MemAddr0[1:0])
					2'b00 : begin
						nextbram0addr[0]=MemAddr0[39:2];
						nextbram0addr[1]=MemAddr0[39:2];
						nextbram0addr[2]=MemAddr0[39:2];
						nextbram0addr[3]=MemAddr0[39:2];
					end
					2'b01 : begin
						nextbram0addr[0]=MemAddr0[39:2]+38'd1;
						nextbram0addr[1]=MemAddr0[39:2];
						nextbram0addr[2]=MemAddr0[39:2];
						nextbram0addr[3]=MemAddr0[39:2];
					end
					2'b10 : begin
						nextbram0addr[0]=MemAddr0[39:2]+38'd1;
						nextbram0addr[1]=MemAddr0[39:2]+38'd1;
						nextbram0addr[2]=MemAddr0[39:2];
						nextbram0addr[3]=MemAddr0[39:2];
					end
					2'b11 : begin
						nextbram0addr[0]=MemAddr0[39:2]+38'd1;
						nextbram0addr[1]=MemAddr0[39:2]+38'd1;
						nextbram0addr[2]=MemAddr0[39:2]+38'd1;
						nextbram0addr[3]=MemAddr0[39:2];
					end
				endcase
				//word to write generation
				case((mode0))
					WORD : begin
						nextbram0we={~RW0,~RW0,~RW0,~RW0};	//always accessing every path at least once
						//nextbram1we=1'b0;	default behavior reads
						nextbram1addr[0]=MemAddr0[39:2]+38'b1;
						nextbram1addr[1]=MemAddr0[39:2]+38'b1;
						nextbram1addr[2]=MemAddr0[39:2]+38'b1;
						nextbram1addr[3]=MemAddr0[39:2]+38'b1;
						nextwritedata1[0]=MemDataIn0[7:0];
						nextwritedata1[1]=MemDataIn0[7:0];
						nextwritedata1[2]=MemDataIn0[7:0];
						nextwritedata1[3]=MemDataIn0[7:0];
						case(MemAddr0[1:0])
							2'b00 : begin
								nextbram1we[0]=~RW0;
								nextwritedata0[0]=MemDataIn0[39:32];
								nextwritedata0[1]=MemDataIn0[31:24];
								nextwritedata0[2]=MemDataIn0[23:16];
								nextwritedata0[3]=MemDataIn0[15:8];
							end
							2'b01 : begin
								nextbram1we[1]=~RW0;
								nextwritedata0[1]=MemDataIn0[39:32];
								nextwritedata0[2]=MemDataIn0[31:24];
								nextwritedata0[3]=MemDataIn0[23:16];
								nextwritedata0[0]=MemDataIn0[15:8];
							end
							2'b10 : begin
								nextbram1we[2]=~RW0;
								nextwritedata0[2]=MemDataIn0[39:32];
								nextwritedata0[3]=MemDataIn0[31:24];
								nextwritedata0[0]=MemDataIn0[23:16];
								nextwritedata0[1]=MemDataIn0[15:8];
							end
							2'b11 : begin
								nextbram1we[3]=~RW0;
								nextwritedata0[3]=MemDataIn0[39:32];
								nextwritedata0[0]=MemDataIn0[31:24];
								nextwritedata0[1]=MemDataIn0[23:16];
								nextwritedata0[2]=MemDataIn0[15:8];
							end
						endcase
					end //END CASE WORD
					HALF : begin	//finished in this cycle
						case(MemAddr0[1:0])
						2'b00 : begin
							nextbram0we={1'b0,1'b0,~RW0,~RW0};
							nextwritedata0[0] = MemDataIn0[15:8];	//order of indices matters
							nextwritedata0[1] = MemDataIn0[7:0];
						end
						2'b01 : begin
							nextbram0we={1'b0,~RW0,~RW0,1'b0};
							nextwritedata0[1] = MemDataIn0[15:8];
							nextwritedata0[2] = MemDataIn0[7:0];
						end
						2'b10 : begin
							nextbram0we={~RW0,~RW0,1'b0,1'b0};
							nextwritedata0[2] = MemDataIn0[15:8];
							nextwritedata0[3] = MemDataIn0[7:0];
						end
						2'b11 : begin
						   nextbram0we={~RW0,1'b0,1'b0,~RW0};
							nextwritedata0[3] = MemDataIn0[15:8];
							nextwritedata0[0] = MemDataIn0[7:0];
						end
						endcase
					end //END CASE HALF
					BYTE : begin
						nextbram0we[MemAddr0[1:0]] = ~RW0;
						nextwritedata0[MemAddr0[1:0]] = MemDataIn0[7:0];
					end //END CASE BYTE
					NEIG : begin
						//neighborhood low part - on bank 0
						case(MemAddr0minus[1:0])
						2'b00 : begin
							//set enables
							nextbram0we={~RW0,1'b0,~RW0,~RW0};
							//set addrs
							nextbram0addr[3]=MemAddr0minus[39:2]-38'b1;
							nextbram0addr[0]=MemAddr0minus[39:2];
							nextbram0addr[1]=MemAddr0minus[39:2];
							//set data
							nextwritedata0[3]=MemDataIn0[31:24];
							nextwritedata0[0]=MemDataIn0[23:16];
							nextwritedata0[1]=MemDataIn0[15:8];
						end
						2'b01 : begin
							//set enables
							nextbram0we={1'b0,~RW0,~RW0,~RW0};
							//set addrs
							nextbram0addr[0]=MemAddr0minus[39:2];
							nextbram0addr[1]=MemAddr0minus[39:2];
							nextbram0addr[2]=MemAddr0minus[39:2];
							//set data
							nextwritedata0[0]=MemDataIn0[31:24];
							nextwritedata0[1]=MemDataIn0[23:16];
							nextwritedata0[2]=MemDataIn0[15:8];
						end
						2'b10 : begin
							//set enables
							nextbram0we={~RW0,~RW0,~RW0,1'b0};
							//set addrs
							nextbram0addr[1]=MemAddr0minus[39:2];
							nextbram0addr[2]=MemAddr0minus[39:2];
							nextbram0addr[3]=MemAddr0minus[39:2];
							//set data
							nextwritedata0[1]=MemDataIn0[31:24];
							nextwritedata0[2]=MemDataIn0[23:16];
							nextwritedata0[3]=MemDataIn0[15:8];
						end
						2'b11 : begin
							//set enables
							nextbram0we={~RW0,~RW0,1'b0,~RW0};
							//set addrs
							nextbram0addr[2]=MemAddr0minus[39:2];
							nextbram0addr[3]=MemAddr0minus[39:2];
							nextbram0addr[0]=MemAddr0minus[39:2]+38'b1;
							//set data
							nextwritedata0[2]=MemDataIn0[31:24];
							nextwritedata0[3]=MemDataIn0[23:16];
							nextwritedata0[0]=MemDataIn0[15:8];
						end
						endcase
						//neighborhood middle part - on bank 1
						case(MemAddr0[1:0])
						2'b00 : begin
							//set enables
							nextbram1we={~RW0,1'b0,~RW0,~RW0};
							//set addrs
							nextbram1addr[3]=MemAddr0[39:2]-38'b1;
							nextbram1addr[0]=MemAddr0[39:2];
							nextbram1addr[1]=MemAddr0[39:2];
							//set data
							nextwritedata1[3]=MemDataIn1[31:24];
							nextwritedata1[0]=MemDataIn1[39:32];
							nextwritedata1[1]=MemDataIn0[7:0];
						end
						2'b01 : begin
							//set enables
							nextbram1we={1'b0,~RW0,~RW0,~RW0};
							//set addrs
							nextbram1addr[0]=MemAddr0[39:2];
							nextbram1addr[1]=MemAddr0[39:2];
							nextbram1addr[2]=MemAddr0[39:2];
							//set data
							nextwritedata1[0]=MemDataIn1[31:24];
							nextwritedata1[1]=MemDataIn1[39:32];
							nextwritedata1[2]=MemDataIn0[7:0];
						end
						2'b10 : begin
							//set enables
							nextbram1we={~RW0,~RW0,~RW0,1'b0};
							//set addrs
							nextbram1addr[1]=MemAddr0[39:2];
							nextbram1addr[2]=MemAddr0[39:2];
							nextbram1addr[3]=MemAddr0[39:2];
							//set data
							nextwritedata1[1]=MemDataIn1[31:24];
							nextwritedata1[2]=MemDataIn1[39:32];
							nextwritedata1[3]=MemDataIn0[7:0];
						end
						2'b11 : begin
							//set enables
							nextbram1we={~RW0,~RW0,1'b0,~RW0};
							//set addrs
							nextbram1addr[2]=MemAddr0[39:2];
							nextbram1addr[3]=MemAddr0[39:2];
							nextbram1addr[0]=MemAddr0[39:2]+38'b1;
							//set data
							nextwritedata1[2]=MemDataIn1[31:24];
							nextwritedata1[3]=MemDataIn1[39:32];
							nextwritedata1[0]=MemDataIn0[7:0];
						end
						endcase
					end // END CASE NEIG
				endcase
			end
			//LAST CYCLE ---------------------------------------------------------------------------------------
			1'b1 : begin
				//PATH 1

				//read path 0 logic
				case((captmode0))
					WORD : begin
						case(captaddr0[1:0])
							2'b00 : begin
								currentoutdata0={bram0data[0],bram0data[1],bram0data[2],bram0data[3],bram1data[0]};
							end
							2'b01 : begin
								currentoutdata0={bram0data[1],bram0data[2],bram0data[3],bram0data[0],bram1data[1]};
							end
							2'b10 : begin
								currentoutdata0={bram0data[2],bram0data[3],bram0data[0],bram0data[1],bram1data[2]};
							end
							2'b11 : begin
								currentoutdata0={bram0data[3],bram0data[0],bram0data[1],bram0data[2],bram1data[3]};
							end
						endcase
					end
					HALF : begin
						case(captaddr0[1:0])
							2'b00 : begin
								currentoutdata0[15:0]={bram0data[0],bram0data[1]};	//order of indices matters in latter
							end
							2'b01 : begin
								currentoutdata0[15:0]={bram0data[1],bram0data[2]};
							end
							2'b10 : begin
								currentoutdata0[15:0]={bram0data[2],bram0data[3]};
							end
							2'b11 : begin
								currentoutdata0[15:0]={bram0data[3],bram0data[0]};
							end
						endcase
					end
					BYTE : begin
						currentoutdata0[7:0]=bram0data[captaddr0[1:0]];
					end
					NEIG : begin
						//neighborhood low part - on bank 0
						case(captaddr0minus[1:0])
						2'b00 : begin
							currentoutdata0[31:24]=bram0data[3];
							currentoutdata0[23:16]=bram0data[0];
							currentoutdata0[15:8]=bram0data[1];
						end
						2'b01 : begin
							currentoutdata0[31:24]=bram0data[0];
							currentoutdata0[23:16]=bram0data[1];
							currentoutdata0[15:8]=bram0data[2];
						end
						2'b10 : begin
							currentoutdata0[31:24]=bram0data[1];
							currentoutdata0[23:16]=bram0data[2];
							currentoutdata0[15:8]=bram0data[3];
						end
						2'b11 : begin
							currentoutdata0[31:24]=bram0data[2];
							currentoutdata0[23:16]=bram0data[3];
							currentoutdata0[15:8]=bram0data[0];
						end
						endcase
						//neighborhood middle part - on bank 1
						case(captaddr0[1:0])
						2'b00 : begin
							currentoutdata1[31:24]=bram1data[3];
							currentoutdata1[39:32]=bram1data[0];
							currentoutdata0[7:0]=bram1data[1];
						end
						2'b01 : begin
							currentoutdata1[31:24]=bram1data[0];
							currentoutdata1[39:32]=bram1data[1];
							currentoutdata0[7:0]=bram1data[2];
						end
						2'b10 : begin
							currentoutdata1[31:24]=bram1data[1];
							currentoutdata1[39:32]=bram1data[2];
							currentoutdata0[7:0]=bram1data[3];
						end
						2'b11 : begin
							currentoutdata1[31:24]=bram1data[2];
							currentoutdata1[39:32]=bram1data[3];
							currentoutdata0[7:0]=bram1data[0];
						end
						endcase
					end
				endcase
				// setup path 1 logic
				//setup addresses for modes other than neighborhood
				case(captaddr1[1:0])
					2'b00 : begin
						nextbram0addr[3]=captaddr1[39:2];
						nextbram0addr[2]=captaddr1[39:2];
						nextbram0addr[1]=captaddr1[39:2];
						nextbram0addr[0]=captaddr1[39:2];
					end
					2'b01 : begin
						nextbram0addr[0]=captaddr1[39:2]+38'd1;
						nextbram0addr[3]=captaddr1[39:2];
						nextbram0addr[2]=captaddr1[39:2];
						nextbram0addr[1]=captaddr1[39:2];
					end
					2'b10 : begin
						nextbram0addr[0]=captaddr1[39:2]+38'd1;
						nextbram0addr[1]=captaddr1[39:2]+38'd1;
						nextbram0addr[3]=captaddr1[39:2];
						nextbram0addr[2]=captaddr1[39:2];
					end
					2'b11 : begin
						nextbram0addr[0]=captaddr1[39:2]+38'd1;
						nextbram0addr[1]=captaddr1[39:2]+38'd1;
						nextbram0addr[2]=captaddr1[39:2]+38'd1;
						nextbram0addr[3]=captaddr1[39:2];
					end
					endcase
				if(captmode0==NEIG) begin
					//neighborhood high part - on bank 0
					case(captaddr0plus[1:0])
						2'b00 : begin
							//set enables
							nextbram0we={~captRW0,1'b0,~captRW0,~captRW0};
							//set addrs
							nextbram0addr[3]=captaddr0plus[39:2]-38'b1;
							nextbram0addr[0]=captaddr0plus[39:2];
							nextbram0addr[1]=captaddr0plus[39:2];
							//set data
							nextwritedata0[3]=captdata1[23:16];
							nextwritedata0[0]=captdata1[15:8];
							nextwritedata0[1]=captdata1[7:0];
						end
						2'b01 : begin
							//set enables
							nextbram0we={1'b0,~captRW0,~captRW0,~captRW0};
							//set addrs
							nextbram0addr[0]=captaddr0plus[39:2];
							nextbram0addr[1]=captaddr0plus[39:2];
							nextbram0addr[2]=captaddr0plus[39:2];
							//set data
							nextwritedata0[0]=captdata1[23:16];
							nextwritedata0[1]=captdata1[15:8];
							nextwritedata0[2]=captdata1[7:0];
						end
						2'b10 : begin
							//set enables
							nextbram0we={~captRW0,~captRW0,~captRW0,1'b0};
							//set addrs
							nextbram0addr[1]=captaddr0plus[39:2];
							nextbram0addr[2]=captaddr0plus[39:2];
							nextbram0addr[3]=captaddr0plus[39:2];
							//set data
							nextwritedata0[1]=captdata1[23:16];
							nextwritedata0[2]=captdata1[15:8];
							nextwritedata0[3]=captdata1[7:0];
						end
						2'b11 : begin
							//set enables
							nextbram0we={~captRW0,~captRW0,1'b0,~captRW0};
							//set addrs
							nextbram0addr[2]=captaddr0plus[39:2];
							nextbram0addr[3]=captaddr0plus[39:2];
							nextbram0addr[0]=captaddr0plus[39:2]+38'b1;
							//set data
							nextwritedata0[2]=captdata1[23:16];
							nextwritedata0[3]=captdata1[15:8];
							nextwritedata0[0]=captdata1[7:0];
						end
					endcase
				end
				else begin
					case((captmode1))
						WORD : begin
							nextbram0we={~captRW1,~captRW1,~captRW1,~captRW1};	//always accessing every path at least once
							//nextbram1we=1'b0;	default behavior reads
							nextbram1addr[0]=captaddr1[39:2]+38'b1;
							nextbram1addr[1]=captaddr1[39:2]+38'b1;
							nextbram1addr[2]=captaddr1[39:2]+38'b1;
							nextbram1addr[3]=captaddr1[39:2]+38'b1;
							nextwritedata1[0]=captdata1[7:0];
							nextwritedata1[1]=captdata1[7:0];
							nextwritedata1[2]=captdata1[7:0];
							nextwritedata1[3]=captdata1[7:0];
							case(captaddr1[1:0])
								2'b00 : begin
									nextbram1we[0]=~captRW1;
									nextwritedata0[0]=captdata1[39:32];
									nextwritedata0[1]=captdata1[31:24];
									nextwritedata0[2]=captdata1[23:16];
									nextwritedata0[3]=captdata1[15:8];
								end
								2'b01 : begin
									nextbram1we[1]=~captRW1;
									nextwritedata0[1]=captdata1[39:32];
									nextwritedata0[2]=captdata1[31:24];
									nextwritedata0[3]=captdata1[23:16];
									nextwritedata0[0]=captdata1[15:8];
								end
								2'b10 : begin
									nextbram1we[2]=~captRW1;
									nextwritedata0[2]=captdata1[39:32];
									nextwritedata0[3]=captdata1[31:24];
									nextwritedata0[0]=captdata1[23:16];
									nextwritedata0[1]=captdata1[15:8];
								end
								2'b11 : begin
									nextbram1we[3]=~captRW1;
									nextwritedata0[3]=captdata1[39:32];
									nextwritedata0[0]=captdata1[31:24];
									nextwritedata0[1]=captdata1[23:16];
									nextwritedata0[2]=captdata1[15:8];
								end
							endcase
						end //END CASE WORD
						HALF : begin
							case(captaddr1[1:0])
	            					2'b00 : begin
								nextbram0we={1'b0,1'b0,~captRW1,~captRW1};
								nextwritedata0[0] = captdata1[15:8];	//order of indices matters
								nextwritedata0[1] = captdata1[7:0];
							end
							2'b01 : begin
								nextbram0we={1'b0,~captRW1,~captRW1,1'b0};
								nextwritedata0[1] = captdata1[15:8];
								nextwritedata0[2] = captdata1[7:0];
							end
							2'b10 : begin
								nextbram0we={~captRW1,~captRW1,1'b0,1'b0};
								nextwritedata0[2] = captdata1[15:8];
								nextwritedata0[3] = captdata1[7:0];
							end
							2'b11 : begin
							   	nextbram0we={~captRW1,1'b0,1'b0,~captRW1};
								nextwritedata0[3] = captdata1[15:8];
								nextwritedata0[0] = captdata1[7:0];
							end
							endcase
						end //END CASE HALF
						BYTE : begin
							nextbram0we[captaddr1[1:0]] = ~captRW1;
							nextwritedata0[captaddr1[1:0]] = captdata1[7:0];
						end //END CASE BYTE
						//default: begin end //$display("bad1 neighborhood switching");
					endcase
				end
			end
		endcase

		//synch reset behavior - overrides all with a NOP (read both pipes)
		if(rst) begin
			nextbram0we=4'b0;
			nextbram1we=4'b0;
		end
	end
endmodule
