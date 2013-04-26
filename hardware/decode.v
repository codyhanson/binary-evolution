/* Module:	Decode

Description:		

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by: Eric H.
Edited by:		
Module interface by:	

Date:			

*/

module decode(clk,rst,instr0,instr1,
        addrWriteBack0,addrWriteBack1,writeBackEn0,writeBackEn1,
        dataWriteBack0,dataWriteBack1,
        rm0_ex,rm1_ex,rn0_ex,rn1_ex,ro0_ex, ro1_ex,
        addrRd0_ex,addrRd1_ex,opCode0_ex,opCode1_ex,
        nextPC_fetch, stall_decode, hazardStall0, hazardStall1,addrRm0,addrRm1,addrRn0,addrRn1,
        
        stall0,stall1,branch_en,branch_addr,
        halt_in_wb
        );
        
        //Discussion: How do we update the PC on a branch
        
        //Discussion: On dump should we just let the dump logic be in this stage.
        
        
input clk,rst,stall_decode,hazardStall0,hazardStall1;
input [31:0] instr0,instr1;
input [4:0] addrWriteBack0, addrWriteBack1;
input [39:0] dataWriteBack0, dataWriteBack1;
input writeBackEn0, writeBackEn1, halt_in_wb;
input branch_en;
input [29:0] branch_addr;

output reg [39:0] rm0_ex, rm1_ex, rn0_ex, rn1_ex, ro0_ex, ro1_ex;
output reg [4:0] addrRd0_ex, addrRd1_ex;
output [4:0] addrRm0, addrRm1, addrRn0, addrRn1;
//ro is the third operand and is used by the Mov w/ shift and by the memory operations 
//  since they pass the pc and offset in rm and rn and have nowhere to pass the data. Also the BL uses it

output [4:0] opCode0_ex, opCode1_ex; //Will have to change width
output [29:0] nextPC_fetch; //PC is 32 bits but is word aligned so output only MSBs
output stall0, stall1;



