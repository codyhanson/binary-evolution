module mem(clk,rst,opCode0,opCode1,RdIn0,RdIn1,RoIn0,RoIn1,dataOut0,dataOut1,wb0_en,wb1_en,branchOnPipe0,
branchOnPipe1,wb_halt,prereg_opCode0,prereg_opCode1,prereg_RdIn0,prereg_RdIn1,prereg_RoIn0,prereg_RoIn1,clk_2x,stall,
blank,comp_sync,hsync,vsync,pixel_r,pixel_g,pixel_b,vga_clk,

//mmr stuff
SW_1, SW_2, SW_3,PB_ENTER,PB_UP,PB_DOWN,PB_LEFT,PB_RIGHT,LED_0,LED_1,LED_2,LED_3,CF_MPIRQ,kbd_data,kbd_clk
);
    input clk, rst;
    input [4:0] opCode0,opCode1;
    input [39:0] RdIn0, RdIn1; //Used as addresses into memory (not regfile) 
    input [39:0] RoIn0, RoIn1; //Memory Write Value or used to pass through writeback value
    //Pre-registered values which are used at the fast clock rate
    input [4:0] prereg_opCode0,prereg_opCode1;
    input [39:0] prereg_RdIn0,prereg_RdIn1,prereg_RoIn0,prereg_RoIn1;
    input clk_2x;
    input vga_clk;
    inout kbd_data;
	inout kbd_clk;
    input SW_1, SW_2, SW_3;
    wire[3:0] dipsPins;
    assign dipsPins = {SW_3,SW_2,SW_1,rst};
    
    input PB_ENTER,PB_UP,PB_DOWN,PB_LEFT,PB_RIGHT;
    wire[4:0] pbsPins;
    assign pbsPins = {~PB_ENTER,~PB_UP,~PB_DOWN,~PB_LEFT,~PB_RIGHT}; //active low
    
    output LED_0,LED_1,LED_2,LED_3;
    wire[7:0] ledPins;
    assign LED_3 = ledPins[3];
	 assign LED_2 = ledPins[2];
	 assign LED_1 = ledPins[1];
	 assign LED_0 = ledPins[0];
	
    
    input CF_MPIRQ;
    assign irq = CF_MPIRQ;
    
    output reg [39:0] dataOut0, dataOut1;
    output wb0_en,wb1_en,wb_halt;
    
    //Branch Logic
    output branchOnPipe0, branchOnPipe1;
    output reg stall;
	 
	 //VGA
	 output blank,comp_sync,hsync,vsync;
	output [7:0] pixel_r,pixel_g,pixel_b;
    
    `include "opcodes.inc"
  localparam BYTEWIDE = 2'b00;
  localparam HALFWIDE = 2'b01;
  localparam WORDWIDE = 2'b10;
  
   
    reg MMR_Enable0, MMR_Enable1;
    reg MMR_RW0, MMR_RW1;
	 
    wire vgaFrameState;
    wire vgaColorMode;
    wire [39:0] mmrDataOut0,mmrDataOut1;
    wire [39:0] memDataOut0,memDataOut1;
    
    //Temp regs
    reg branch0, branch1; //Will be output on branchOnPipeX after logic
    reg wb0, wb1; //Will be outputted on wbX_en after some limited logic
    
    //Slow State Machine
    always @(*) begin
        //Defaults
        dataOut0 = RdIn0;
        dataOut1 = RdIn1;
        wb0 = 1'b1;
        wb1 = 1'b1;
        branch0 = 1'b0;
        branch1 = 1'b0;
		  MMR_Enable0 = 1'b0;
		  MMR_Enable1 = 1'b0;
		  MMR_RW0 = 1'b0;
		  MMR_RW1 = 1'b0;
        
     casex({stall,opCode0})
         {1'b1,5'bX} : begin //VGA Using Mem Stage 
               wb0 = 1'b0;
            end
         {1'b0,ADD}: begin end
         {1'b0,AND}: begin end
         {1'b0,BIC}: begin end
         {1'b0,NOOP}: begin wb0 = 1'b0; end
         {1'b0,OR}: begin end
         {1'b0,RSB}: begin end
         {1'b0,SUB}: begin end
         {1'b0,SWP}: begin end
         {1'b0,ACCUMBYTES}: begin end
         {1'b0,MXMUL}: begin end
         {1'b0,MXADD}: begin end
         {1'b0,MXSUB}: begin end
         {1'b0,B}: begin branch0 = 1'b1; wb0 = 1'b0; end
         {1'b0,BL}: begin dataOut0 = RoIn0; branch0 = 1'b1; end
         {1'b0,CMP}: begin  wb0 = 1'b0; end
         {1'b0,MOV}: begin end
         {1'b0,NOT}: begin end
         {1'b0,TEQ}: begin  wb0 = 1'b0;  end
         {1'b0,TST}: begin  wb0 = 1'b0;  end
         {1'b0,BWCMPL}: begin end
         {1'b0,LDR}: begin
           dataOut0 =(RdIn0[39]) ? mmrDataOut0: memDataOut0; 
           MMR_Enable0 = RdIn0[39] ? 1:0;
         end
         {1'b0,LDRB}: begin
           dataOut0 = (RdIn0[39]) ? {32'd0,mmrDataOut0[7:0]}: {32'd0,memDataOut0[7:0]};
           MMR_Enable0 = RdIn0[39] ? 1:0;
           
         end
         {1'b0,LDRH}: begin 
           dataOut0 = (RdIn0[39]) ? {24'd0,mmrDataOut0[15:0]}:{24'd0,memDataOut0[15:0]};
           MMR_Enable0 = RdIn0[39] ? 1:0;
         end
         {1'b0,LDRSB}: begin
           dataOut0 = (RdIn0[39]) ? {{32{mmrDataOut0[7]}},mmrDataOut0[7:0]}:{{32{memDataOut0[7]}},memDataOut0[7:0]};
           MMR_Enable0 = RdIn0[39] ? 1:0;
         end
         {1'b0,LDRSH}: begin
           dataOut0 = (RdIn0[39]) ? {{24{mmrDataOut0[15]}},mmrDataOut0[15:0]}:{{24{memDataOut0[15]}},memDataOut0[15:0]};
           MMR_Enable0 = RdIn0[39] ? 1:0;
         end
         {1'b0,STR}: begin
           wb0 = 1'b0;
			  MMR_Enable0 = RdIn0[39] ? 1:0;
			  MMR_RW0 = RdIn0[39] ? 1:0;
         end
         {1'b0,STRB}: begin
           wb0 = 1'b0;
			  MMR_Enable0 = RdIn0[39] ? 1:0;
			  MMR_RW0 = RdIn0[39] ? 1:0;
         end
         {1'b0,STRH}: begin
           wb0 = 1'b0;
			  MMR_Enable0 = RdIn0[39] ? 1:0;
			  MMR_RW0 = RdIn0[39] ? 1:0;
         end
         {1'b0,LDNEIGHBOR}: begin
           dataOut0 = memDataOut0;
         end
         {1'b0,STRNEIGHBOR}: begin
           wb0 = 1'b0;
         end
         {1'b0,RETURN}: begin  wb0 = 1'b0; end
         {1'b0,HALT}: begin  wb0 = 1'b0;  end
         default: begin
           wb0= 1'b0;  
         end
     endcase
    
     casex({stall,opCode0,opCode1})
         {1'b1,10'hx} : begin wb1 = 1'b0; end
         {1'b0,ACCUMBYTES,5'hx} : begin
             wb1 = 1'b0;
	      end
	      {1'b0,SWP,5'hx} : begin
	      end
	      {1'b0,MXMUL,5'hx} : begin
	      end
	      {1'b0,MXADD,5'hx} : begin
	      end
	      {1'b0,MXSUB,5'hx} : begin
	      end
         {1'b0,LDNEIGHBOR,5'hx} : begin
           dataOut1 = memDataOut1;
	      end
         {1'b0,STRNEIGHBOR,5'hx} : begin
             wb1 = 1'b0;
	       end
         {1'b0,5'hX,ADD}: begin end
         {1'b0,5'hX,AND}: begin end
         {1'b0,5'hX,BIC}: begin end
         {1'b0,5'hX,NOOP}: begin wb1 = 1'b0; end
         {1'b0,5'hX,OR}: begin end
         {1'b0,5'hX,RSB}: begin end
         {1'b0,5'hX,SUB}: begin end
         {1'b0,5'hX,SWP}: begin end
         {1'b0,5'hX,ACCUMBYTES}: begin end
         {1'b0,5'hX,MXMUL}: begin end
         {1'b0,5'hX,MXADD}: begin end
         {1'b0,5'hX,MXSUB}: begin end
         {1'b0,5'hX,B}: begin branch1 = 1'b1; wb1 = 1'b0; end
         {1'b0,5'hX,BL}: begin dataOut1 = RoIn1; branch1 = 1'b1; end
         {1'b0,5'hX,CMP}: begin  wb1 = 1'b0; end
         {1'b0,5'hX,MOV}: begin end
         {1'b0,5'hX,NOT}: begin end
         {1'b0,5'hX,TEQ}: begin  wb1 = 1'b0;  end
         {1'b0,5'hX,TST}: begin  wb1 = 1'b0;  end
         {1'b0,5'hX,BWCMPL}: begin end
         {1'b0,5'hX,LDR}: begin
				 MMR_Enable1 = RdIn1[39] ? 1:0;
             dataOut1 = (RdIn1[39]) ? mmrDataOut1 : memDataOut1;
         end
         {1'b0,5'hX,LDRB}: begin
             dataOut1 = (RdIn1[39]) ? {32'd0,mmrDataOut1[7:0]}:{32'd0,memDataOut1[7:0]}; 
             MMR_Enable1 = RdIn1[39] ? 1:0;
            
         end
         {1'b0,5'hX,LDRH}: begin 
      
             dataOut1 = (RdIn1[39]) ? {24'd0,mmrDataOut1[15:0]}:{24'd0,memDataOut1[15:0]}; 
             MMR_Enable1 = RdIn1[39] ? 1:0;
     
          
         end
         {1'b0,5'hX,LDRSB}: begin
     
             dataOut1 = (RdIn1[39]) ? {{32{mmrDataOut1[7]}},mmrDataOut1[7:0]}:{{32{memDataOut1[7]}},memDataOut1[7:0]}; 
             MMR_Enable1 = RdIn1[39] ? 1:0;
     
           
         end
         {1'b0,5'hX,LDRSH}: begin
             dataOut1 = (RdIn1[39]) ? {{24{mmrDataOut1[15]}},mmrDataOut1[15:0]}:{{24{memDataOut1[15]}},memDataOut1[15:0]}; 
             MMR_Enable1 = RdIn1[39] ? 1:0;
          
          
         end
         {1'b0,5'hX,STR}: begin
           wb1 = 1'b0;
			  MMR_Enable1 = RdIn1[39] ? 1:0;
			  MMR_RW1 = RdIn1[39] ? 1:0;
         end
         {1'b0,5'hX,STRB}: begin
           wb1 = 1'b0;
			  MMR_Enable1 = RdIn1[39] ? 1:0;
			  MMR_RW1 = RdIn1[39] ? 1:0;
         end
         {1'b0,5'hX,STRH}: begin
           wb1 = 1'b0;
			  MMR_Enable1 = RdIn1[39] ? 1:0;
			  MMR_RW1 = RdIn1[39] ? 1:0;
         end
         {1'b0,5'hX,LDNEIGHBOR}: begin
           //Case should not hit Happen
         end
         {1'b0,5'hX,STRNEIGHBOR}: begin
           //Case should not hit
         end
         {1'b0,5'hX,RETURN}: begin  wb1 = 1'b0; end
         {1'b0,5'hX,HALT}: begin  wb1 = 1'b0;  end
         default: begin
            //Case should not hit 
         end
     endcase
    end
    
    //Branching Logic
    assign branchOnPipe0 = branch0;
    assign branchOnPipe1 = branch1 && !branch0;
    assign wb0_en = wb0;
    assign wb1_en = wb1 && !branch0 && (!(opCode0==HALT));
    assign wb_halt = ((opCode0==HALT)||(opCode1==HALT && !(opCode0==B || opCode0==BL))) && !stall;

    
    //VGA Module
    reg vga_request;
	 
    wire vga_request_raw;
    wire next_vga_request;
	 assign next_vga_request = (vga_request)? 1'b0 : vga_request_raw;
	 
	 always @(posedge clk) begin //Flop to prevent metastability
       vga_request <= next_vga_request; 
    end
    
   
    wire [39:0] vga_addr_raw;
    wire [39:0] next_vga_addr;
    reg [39:0] vga_addr;
    wire [79:0] vga_data;
    assign next_vga_addr = (vga_request_raw && !vga_request) ? vga_addr_raw : vga_addr;
    always @(posedge clk) begin
       vga_addr <= next_vga_addr; 
    end
    
    reg [79:0] saved_vga_data;
    wire [79:0] next_saved_vga_data;
    assign next_saved_vga_data = (stall) ? {memDataOut1[7:0],memDataOut1[15:8],memDataOut1[23:16],memDataOut1[31:24],memDataOut1[39:32],memDataOut0[7:0],memDataOut0[15:8],memDataOut0[23:16],memDataOut0[31:24],memDataOut0[39:32]} : saved_vga_data;

    always @(posedge clk) begin
       saved_vga_data <= next_saved_vga_data; 
    end
    assign vga_data =   (stall) ? {memDataOut1[7:0],memDataOut1[15:8],memDataOut1[23:16],memDataOut1[31:24],memDataOut1[39:32],memDataOut0[7:0],memDataOut0[15:8],memDataOut0[23:16],memDataOut0[31:24],memDataOut0[39:32]} : saved_vga_data;  
    always @(posedge clk) begin
       if (rst) begin
          stall <= 1'b0;
       end else begin
          stall <= vga_request;
      end 
    end
    
    
    
    //Fast Memory Logic
    reg memWr0,memWr1;
    reg [1:0] memMode0, memMode1;
    `include "brammodes.inc" 
    //BYTE,HALF,WORD,NEIG
    
