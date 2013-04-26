/* Module:	toplevel
Description: The top level for all modules		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by: Eric H.
Edited by:		
Module interface by:	

Date:			

*/

module toplevel(input CLK_100MHZ, rst, 
	output blank,comp_sync,hsync,vsync,
	output [7:0] pixel_r,pixel_g,pixel_b,
	output CLK_25MHZ, //Not sure why we need this
	output CLK_CORE,
	output CLK_2XCORE,
	 input SW_1, SW_2, SW_3,
    input PB_ENTER,PB_UP,PB_DOWN,PB_LEFT,PB_RIGHT,
	 inout kbd_data, kbd_clk,
    output LED_0,LED_1,LED_2,LED_3,
    input CF_MPIRQ
	);
	
	
	//Clocking
	wire clk, clk_2x, vga_clk;
	wire clk_mem_i;
	wire locked_dcm,prelock;
	assign CLK_25MHZ = vga_clk;
	assign CLK_CORE = clk;
	assign CLK_2XCORE = clk_2x;

	wire clock_100;
	clk_half clk_gen(
    .CLKIN_IN(clk_mem_i), 
    .RST_IN(rst||~prelock), 
    .CLKFX_OUT(clk), 
    .CLK0_OUT(clk_2x), 
    .LOCKED_OUT(locked_dcm)
    );
	 
	 clk_prestage clk_60(
    .CLKIN_IN(CLK_100MHZ), 
    .RST_IN(rst), 
    .CLKFX_OUT(clk_mem_i),
    .CLK0_OUT(clock_100), 
    .LOCKED_OUT(prelock)
    );
    
   clk_vga clk_vgagen(
    .CLKIN_IN(clock_100), 
    .RST_IN(rst), 
    .CLKFX_OUT(vga_clk),
    .LOCKED_OUT() //Don't care if the VGA clock is a little off
    );
	 
	
	wire rst_internal;
	reg rst_reg;
	always @(posedge clk) begin //Sync reset to slow clock
	   rst_reg <= rst || !locked_dcm; 
	end
	assign rst_internal = rst || !locked_dcm || rst_reg;
	
	    wire [4:0] nextopCode0_memR, nextopCode1_memR;
	  wire [39:0] nextro0_memR, nextro1_memR,nextdataRd0_memR,nextdataRd1_memR;
    wire [4:0] nextaddrRd0_memR, nextaddrRd1_memR;