`include "opcodes.inc"
 localparam UNUSED = 5'd31; //Used to signal to RF that the read/write is unused.

reg [4:0] addrRm0_rf,addrRn0_rf,addrRm1_rf,addrRn1_rf;
reg halt_latch;

//Option: Just chose to implement
wire writeEn0_rf, writeEn1_rf;
assign writeEn0_rf = (writeBackEn0&&(addrWriteBack0!=5'b11111)); //Don't enable WB on PC update
assign writeEn1_rf = (writeBackEn1&&(addrWriteBack1!=5'b11111)); //Don't enable WB on PC update

//PC Values PC Logic at bottom
reg [29:0] pc, next_pc;

//Register File (does not contain PC)
wire [39:0] rm0, rm1, rn0, rn1; //Don't put on outputs just yet.

assign addrRm0 = addrRm0_rf;
assign addrRm1 = addrRm1_rf;
assign addrRn0 = addrRn0_rf;
assign addrRn1 = addrRn1_rf;

      
 regFile regFile0(.clk(clk),.rst(rst),.addrRd0(addrRm0_rf),
   .addrRd1(addrRn0_rf),.addrRd2(addrRm1_rf), .addrRd3(addrRn1_rf),
   .addrWr0(addrWriteBack0),.addrWr1(addrWriteBack1),.dataRd0(rm0),.dataRd1(rn0),
      .dataRd2(rm1),.dataRd3(rn1),
      .dataInWr0(dataWriteBack0),.dataInWr1(dataWriteBack1),
      .writeEn0(writeEn0_rf&&!halt_latch), .writeEn1(writeEn1_rf&&!halt_latch));

//Address Resolution
//addrRm0_rf,addrRn0_rf,addrR2_rf,addrR3_rf also available


//Forwarding Logic

//Decoding Logic
reg instr0RequiresBothPipes;
reg instr1RequiresBothPipes;

reg inst0_hasWB; //TODO: IMPLEMENT


always @(*) begin
    //Defaults
	ro0_ex = 40'hx; //Only used for STR and MOV w/ Shifts
	ro1_ex = 40'hx; //Only used for STR and MOV w/ Shifts
	instr0RequiresBothPipes = 1'b0;
	instr1RequiresBothPipes = 1'b0;
   inst0_hasWB = 1'b1; //Default assumes every instruction writes back
////////////////Upper Pipe Decode///////////////////////
	case(instr0[31:27])
	 ADD : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 AND : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 BIC : begin 
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 NOOP : begin 
	  rm0_ex = 40'hX;
	  addrRm0_rf = UNUSED;
	  addrRn0_rf = UNUSED;
	  rn0_ex = 40'hX;
	  addrRd0_ex = UNUSED;
	  inst0_hasWB = 1'b0;
	  end
	 OR : begin 
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 RSB : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 SUB : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{28{instr0[11]}},instr0[11:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  end
	 SWP : begin //USES both paths
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  instr0RequiresBothPipes = 1'b1;
	  end
	 ACCUMBYTES : begin //Neighborhood op but can be done in a single pipe. 
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = rn0; 
	  addrRd0_ex = instr0[21:17];
	  instr0RequiresBothPipes = 1'b1; //Well not really but it requires more than one cycle
	  end
	  
	 //Neighborhood Ops that occupy both paths. Special Logic on the second pipe for this
	 MXMUL : begin //TODO: figure out why we are using an immediate here
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  instr0RequiresBothPipes = 1'b1;
	  //Other half of logic is defined on second case statement.
	  end
	 MXADD : begin//TODO: figure out why we are using an immediate here
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  instr0RequiresBothPipes = 1'b1;
	  end
	 MXSUB : begin//TODO: figure out why we are using an immediate here
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = instr0[21:17];
	  instr0RequiresBothPipes = 1'b1;
	  end
	 B : begin
	  rm0_ex = pc; //TODO: Expand 
	  addrRm0_rf = UNUSED;
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[21:17]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{18{instr0[21]}},instr0[21:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = UNUSED;
	  end
	 BL : begin
	  rm0_ex = pc;
	  addrRm0_rf = UNUSED;
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[21:17]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{18{instr0[21]}},instr0[21:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = 5'd30; //Store pc back in R30 so we'll also pass it to the mem stage via ro
	  ro0_ex = pc;
	  end
	 CMP : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[21:17];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[16:12]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{23{instr0[16]}},instr0[16:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = UNUSED;
	  inst0_hasWB = 1'b0;
	  end
	 MOV : begin
	  rm0_ex = (instr0[22]) ? {{23{instr0[16]}},instr0[16:0]} : rm0;
	  addrRm0_rf = (instr0[22]) ? UNUSED : instr0[16:12];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[11:7]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? 40'hX  : rn0; //Only need Rn if not using immediate type
	  addrRd0_ex = instr0[21:17];
	  ro0_ex = (instr0[22]) ? {38'h0, 2'b11} : {38'h0, instr0[6:5]}; //Shift Type passed through on unused ro0
	  end
	 NOT : begin 
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = UNUSED; //Don't care if we're using immediate
	  rn0_ex = 40'hX; //Only need Rn if not using immediate type
	  addrRd0_ex = instr0[21:17];
	  end
	 TEQ : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[21:17];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[16:12]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{23{instr0[16]}},instr0[16:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = UNUSED;
	  inst0_hasWB = 1'b0;
	  end
	 TST : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[21:17];
	  addrRn0_rf = (instr0[22]) ? UNUSED : instr0[16:12]; //Don't care if we're using immediate
	  rn0_ex = (instr0[22]) ? {{23{instr0[16]}},instr0[16:0]} : rn0; //Sign extend Immediate or the value.
	  addrRd0_ex = UNUSED;
	  inst0_hasWB = 1'b0;
	  end
	 BWCMPL : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[16:12];
	  addrRn0_rf = UNUSED; //Don't care if we're using immediate
	  rn0_ex = 40'hX; //Only need Rn if not using immediate type
	  addrRd0_ex = instr0[21:17];
	  end
	 LDR : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  end
	 LDRB : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  end
	 LDRH : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  end
	 LDRSB : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  end
	 LDRSH : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  end
	  //TODO: Figure out how stores are going to work
	 STR : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = instr0[22:18]; //Load value to store in Rn 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = UNUSED; 
	  ro0_ex = rn0; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  inst0_hasWB = 1'b0;
	  end
	 STRB : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = instr0[22:18]; //Load value to store in Rn 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = UNUSED; 
	  ro0_ex = rn0; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  inst0_hasWB = 1'b0;
	  end
	 STRH : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = instr0[22:18]; //Load value to store in Rn 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = UNUSED; 
	  ro0_ex = rn0; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  inst0_hasWB = 1'b0;
	  end
	 //Neighborhood Ops take both pipes but the second half of the instructions are implemented in the second case
	 LDNEIGHBOR : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = UNUSED; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = instr0[22:18];
	  instr0RequiresBothPipes = 1'b1;
	  end
	 STRNEIGHBOR : begin
	  rm0_ex = rm0;
	  addrRm0_rf = instr0[17:13];
	  addrRn0_rf = instr0[22:18]; 
	  rn0_ex = {{27{instr0[12]}},instr0[12:0]};
	  addrRd0_ex = UNUSED;
	  ro0_ex = rn0; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage 
	  instr0RequiresBothPipes = 1'b1;
	  inst0_hasWB = 1'b0;
	  end
	 RETURN : begin
	  rm0_ex = rm0;
	  addrRm0_rf = 5'd30; //Read the LR
	  addrRn0_rf = UNUSED; 
	  rn0_ex = 40'hx;
	  addrRd0_ex = UNUSED;
	  end
	 HALT : begin
	  rm0_ex = 40'hX;
	  addrRm0_rf = UNUSED;
	  addrRn0_rf = UNUSED; 
	  rn0_ex = 40'hx;
	  addrRd0_ex = UNUSED;
	  end
	endcase
	
	
////////////////Lower Pipe Decode///////////////////////
//Remember only the first match is used in the case of multiple matches

	casex({instr0[31:27],instr1[31:27]})
	//Put when pipe0 needs both pipes first, then instr0 solely controls
	{HALT,5'hx} : begin
	  rm1_ex = 40'hX;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED; 
	  rn1_ex = 40'hx;
	  addrRd1_ex = UNUSED;
	  end
	{ACCUMBYTES,5'hx} : begin //TODO: Discuss with Ben about the format he wants the data in
	  rm1_ex = rm1;
	  addrRm1_rf = instr0[16:12];
	  addrRn1_rf = instr0[11:7];
	  rn1_ex = rn1; 
	  addrRd1_ex = UNUSED;
	  end
	{SWP,5'hx} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr0[11:7]; //Swaped from first pipe
	  addrRn1_rf = instr0[16:12];
	  rn1_ex = rn1; 
	  addrRd1_ex = instr0[11:7];
	 end
	{MXMUL,5'hx} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr0[16:12] + 1'b1;
	  addrRn1_rf = instr0[11:7] + 1'b1;
	  rn1_ex = rn1; 
	  addrRd1_ex = instr0[21:17] + 1'b1;
	 end
	{MXADD,5'hx} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr0[16:12] + 1'b1;
	  addrRn1_rf = instr0[11:7] + 1'b1;
	  rn1_ex = rn1; 
	  addrRd1_ex = instr0[21:17] + 1'b1;
	 end
	{MXSUB,5'hx} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr0[16:12] + 1'b1;
	  addrRn1_rf = instr0[11:7] + 1'b1;
	  rn1_ex = rn1; 
	  addrRd1_ex = instr0[21:17] + 1'b1;
	 end
	{LDNEIGHBOR,5'hx} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED; 
	  rn1_ex = 40'hx;
	  addrRd1_ex = instr0[22:18] + 1'b1; //Second half going to second register
	 end
	{STRNEIGHBOR,5'hx} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = instr0[22:18] + 1'b1; //We want Rm and Rm+1, this pipe gets RM+1
	  rn1_ex = 40'hx;
	  addrRd1_ex = UNUSED;
	  ro1_ex = rn1; //Putting on RO to be consistent with first pipe
	 end
	  
	//Standard Instructions
	 {5'hx,ADD} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,AND} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,BIC} : begin 
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,NOOP} : begin 
	  rm1_ex = 40'hX;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hX;
	  addrRd1_ex = UNUSED;
	  end
	 {5'hx,OR} : begin 
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,RSB} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,SUB} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{28{instr1[11]}},instr1[11:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,SWP} : begin //USES both paths
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	 {5'hx,ACCUMBYTES} : begin 
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	  
	 //Neighborhood Ops that occupy both paths. Special Logic on the second pipe for this
	 {5'hx,MXMUL} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  //Other half of logic is defined on second case statement.
	  end
	 {5'hx,MXADD} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	 {5'hx,MXSUB} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	 {5'hx,B} : begin
	  rm1_ex = pc + 1'b1; 
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[21:17]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{18{instr1[21]}},instr1[21:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = UNUSED;
	  end
	 {5'hx,BL} : begin
	  rm1_ex = pc + 1'b1;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[21:17]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{18{instr1[21]}},instr1[21:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = 5'd30; //Store pc back in R30 so we'll also pass it to the mem stage via ro
	  ro1_ex = pc;
	  end
	 {5'hx,CMP} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[21:17];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[16:12]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{23{instr1[16]}},instr1[16:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = UNUSED;
	  end
	 {5'hx,MOV} : begin
	  rm1_ex = (instr1[22]) ? {{23{instr1[16]}},instr1[16:0]} : rm1;
	  addrRm1_rf = (instr1[22]) ? UNUSED : instr1[16:12];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[11:7]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? 40'hX  : rn1; //Only need Rn if not using immediate type
	  addrRd1_ex = instr1[21:17];
	  ro1_ex = (instr1[22]) ? {38'h0, 2'b11} : {38'h0, instr1[6:5]}; //Shift Type passed through on unused ro1
	  end
	 {5'hx,NOT} : begin 
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = UNUSED; //Don't care if we're using immediate
	  rn1_ex = 40'hX; //Only need Rn if not using immediate type
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,TEQ} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[21:17];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[16:12]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{23{instr1[16]}},instr1[16:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = UNUSED;
	  end
	 {5'hx,TST} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[21:17];
	  addrRn1_rf = (instr1[22]) ? UNUSED : instr1[16:12]; //Don't care if we're using immediate
	  rn1_ex = (instr1[22]) ? {{23{instr1[16]}},instr1[16:0]} : rn1; //Sign extend Immediate or the value.
	  addrRd1_ex = UNUSED;
	  end
	 {5'hx,BWCMPL} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[16:12];
	  addrRn1_rf = UNUSED; //Don't care if we're using immediate
	  rn1_ex = 40'hX; //Only need Rn if not using immediate type
	  addrRd1_ex = instr1[21:17];
	  end
	 {5'hx,LDR} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = UNUSED; 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = instr1[22:18];
	  end
	 {5'hx,LDRB} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = UNUSED; 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = instr1[22:18];
	  end
	 {5'hx,LDRH} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = UNUSED; 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = instr1[22:18];
	  end
	 {5'hx,LDRSB} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = UNUSED; 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = instr1[22:18];
	  end
	 {5'hx,LDRSH} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = UNUSED; 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = instr1[22:18];
	  end
	  //TODO: Figure out how stores are going to work
	 {5'hx,STR} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = instr1[22:18]; //Load value to store in Rn 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = UNUSED; 
	  ro1_ex = rn1; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  end
	 {5'hx,STRB} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = instr1[22:18]; //Load value to store in Rn 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = UNUSED; 
	  ro1_ex = rn1; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  end
	 {5'hx,STRH} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = instr1[17:13];
	  addrRn1_rf = instr1[22:18]; //Load value to store in Rn 
	  rn1_ex = {{27{instr1[12]}},instr1[12:0]};
	  addrRd1_ex = UNUSED; 
	  ro1_ex = rn1; //Since we put shift amount on rn we map data to the data reg to be passed to mem stage
	  end
	 //Neighborhood Ops take both pipes but the second half of the instructions are implemented in the second case
	 {5'hx,LDNEIGHBOR} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	 {5'hx,STRNEIGHBOR} : begin
	  rm1_ex = 40'hx;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED;
	  rn1_ex = 40'hx; 
	  addrRd1_ex = UNUSED;	  
	  instr1RequiresBothPipes = 1'b1;
	  end
	 {5'hx,RETURN} : begin
	  rm1_ex = rm1;
	  addrRm1_rf = 5'd30; //Read the LR
	  addrRn1_rf = UNUSED; 
	  rn1_ex = 40'hx;
	  addrRd1_ex = UNUSED; 
	  end
	 {5'hx,HALT} : begin
	  rm1_ex = 40'hX;
	  addrRm1_rf = UNUSED;
	  addrRn1_rf = UNUSED; 
	  rn1_ex = 40'hx;
	  addrRd1_ex = UNUSED;
	  end
	  default : begin
	   rm1_ex = 40'hX;
	   addrRm1_rf = UNUSED;
	   addrRn1_rf = UNUSED; 
	   rn1_ex = 40'hx;
	   addrRd1_ex = UNUSED;
	  
	  end
	endcase
end


assign scalarhazard = ~instr0RequiresBothPipes && inst0_hasWB &&(instr1[31:27]!=NOOP)&& (addrRd0_ex!=UNUSED)&&((addrRd0_ex==addrRm1_rf)||(addrRd0_ex==addrRn1_rf));
//What about if the data is in the execute stage??? 
wire inst1_stall,inst0_stall;
assign inst0_stall = (stall_decode||hazardStall0); //External Stall (likely from neighborhood op or cache miss)
assign inst1_stall = (instr1RequiresBothPipes||instr0RequiresBothPipes||scalarhazard||inst0_stall||hazardStall1);



assign opCode0_ex = (inst0_stall||halt_latch) ? NOOP : instr0[31:27];
assign opCode1_ex =  (instr0RequiresBothPipes) ? opCode0_ex : ((inst1_stall||(instr0[31:27]==HALT)||halt_latch) ? NOOP : instr1[31:27]); //Don't send down second pipe if first instruction is halt


//PC Logic.

always @(posedge clk) begin
   if (rst) begin halt_latch <= 1'b0; end
   else begin
     halt_latch <= halt_in_wb || halt_latch;
   end 
end
always @(posedge clk) begin
   if (rst) begin pc <= 29'b0; end
   else begin
      pc <= nextPC_fetch; 
   end
end

// If we see a halt in pipe 1, we keep fetching that halt
always @ (*) begin
  casex({inst0_stall,inst1_stall})
      2'b00 : next_pc = pc + 30'd2; //Both instructions were sent down the pipe
      2'b01 : next_pc = pc + 30'd1; //Only top instruction sent
      2'b1X : next_pc = pc; //top instruction stalled so we stall both (for now)
  endcase
end

assign nextPC_fetch = (rst) ? 29'b0 : ((branch_en) ? branch_addr : next_pc);
assign stall0 = inst0_stall && ~branch_en;
assign stall1 = inst1_stall && ~branch_en;

//Data Dependency Detectors for Execute stage
//Regfile forwards from WB stage. We just need to track what is in execute and determine if data forwarding needs to happen.

endmodule
        
