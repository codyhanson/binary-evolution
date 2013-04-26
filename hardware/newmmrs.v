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



module newmmrs(
	input clk, input rst,
	//cpu end
	input[7:0]		Addr0, Addr1,
	input			Enable0, Enable1, 
	input			RW0, RW1,
  input[39:0]		DataIn0, DataIn1,
  inout kbd_data,
	inout kbd_clk,
  output reg[39:0] DataOut0, DataOut1,
	output			irq,
	//internal vga control
	
	//external device pins
	input[4:0]	pbsPins, 
	input[3:0] dipsPins,
	output[7:0]	ledsPins,
	output reg vgaFrameState,
	output reg vgaColorMode
	);

`include "mmrnames.inc"



 
	reg nextvgaFrameState;
	reg nextvgaColorMode;
	reg[7:0] nextleds;
	reg[15:0] nexttmrcnt;
	reg[3:0] nexttmrdiv;
	reg[7:0] nextirqsta,nextirqen,nextexp;
	reg[15:0] nextarrayWidth;
	reg nextirqdis;
	
	
	reg[7:0] leds;
	reg[15:0] tmrcnt;
	reg[3:0] tmrdiv;
	reg[7:0] irqsta,irqen,exp;
	reg[15:0] arrayWidth;
	reg irqdis;
	
	wire [7:0] randNum;
	//set up random generation
	rand r1 (rst,clk,randNum);
	

	
	//leds are active low in hardware, active hi in interface
	
	assign ledsPins=~leds;
	
	//internal hardware instantiation
	// SPARTs
	// TODO: ~instantiate with modified driver to abstract(?)
	
	// user peripherals
	wire		mouseRq, timerRq;
	wire kbd_rda;
	reg[3:0]pbsRq; 
	reg dipsRq;
	wire[7:0]	kbdData, mouseData;
  
	assign mouseRq = 0;
	assign timerRq = 0;
	
	
	//TODO: ~instantiate  mouse, timer.
	
	kbd_cntrl key0 (.clk(clk),.rst(rst),.kbd_data(kbd_data),.kbd_clk(kbd_clk),.data_out(kbdData),.rda_out(kbd_rda),.tx_data());
	
	//IRQ/exception handling
	assign irq=|irqsta;
	
	
	
	always @(posedge clk) begin
	  if(rst)begin
	     vgaFrameState <= 0;
		  vgaColorMode <= 0;
    	  leds <= 0;
	     tmrcnt <= 0;
	     tmrdiv <= 0;
	     irqsta <= 0;
	     irqen <= 0;
	     exp <= 0;
	     arrayWidth <= 0;
	     irqdis <= 0; 
		  pbsRq <= 0;
		  dipsRq <= 0;
	     
	  end  
	  else begin
		  if(dipsRq^(|dipsPins[3:1]))dipsRq <= 1;
		  else dipsRq <= 0;
		  if(pbsRq[3]^pbsPins[3]) pbsRq[3] <= 1;
		  else pbsRq[3] <=0;
		  if(pbsRq[2]^pbsPins[2]) pbsRq[2] <= 1;
		  else pbsRq[2] <=0;
		  if(pbsRq[1]^pbsPins[1]) pbsRq[1] <= 1;
		  else pbsRq[1] <=0;
		  if(pbsRq[0]^pbsPins[0]) pbsRq[0] <= 1;
		  else pbsRq[0] <=0;
		  
	     vgaFrameState <= nextvgaFrameState;
		  vgaColorMode <= nextvgaColorMode;
    	  leds <= nextleds;
	     tmrcnt <= nexttmrcnt;
	     tmrdiv <= nexttmrdiv;
	     irqsta <= nextirqsta; 
	     irqen <= nextirqen;
	     exp <= nextexp;
	     arrayWidth <= nextarrayWidth;
	     irqdis <= nextirqdis;
	    
	  end
	end
	
	 //irqstatus logic
	 wire clear_irq;
	 wire[7:0] clearbits;
	 assign clear_irq = (Addr0 == IRQSTA && RW0 == 1 && Enable0) || (Addr1 == IRQSTA && RW1 == 1 && Enable1)?1:0;
	 assign clearbits = (RW1 == 1) ? DataIn1[7:0] : DataIn0[7:0];
	 
	 always @(*)begin
	   nextirqsta[7:4] = (clear_irq) ? (irqsta[7:4]&(~clearbits[7:4])) : (irqsta[7:4] | pbsRq[3:0]);
	   nextirqsta[3] = (clear_irq) ? (irqsta[3]&(~clearbits[3])) : (dipsRq | irqsta[3]);
	   nextirqsta[2] = (clear_irq) ? (irqsta[2]&(~clearbits[2])) : (mouseRq | irqsta[2]);
	   nextirqsta[1] = (clear_irq) ? (irqsta[1]&(~clearbits[1])) : (kbd_rda | irqsta[1]);
	   nextirqsta[0] = (clear_irq) ? (irqsta[0]&(~clearbits[0])) : (timerRq | irqsta[0]);
	 end
	    
	
	// next state logic
	always @ (*) begin
	    //Defaults
			nextvgaFrameState = vgaFrameState;
			nextvgaColorMode = vgaColorMode;
			nextleds =leds;
			nexttmrcnt=tmrcnt;
			nexttmrdiv=tmrdiv;
			
			nextirqen=irqen;
			nextexp=exp;
			nextarrayWidth=arrayWidth;
			nextirqdis=irqdis;
			
			if(Enable0 && RW0) begin
			 case(Addr0)
			    VGASWFB : begin
				 nextvgaFrameState=DataIn0[0];
				 nextvgaColorMode = DataIn0[1];
				 end
			 	
			 LEDS : nextleds=DataIn0[7:0];
			 	
			 TMRCNT : nexttmrcnt=DataIn0[15:0];
			 
			 TMRDIV : nexttmrdiv=DataIn0[3:0];
			 
			
			 
			 IRQEN : nextirqen=DataIn0[7:0];
			 	
			 EXP : nextexp=8'b0;
			 	
			 ARRWID : nextarrayWidth = DataIn0[15:0];
			   
			 IRQDIS : nextirqdis = DataIn0[0];
						
			   
			 endcase  
			end
			if(Enable1 && RW1) begin
			 case(Addr1)
			 VGASWFB : begin
			 nextvgaFrameState=DataIn1[0];
			 nextvgaColorMode = DataIn1[1];
			 end
			 	
			 LEDS : nextleds=DataIn1[7:0];
			 	
			 TMRCNT : nexttmrcnt=DataIn1[15:0];
			 
			 TMRDIV : nexttmrdiv=DataIn1[3:0];
			 
		
			 
			 IRQEN : nextirqen=DataIn1[7:0];
			 	
			 EXP : nextexp=8'b0;
			 	
			 ARRWID : nextarrayWidth = DataIn1[15:0];
			   
			 IRQDIS : nextirqdis = DataIn1[0];
			  
			 endcase  
			end
			
			
	end
	
	
	

	    
	   
 
  // output logic
  always @(*)begin
       case(Addr1)
         RANDNUM: DataOut1 = {32'b0,randNum};
         
			 VGASWFB : DataOut1={38'b0, vgaColorMode,vgaFrameState};
						
			 LEDS : DataOut1={32'b0, leds};
			
			 TMRCNT : DataOut1=40'b1;	//DEBUG of write-only register
			 
			 TMRDIV : DataOut1={16'b0, tmrdiv};
			
			 IRQSTA : DataOut1={32'b0, irqsta & irqen};
			 	
			 IRQEN : DataOut1={32'h0, irqen};
			 	
			 EXP : DataOut1={32'b0, exp};
			 	
			 KBD : DataOut1={31'b0, kbd_rda, kbdData[7:0]};
			 	
			 MOUSE : DataOut1={31'b0, mouseRq, mouseData[7:0]};
			 
			 DIPS : DataOut1={37'b0,  dipsPins[3:1]};
			 	
			 PBS : DataOut1={35'b0,  pbsPins[4:0]};
			 
			 ARRWID : DataOut1 = {24'b0, arrayWidth};
			  
			 IRQDIS : DataOut1 = {39'b0, irqdis};
			   
			 default:	DataOut1 = 40'bx;
			endcase
			
			case(Addr0)
			  RANDNUM: DataOut0 = {32'b0,randNum};
			  
			 VGASWFB : DataOut0={38'b0, vgaColorMode, vgaFrameState};
			 
			 LEDS :    DataOut0={32'b0, leds};
		
			 TMRCNT :  DataOut0=40'b1;	//DEBUG of write-only register
			
			 TMRDIV :  DataOut0={16'b0, tmrdiv};
			 
			 IRQSTA :  DataOut0={32'b0, irqsta & irqen};
			 
			 IRQEN : DataOut0={32'h0, irqen};
			 
			 EXP : DataOut0={32'b0, exp};
			 	
			 KBD : DataOut0={31'b0, kbd_rda, kbdData[7:0]};
			 
			 MOUSE : DataOut0={31'b0, mouseRq, mouseData[7:0]};
			 	
			 DIPS : DataOut0={37'b0,  dipsPins[3:1]};
			 	
			 PBS : DataOut0={35'b0,  pbsPins[4:0]};
			 
       ARRWID : DataOut0 = {24'b0, arrayWidth};
			  
			 IRQDIS : DataOut0 = {39'b0, irqdis};
			  
			
			 default:	DataOut0 = 40'bx;
			endcase
		end
  
	
endmodule
