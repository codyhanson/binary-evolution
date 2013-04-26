/*
Module:			mmrs

Description:		memory mapped register file, to spec in memory_locations.txt
Hierarchy:		SYSTEM=>periphsyswrapper=>mmrs

Notes: 1 first draft assumes single cycle operation
2 Search "TODO" to find parts that still need implementing
3 Need to instantiate and setup spart
4 Need to instantiate mouse and timer
5 Need to figure out how to setup exception handling

Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by:	Eric Weisman, 022711	
Edited by:		Ben Fuhrmann 040411 
Module interface by:	Eric Weisman, 021711

Date:			

*/



module mmrs(
	input clk, input rst,
	//cpu end
	input[7:0]		Addr0, Addr1,
	input			Enable0, Enable1, 
	input			RW0, RW1,
  input[39:0]		DataIn0, DataIn1,
  output reg[39:0] DataOut0, DataOut1,
	output			irq,
	//internal vga control
	output[31:0]	vgaFrameBase,
	//external device pins
	input[4:0]	pbsPins, 
	input[3:0] dipsPins,
	output[7:0]	ledsPins
	);

`include "mmrnames.inc"

	//vga offset generation
	reg	vgaFrameState;
	assign	vgaFrameBase=vgaFrameState?32'h0005_0000:32'h0;
	
	//leds are active low in hardware, active hi in interface
	reg[7:0]	leds;
	assign ledsPins=~leds;
	
	//internal hardware instantiation
	// SPARTs
	// TODO: ~instantiate with modified driver to abstract(?)
	
	// user peripherals
	reg		mouseRq, kbdRq, timerRq;
	wire kbd_rda;
	wire[7:0]	kbdData, mouseData;
	reg[15:0]	tmrcnt;
	reg[3:0] 	tmrdiv;
	
	//TODO: ~instantiate  mouse, timer.
	
	kbd_cntrl key0 (.clk(clk),.rst(rst),.kbd_data(),.kbd_clk(),.data_out(kbdData),.rda_out(kbd_rda),.tx_data());
	
	//IRQ/exception handling
	reg[7:0] 	irqsta, irqen, exp;
	assign irq=|irqsta;
	reg[3:0] 	pbsRq, dipsRq;
	
  reg[15:0] arrayWidth;
	reg irqdis;
	
	//arbitration logic
	always@(posedge clk) begin
		//clocked defaults
		DataOut0<=40'bz;	//tristate
		DataOut1<=40'bz;	//tristate
		// irq processing
		pbsRq<=pbsRq^pbsPins;
		dipsRq<=dipsRq^dipsPins;
		kbdRq<=kbdRq^kbd_rda;
		
		irqsta<=(irqsta|{pbsRq[3:0], |dipsRq[3:0], mouseRq, kbdRq, timerRq});
		// exception processing? how is value set?
		
		//interacting with databus
		// reset behavior
		if(rst) begin
			//VGASWFB
			vgaFrameState<=1'b0;
			//LEDS
			leds<=8'b0;
			//S0RCV
			//TODO: ~what abstraction? a
			//S0SND
			//TODO: ~what abstraction? b
			//TMRCNT
			tmrcnt<=16'b0;
			//TMRDIV
			tmrdiv<=4'b0;
			//IRQSTA
			irqsta<=8'b0;
			//IRQEN
			irqen<=8'b0;	//comes up disabled to give system setup time
			//EXP
			exp<=8'b0;
			//KBD - readonly
			//MOUSE - readonly
			//DIPS - readonly
			//PBS - readonly
			//ARRWID
			arrayWidth <= 16'b0;
			//IRQDIS
			irqdis <= 1'b0;
		end
		// typical enabled behavior
		else begin
			//data construction, path 1
			 if(Enable1) case(Addr1)
			 VGASWFB : begin	//implemented write which bank
			 	if(RW1) begin	//writing to mmr
			 		vgaFrameState<=DataIn1[0];
			 	end
			 	else begin	//reading from mmr
			 		DataOut1<={39'b0, vgaFrameState};
			 	end
			 end
			 LEDS : begin	//represented here as active high
			 	if(RW1) begin
			 		leds<=DataIn1[7:0];
			 	end
			 	else begin
			 		DataOut1<={32'b0, leds};
			 	end
			 end
			 S0RCV : begin
			 	if(RW1) begin
			 		//TODO: ~what abstraction? a
			 	end
			 	else begin
			 		//TODO: ~what abstraction? a
			 	end
			 end
			 S0SND : begin
			 	if(RW1) begin
			 		//TODO: ~what abstraction? b
			 	end
			 	else begin
			 		//TODO: ~what abstraction? b
			 	end
			 end
			 TMRCNT : begin
			 	if(RW1) begin
			 		tmrcnt<=DataIn1[15:0];
			 	end
			 	else begin
			 		DataOut1<=40'b1;	//DEBUG of write-only register
			 	end
			 end
			 TMRDIV : begin
			 	if(RW1) begin
			 		tmrdiv<=DataIn1[3:0];
			 	end
			 	else begin
			 		DataOut1<={16'b0, tmrdiv};
			 	end
			 end
			 IRQSTA : begin
			 	if(RW1) begin	//clearing irqs
			 		irqsta<=irqsta & DataIn1[7:0];
			 	end
			 	else begin
			 		DataOut1<={32'b0, irqsta};
			 	end
			 end
			 IRQEN : begin
			 	if(RW1) begin	//raw write from databus
			 		irqen<=DataIn1[7:0];
			 	end
			 	else begin
			 		DataOut1<={32'h0, irqen};
			 	end
			 end
			 EXP : begin
			 	if(RW1) begin
			 		exp<=8'b0;
			 	end
			 	else begin
			 		DataOut1<={32'b0, exp};
			 	end
			 end
			 KBD : begin
			 	if(RW1) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut1<={31'b0, kbdRq, kbdData[7:0]};
			 	end
			 end
			 MOUSE : begin
			 	if(RW1) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut1<={31'b0, mouseRq, mouseData[7:0]};
			 	end
			 end
			 DIPS : begin
			 	if(RW1) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut1<={36'b0,  dipsPins[3:0]};
			 	end
			 end
			 PBS : begin
			 	if(RW1) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut1<={35'b0,  pbsPins[4:0]};
			 	end
			 end
			 ARRWID : begin
			   if(RW1) begin
			     arrayWidth <= DataIn1[15:0];
			   end
			   else begin
			     DataOut1 <= {24'b0, arrayWidth};
			   end
			 end
			 IRQDIS : begin
			   if(RW1) begin
			     irqdis <= DataIn1[0];
			   end
			   else begin
			     DataOut1 <= {39'b0, irqdis};
			   end
			 end
			 default:	$display("bad default case in mmrs 0");
			endcase
			//data construction, path 0 - write supercedes path 1 write.
			 if(Enable0) case(Addr0)
			 VGASWFB : begin	//implemented switch on write
			 	if(RW0) begin	//writing to mmr
			 		vgaFrameState<=DataIn0[0];
			 	end
			 	else begin	//reading from mmr
			 		DataOut0<={39'b0, vgaFrameState};
			 	end
			 end
			 LEDS : begin	//represented here as active high
			 	if(RW0) begin
			 		leds<=DataIn0[7:0];
			 	end
			 	else begin
			 		DataOut0<={32'b0, leds};
			 	end
			 end
			 S0RCV : begin
			 	if(RW0) begin
			 		//TODO: ~what abstraction? a
			 	end
			 	else begin
			 		//TODO: ~what abstraction? a
			 	end
			 end
			 S0SND : begin
			 	if(RW0) begin
			 		//TODO: ~what abstraction? b
			 	end
			 	else begin
			 		//TODO: ~what abstraction? b
			 	end
			 end
			 TMRCNT : begin
			 	if(RW0) begin
			 		tmrcnt<=DataIn0[15:0];
			 	end
			 	else begin
			 		DataOut0<=40'b1;	//DEBUG of write-only register
			 	end
			 end
			 TMRDIV : begin
			 	if(RW0) begin
			 		tmrdiv<=DataIn0[3:0];
			 	end
			 	else begin
			 		DataOut0<={16'b0, tmrdiv};
			 	end
			 end
			 IRQSTA : begin
			 	if(RW0) begin	//clearing irqs
			 		irqsta<=irqsta & DataIn0[7:0];
			 	end
			 	else begin
			 		DataOut0<={32'b0, irqsta};
			 	end
			 end
			 IRQEN : begin
			 	if(RW0) begin	//raw write from databus
			 		irqen<=DataIn0[7:0];
			 	end
			 	else begin
			 		DataOut0<={32'h0, irqen};
			 	end
			 end
			 EXP : begin
			 	if(RW0) begin
			 		exp<=8'b0;
			 	end
			 	else begin
			 		DataOut0<={32'b0, exp};
			 	end
			 end
			 KBD : begin
			 	if(RW0) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut0<={31'b0, kbdRq, kbdData[7:0]};
			 	end
			 end
			 MOUSE : begin
			 	if(RW0) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut0<={31'b0, mouseRq, mouseData[7:0]};
			 	end
			 end
			 DIPS : begin
			 	if(RW0) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut0<={36'b0,  dipsPins[3:0]};
			 	end
			 end
			 PBS : begin
			 	if(RW0) begin
			 		//a readonly device
			 	end
			 	else begin
			 		DataOut0<={35'b0,  pbsPins[4:0]};
			 	end
			 end
       ARRWID : begin
			   if(RW0) begin
			     arrayWidth <= DataIn0[15:0];
			   end
			   else begin
			     DataOut0 <= {24'b0, arrayWidth};
			   end
			 end
			 IRQDIS : begin
			   if(RW0) begin
			     irqdis <= DataIn0[0];
			   end
			   else begin
			     DataOut0 <= {39'b0, irqdis};
			   end
			 end
			 default:	$display("bad default case in mmrs 1");
			endcase
		end
		// else hold current values
	end

endmodule