always @(*) begin
     memWr0 = 1'b0;
     memMode0 = 2'bX;
     memWr1 = 1'b0;
     memMode1 = 2'bX;
   case(prereg_opCode0)
         ADD: begin end
         AND: begin end
         BIC: begin end
         NOOP: begin end
         OR: begin end
         RSB: begin end
         SUB: begin end
         SWP: begin end
         ACCUMBYTES: begin end
         MXMUL: begin end
         MXADD: begin end
         MXSUB: begin end
         B: begin end
         BL: begin end
         CMP: begin end
         MOV: begin end
         NOT: begin end
         TEQ: begin end
         TST: begin end
         BWCMPL: begin end
         LDR: begin
             memMode0 = WORD;
         end
         LDRB: begin
             memMode0 = BYTE;
         end
         LDRH: begin 
            memMode0 = HALF;
         end
         LDRSB: begin
            memMode0 = BYTE;
         end
         LDRSH: begin
             memMode0 = HALF;
         end
         STR: begin
           memWr0 = (prereg_RdIn0[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region;
           memMode0 = WORD;
         end
         STRB: begin
           memWr0 = (prereg_RdIn0[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region;
           memMode0 = BYTE;
         end
         STRH: begin
           memWr0 = (prereg_RdIn0[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region;
           memMode0 = HALF;
         end
         LDNEIGHBOR: begin
          memMode0 = NEIG;
         end
         STRNEIGHBOR: begin
           memWr0 = 1'b1;
           memMode0 = NEIG;
         end
         RETURN: begin end
         HALT: begin end
     endcase
    
     casex({prereg_opCode0,prereg_opCode1})
         {HALT,5'hx} : begin end
         {ACCUMBYTES,5'hx} : begin
	      end
	      {SWP,5'hx} : begin
	      end
	      {MXMUL,5'hx} : begin
	      end
	      {MXADD,5'hx} : begin
	      end
	      {MXSUB,5'hx} : begin
	      end
         {LDNEIGHBOR,5'hx} : begin
             memMode1 = NEIG;
	      end
         {STRNEIGHBOR,5'hx} : begin
             memWr1 = 1'b1;
             memMode1 = NEIG;
	       end
	       {B,5'hx}: begin /* Don't do second pipe if branch on 1st pipe */ end
	       {BL,5'hx}: begin end
         {5'hX,ADD}: begin end
         {5'hX,AND}: begin end
         {5'hX,BIC}: begin end
         {5'hX,NOOP}: begin end
         {5'hX,OR}: begin end
         {5'hX,RSB}: begin end
         {5'hX,SUB}: begin end
         {5'hX,SWP}: begin end
         {5'hX,ACCUMBYTES}: begin end
         {5'hX,MXMUL}: begin end
         {5'hX,MXADD}: begin end
         {5'hX,MXSUB}: begin end
         {5'hX,B}: begin end
         {5'hX,BL}: begin end
         {5'hX,CMP}: begin  end
         {5'hX,MOV}: begin end
         {5'hX,NOT}: begin end
         {5'hX,TEQ}: begin end
         {5'hX,TST}: begin end
         {5'hX,BWCMPL}: begin end
         {5'hX,LDR}: begin
             memMode1 = WORD;
         end
         {5'hX,LDRB}: begin
             memMode1 = BYTE;
         end
         {5'hX,LDRH}: begin 
            memMode1 = HALF;
         end
         {5'hX,LDRSB}: begin
             memMode1 = BYTE;
         end
         {5'hX,LDRSH}: begin
             memMode1 = HALF;
         end
         {5'hX,STR}: begin
           memWr1 = (prereg_RdIn1[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region
           memMode1 = WORD;
         end
         {5'hX,STRB}: begin
           memWr1 = (prereg_RdIn1[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region;
           memMode1 = BYTE;
         end
         {5'hX,STRH}: begin
           memWr1 = (prereg_RdIn1[39]==1'b1) ? 1'b0 : 1'b1; //Check for MMR Region;
           memMode1 = HALF;
         end
         {5'hX,LDNEIGHBOR}: begin
           //Case should not hit Happen
         end
         {5'hX,STRNEIGHBOR}: begin
           //Case should not hit
         end
         {5'hX,RETURN}: begin end
         {5'hX,HALT}: begin end
     endcase
  end   
  
/*vga vga0(.rst(rst),.clk_25mhz(clk),
.blank(blank),.comp_sync(comp_sync),.hsync(hsync),.vsync(vsync),.pixel_r(pixel_r),.pixel_g(pixel_g),.pixel_b(pixel_b),
.read_bytes(vga_request_debug), 
.input_bytes({memDataOut1[7:0],memDataOut1[15:8],memDataOut1[23:16],memDataOut1[31:24],memDataOut1[39:32],memDataOut0[7:0],memDataOut0[15:8],memDataOut0[23:16],memDataOut0[31:24],memDataOut0[39:32]}),
.fb_select(vgaFrameState),
.mem_addr(vga_addr));//,.color_mode(vgaColorMode));*/

vga_proto vga0(.rst(rst),.clk_25mhz(vga_clk),
.blank(blank),.comp_sync(comp_sync),.hsync(hsync),.vsync(vsync),.pixel_r(pixel_r),.pixel_g(pixel_g),.pixel_b(pixel_b),
.read_bytes(vga_request_raw), 
.input_bytes(vga_data),
.fb_select(vgaFrameState),
.mem_addr(vga_addr_raw),.color_mode(vgaColorMode));
  

  
     bramctl bramctl0(.clk(clk),.rst(rst),.fastclk(clk_2x),
     .MemDataIn0((vga_request) ? vga_addr : prereg_RoIn0), 
     .MemDataIn1((vga_request) ? vga_addr : prereg_RoIn1),
     .MemDataOut0(memDataOut0),
     .MemDataOut1(memDataOut1),
     .arraywidth(16'd256),
     .MemAddr0(vga_request ? vga_addr : prereg_RdIn0), .MemAddr1(vga_request ? vga_addr + 40'd5 : prereg_RdIn1),
     .mode0(vga_request ? WORD : memMode0), .mode1(vga_request ? WORD : memMode1),
     .RW0(vga_request ? 1'b1 : ~memWr0),.RW1(vga_request||branchOnPipe0 ? 1'b1 : ~memWr1));

  newmmrs mmrs0(.clk(clk) ,.rst(rst), .Addr0(RdIn0[7:0]) ,.Addr1(RdIn1[7:0]),
	.Enable0(MMR_Enable0), .Enable1(!branch0&&(opCode0!=HALT)&&MMR_Enable1), .RW0(MMR_RW0), .RW1(MMR_RW1),
		.DataIn0(RoIn0), .DataIn1(RoIn1), .DataOut0(mmrDataOut0), .DataOut1(mmrDataOut1), .irq(irq), .vgaFrameState(vgaFrameState),
		.pbsPins(pbsPins) ,.dipsPins(dipsPins), .ledsPins(ledPins),.kbd_data(kbd_data),.kbd_clk(kbd_clk),.vgaColorMode(vgaColorMode));



    
endmodule 