`include "opcodes.inc"     
//FETCH+++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++
   //THE IM registers its data already
    wire [29:0] pc_fetch;
    wire[31:0] imem_instr0, imem_instr1;
    instr_mem instr_mem0(.clk(clk), .rst(rst_internal), .addrIn(rst_internal ? 30'd0 : pc_fetch), .instr0(imem_instr0), .instr1(imem_instr1));
	//TODO: NOte that fetch starts at 0

//Flush Wires
wire wb_branch0,wb_branch1;
wire stall_for_mem;
//EXEC WB REG EARLY 
reg [39:0] dataRd0_memR, dataRd1_memR;
reg execStalledLastCycle;

//Reset Delay so that Decode stage injects a second reset until the imem has read
reg delayed_rst;
always @(posedge clk) begin
delayed_rst <= (rst_internal);
end

     wire decode_stall0, decode_stall1;
	  reg [31:0] instr0_decodeR, instr1_decodeR;
	  reg [31:0] nextinstr0_decodeR, nextinstr1_decodeR;
	  always @(*) begin
	      	    if ((rst_internal) || wb_branch0 || wb_branch1) begin
	                nextinstr0_decodeR = {NOOP,27'hx};
	                nextinstr1_decodeR = {NOOP,27'hx};
	             end else begin
	                 nextinstr0_decodeR =  (decode_stall0) ? instr0_decodeR : ((decode_stall1) ? instr1_decodeR: imem_instr0);
	                 nextinstr1_decodeR =  (decode_stall0) ? instr1_decodeR : ((decode_stall1) ? imem_instr0: imem_instr1);
	             end 
	  end
	  
	  
	  always @(posedge clk) begin
	       instr0_decodeR <= nextinstr0_decodeR;
	       instr1_decodeR <= nextinstr1_decodeR;
	  end
	 
	 
	 
	 
	 
//DECODE+++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++
    wire [39:0] rm0_ex, rm1_ex,rn0_ex,rn1_ex, ro0_ex, ro1_ex; 
    wire [4:0] addrRd0_ex, addrRd1_ex;
    
    reg [4:0] addrRd0_memR, addrRd1_memR; //Output from EX_MEM Flops
   
    wire [4:0] opCode0_ex, opCode1_ex; //TODO: Change width
    wire [39:0] dataWriteBack0, dataWriteBack1;
    wire stall_ExecDecode;
    wire wb_halt;
    
    //Hazard Wires
    wire [4:0] dec_addrRm0, dec_addrRm1, dec_addrRn0, dec_addrRn1;
    wire hazardStall0_dec, hazardStall1_dec;
    
    
    //Early Execute Wires that get fed back
     reg [4:0] addrRd0_exR, addrRd1_exR;
    wire [4:0] opCode0_mem, opCode1_mem;
    wire [39:0] dataRd0_mem, dataRd1_mem;
    wire wbEn0_decode, wbEn1_decode;
    
    decode decode0(.clk(clk),.rst(rst_internal),.instr0(instr0_decodeR),.instr1(instr1_decodeR),
        .addrWriteBack0(addrRd0_memR),.addrWriteBack1(addrRd1_memR),.writeBackEn0(wbEn0_decode),.writeBackEn1(wbEn1_decode),
        
        .dataWriteBack0(dataWriteBack0),
        .dataWriteBack1(dataWriteBack1),
        
        .rm0_ex(rm0_ex),.rm1_ex(rm1_ex),.rn0_ex(rn0_ex),.rn1_ex(rn1_ex), .ro0_ex(ro0_ex), .ro1_ex(ro1_ex),
        .addrRd0_ex(addrRd0_ex),.addrRd1_ex(addrRd1_ex),.opCode0_ex(opCode0_ex),.opCode1_ex(opCode1_ex),
        .nextPC_fetch(pc_fetch), .stall_decode(stall_ExecDecode||stall_for_mem),
        //Hazard Detection for Execute Stage
        .hazardStall0(hazardStall0_dec), 
        .hazardStall1(hazardStall1_dec||(SW_3)),
        .addrRm0(dec_addrRm0),
        .addrRm1(dec_addrRm1),
        .addrRn0(dec_addrRn0),
        .addrRn1(dec_addrRn1),
       //Inputs from WB
        .branch_en(wb_branch0||wb_branch1),
        .branch_addr((wb_branch0)? dataRd0_memR[29:0] : dataRd1_memR[29:0]),
        .halt_in_wb(wb_halt),
        //Final Stall Decision Output
        .stall0(decode_stall0),
        .stall1(decode_stall1) 
        );


wire [39:0] rm0_hazardFree_ex, rm1_hazardFree_ex,rn0_hazardFree_ex,rn1_hazardFree_ex,ro0_hazardFree_ex,ro1_hazardFree_ex;
exec_hazard_detector exechazard0(.rm0_in(rm0_ex),.rm1_in(rm1_ex), 
  .rn0_in(rn0_ex), .rn1_in(rn1_ex), .ro0_in(ro0_ex), .ro1_in(ro1_ex),
  .addrRm0(dec_addrRm0), .addrRm1(dec_addrRm1),
  .addrRn0(dec_addrRn0), .addrRn1(dec_addrRn1),
  .opCode0_dec(instr0_decodeR[31:27]), //Don't use output of decode stage or will form loop
  .opCode1_dec(instr1_decodeR[31:27]),
  //Inputs from Decode
  .opCode0_exe(nextopCode0_memR),
  .opCode1_exe(nextopCode1_memR),
  .execDataIn0(nextdataRd0_memR),
  .execDataIn1(nextdataRd1_memR),
  .addrRd0_exe(nextaddrRd0_memR),
  .addrRd1_exe(nextaddrRd1_memR),
  //Outputs
  .hazardStall0(hazardStall0_dec),
  .hazardStall1(hazardStall1_dec),
  .rm0_out(rm0_hazardFree_ex),
  .rm1_out(rm1_hazardFree_ex),
  .rn0_out(rn0_hazardFree_ex),
  .rn1_out(rn1_hazardFree_ex),
  .ro0_out(ro0_hazardFree_ex),
  .ro1_out(ro1_hazardFree_ex)
);



// DEC_EX Registers
reg [39:0] rm0_exR, rm1_exR,rn0_exR,rn1_exR, ro0_exR, ro1_exR; 
reg [3:0] cond0_exR, cond1_exR;
reg [4:0] opCode0_exR, opCode1_exR;
wire [39:0] nextrm0_exR, nextrm1_exR,nextrn0_exR,nextrn1_exR, nextro0_exR, nextro1_exR; 
wire [3:0] nextcond0_exR, nextcond1_exR;
wire [4:0] nextopCode0_exR, nextopCode1_exR;
wire [4:0] nextaddrRd0_exR, nextaddrRd1_exR;
assign nextrm0_exR =(stall_for_mem) ? rm0_exR : rm0_hazardFree_ex;
assign nextrm1_exR = (stall_for_mem) ? rm1_exR : rm1_hazardFree_ex; 
assign nextrn0_exR = (stall_for_mem) ? rn0_exR : rn0_hazardFree_ex;
assign nextrn1_exR = (stall_for_mem) ? rn1_exR : rn1_hazardFree_ex;
assign nextro0_exR = (stall_for_mem) ? ro0_exR : ro0_hazardFree_ex;
assign nextro1_exR = (stall_for_mem) ? ro1_exR : ro1_hazardFree_ex;
assign nextcond0_exR = stall_for_mem ? cond0_exR:instr0_decodeR[26:23];
assign nextcond1_exR = stall_for_mem ? cond1_exR:instr1_decodeR[26:23];
assign nextopCode0_exR =  (rst_internal||delayed_rst) ? NOOP : (stall_for_mem ? opCode0_exR: (wb_halt||wb_branch0||wb_branch1) ? NOOP : opCode0_ex);
assign nextopCode1_exR =  (rst_internal||delayed_rst) ? NOOP : (stall_for_mem ? opCode1_exR: (wb_halt||wb_branch0||wb_branch1) ? NOOP : opCode1_ex);
assign nextaddrRd0_exR =(stall_for_mem) ? addrRd0_exR : addrRd0_ex;
assign nextaddrRd1_exR = (stall_for_mem) ? addrRd1_exR : addrRd1_ex;
 
 
  always @(posedge clk) begin
    rm0_exR <= nextrm0_exR;
    rn0_exR <= nextrn0_exR; 
    ro0_exR <= nextro0_exR; 
    rm1_exR <= nextrm1_exR;
    rn1_exR <= nextrn1_exR; 
    ro1_exR <= nextro1_exR;
    addrRd0_exR <= nextaddrRd0_exR;
    addrRd1_exR <= nextaddrRd1_exR; 
    opCode0_exR <= nextopCode0_exR;
    opCode1_exR <= nextopCode1_exR;
    cond0_exR <= nextcond0_exR;
    cond1_exR <= nextcond1_exR; 
 end
        
//Execute+++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++


wire [39:0] ro0_mem, ro1_mem;
wire [2:0] cyclecount;
executetoplevel execute0(.clk(clk), .rst(rst_internal), .controlInDecExOp1(opCode0_exR),
			  .dataInDecExRm1(rm0_exR),.dataInDecExRn1(rn0_exR),.dataInDecExRo1(ro0_exR),
           .controlInDecExOp2(opCode1_exR),
			  .dataInDecExRm2(rm1_exR),.dataInDecExRn2(rn1_exR),.dataInDecExRo2(ro1_exR),
			  .dataInExMemRd1(dataRd0_memR),.dataInExMemRd2(dataRd1_memR),
			  .controlInDecExCond1(cond0_exR), .controlInDecExCond2(cond1_exR),
			  //Outputs
			  .controlOutExMemOp1(opCode0_mem),.dataOutExMemRd1(dataRd0_mem),
			  .dataOutExMemRo1(ro0_mem),.controlOutExMemOp2(opCode1_mem),
			  .dataOutExMemRd2(dataRd1_mem),.dataOutExMemRo2(ro1_mem),
			  .controlOutExecuteStall(stall_ExecDecode), .flush(wb_branch0||wb_branch1), .stall(stall_for_mem)
			  ,.cyclecnt(cyclecount));
//TODO: Put stall signal into execute stage.
//Exec_WB Registers
    //Remember last execute stall decision
    
    always @(posedge clk) begin
       execStalledLastCycle <= stall_ExecDecode; 
    end




    reg [4:0] opCode0_memR, opCode1_memR;
    reg [39:0] ro0_memR, ro1_memR;
  
    assign nextopCode0_memR = (rst_internal) ? NOOP : (stall_for_mem) ? opCode0_memR: (wb_halt||wb_branch0||wb_branch1)? NOOP : opCode0_mem;
    assign nextopCode1_memR = (rst_internal) ? NOOP : (stall_for_mem) ? opCode1_memR: (wb_halt||wb_branch0||wb_branch1) ? NOOP :opCode1_mem;
   
    assign nextro0_memR = (stall_for_mem) ? ro0_memR : ro0_mem;
    assign nextro1_memR = (stall_for_mem) ? ro1_memR : ro1_mem;
    assign nextdataRd0_memR = (stall_for_mem) ? dataRd0_memR: dataRd0_mem;
    assign nextdataRd1_memR = (stall_for_mem) ? dataRd1_memR: dataRd1_mem;
    assign nextaddrRd0_memR = (execStalledLastCycle&&cyclecount!=0)||(stall_for_mem) ? addrRd0_memR : addrRd0_exR;
    assign nextaddrRd1_memR = (stall_for_mem) ? addrRd1_memR : addrRd1_exR;

    always @(posedge clk) begin
      opCode0_memR <= nextopCode0_memR;
      opCode1_memR <= nextopCode1_memR;
      ro0_memR <= nextro0_memR;
      ro1_memR <= nextro1_memR;
      dataRd0_memR <= nextdataRd0_memR ;
      dataRd1_memR <= nextdataRd1_memR ;
      addrRd0_memR <= nextaddrRd0_memR;
      addrRd1_memR <= nextaddrRd1_memR; 
     end

//WriteBack/MEM+++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++     

mem mem0(.clk(clk),.rst(rst_internal),.opCode0(opCode0_memR),.opCode1(opCode1_memR),
.RoIn0(ro0_memR),.RoIn1(ro1_memR),.RdIn0(dataRd0_memR),
.RdIn1(dataRd1_memR),.dataOut0(dataWriteBack0),.dataOut1(dataWriteBack1),
.wb0_en(wbEn0_decode),.wb1_en(wbEn1_decode),.branchOnPipe0(wb_branch0),.branchOnPipe1(wb_branch1),.wb_halt(wb_halt),
//Signals for First Edge Write/Read
.prereg_opCode0(nextopCode0_memR),
  .prereg_opCode1(nextopCode1_memR),
  .prereg_RdIn0(nextdataRd0_memR),
  .prereg_RdIn1(nextdataRd1_memR),
  .prereg_RoIn0(nextro0_memR),
  .prereg_RoIn1(nextro1_memR),

  .clk_2x(clk_2x), .stall(stall_for_mem),
  //VGA Signals
  .blank(blank),.comp_sync(comp_sync),.hsync(hsync),.vsync(vsync),.pixel_r(pixel_r),.pixel_g(pixel_g),.pixel_b(pixel_b),
	.vga_clk(vga_clk),
	//Inout
	.SW_1(SW_1), .SW_2(SW_2), .SW_3(SW_3),.PB_ENTER(PB_ENTER),.PB_UP(PB_UP),.PB_DOWN(PB_DOWN),.PB_LEFT(PB_LEFT),.PB_RIGHT(PB_RIGHT),.LED_0(LED_0),.CF_MPIRQ(CF_MPIRQ),
	.LED_1(LED_1),.LED_2(LED_2),.LED_3(LED_3),
	.kbd_data(kbd_data),.kbd_clk(kbd_clk)

);
        
endmodule
