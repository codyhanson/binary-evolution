module exec_hazard_detector(
  rm0_in,rm1_in,rn0_in,rn1_in,
  ro0_in,ro1_in,addrRm0,addrRm1,
  addrRn0,addrRn1,
  opCode0_dec, //Don't use output of decode stage or will form loop
  opCode1_dec,
  //Inputs from Decode
  opCode0_exe,
  opCode1_exe,
  execDataIn0,
  execDataIn1,
  addrRd0_exe,
  addrRd1_exe,
  //Outputs
  hazardStall0,
  hazardStall1,
  rm0_out,
  rm1_out,
  rn0_out,
  rn1_out,
  ro0_out,
  ro1_out
);
  input [39:0] rm0_in,rm1_in,rn0_in,rn1_in,ro0_in,ro1_in;
  input [4:0] addrRm0,addrRm1,addrRn0,addrRn1;
  input [4:0] opCode0_dec,opCode1_dec,opCode0_exe,opCode1_exe,addrRd0_exe,addrRd1_exe;
  input [39:0] execDataIn0,execDataIn1;
  
  //Outputs
  output hazardStall0,hazardStall1;
  output [39:0] rm0_out,rm1_out,rn0_out,rn1_out,ro0_out,ro1_out;
  
  `include "opcodes.inc"
  localparam UNUSED = 5'd31; //Used to signal to RF that the read/write is unused.
  
  reg pipe0Writes, pipe1Writes;
  reg pipe0Resolvable, pipe1Resolvable; 
  //If instruction in execute is a load there is no way to resolve it.
  
  
  always @(*) begin
      pipe0Writes = 1'b1; //Default
      pipe1Writes = 1'b1; //Default
      pipe0Resolvable = 1'b1; //Default
      pipe1Resolvable = 1'b1; //Default
     case(opCode0_exe)
         NOOP: begin pipe0Writes = 1'b0; end
         B: begin pipe0Writes = 1'b0; end
         CMP: begin  pipe0Writes = 1'b0; end
         TEQ: begin  pipe0Writes = 1'b0;  end
         TST: begin  pipe0Writes = 1'b0;  end
         LDR: begin  pipe0Resolvable = 1'b0; end
         LDRB: begin  pipe0Resolvable = 1'b0; end
         LDRH: begin  pipe0Resolvable = 1'b0; end
         LDRSB: begin  pipe0Resolvable = 1'b0; end
         LDRSH:begin  pipe0Resolvable = 1'b0; end
         STR: begin pipe0Writes = 1'b0; end
         STRB: begin pipe0Writes = 1'b0; end
         STRH: begin pipe0Writes = 1'b0; end
         LDNEIGHBOR: begin  pipe0Resolvable = 1'b0; end
         STRNEIGHBOR: begin pipe0Writes = 1'b0; end
         RETURN: begin  pipe0Writes = 1'b0; end
         HALT: begin  pipe0Writes = 1'b0;  end
     endcase
    
     casex({opCode0_exe,opCode1_exe})
         {ACCUMBYTES,5'hx} : begin pipe1Writes = 1'b0;  end//Default Is Fine
	      {SWP,5'hx} : begin end//Default Is Fine
	      {MXMUL,5'hx} : begin end//Default Is Fine
	      {MXADD,5'hx} : begin end//Default Is Fine
	      {MXSUB,5'hx} : begin end//Default Is Fine
         {LDNEIGHBOR,5'hx} : begin  pipe1Resolvable = 1'b0;   end
         {STRNEIGHBOR,5'hx} : begin pipe1Writes = 1'b0;       end
         {5'hX,NOOP}: begin pipe1Writes = 1'b0; end
         {5'hX,B}: begin pipe1Writes = 1'b0; end
         {5'hX,CMP}: begin  pipe1Writes = 1'b0; end
         {5'hX,TEQ}: begin  pipe1Writes = 1'b0;  end
         {5'hX,TST}: begin  pipe1Writes = 1'b0;  end
         {5'hX,LDR}: begin  pipe1Resolvable = 1'b0;   end
         {5'hX,LDRB}: begin  pipe1Resolvable = 1'b0;   end
         {5'hX,LDRH}: begin  pipe1Resolvable = 1'b0;   end
         {5'hX,LDRSB}: begin  pipe1Resolvable = 1'b0;   end
         {5'hX,LDRSH}: begin  pipe1Resolvable = 1'b0;   end
         {5'hX,STR}: begin  pipe1Writes = 1'b0;  end
         {5'hX,STRB}: begin  pipe1Writes = 1'b0;  end
         {5'hX,STRH}: begin  pipe1Writes = 1'b0;  end
         {5'hX,LDNEIGHBOR}: begin
           //Should Not Happen
           pipe1Resolvable = 1'bX;
         end
         {5'hX,STRNEIGHBOR}: begin
           //Should Not Happen
           pipe1Resolvable = 1'bX;
         end
         {5'hX,RETURN}: begin  pipe1Writes = 1'b0; end
         {5'hX,HALT}: begin  pipe1Writes = 1'b0;  end
     endcase 
      
      
  end
  
  
  
  
  
  
 
  
  wire forward0toRm0, forward0toRn0, forward0toRm1, forward0toRn1;
  wire forward1toRm0, forward1toRn0, forward1toRm1, forward1toRn1;
  

assign forward1toRm0 = ((addrRm0!=UNUSED)&&(addrRm0==addrRd1_exe)&&pipe1Writes);
assign forward0toRm0 = ~forward1toRm0 &&(addrRm0!=UNUSED)&&(addrRm0==addrRd0_exe)&&pipe0Writes;       
assign forward1toRm1 = (addrRm1!=UNUSED)&&(addrRm1==addrRd1_exe)&&pipe1Writes;
assign forward0toRm1 = ~forward1toRm1 &&(addrRm1!=UNUSED)&&(addrRm1==addrRd0_exe)&&pipe0Writes;  

assign forward1toRn0 = (addrRn0!=UNUSED)&&(addrRn0==addrRd1_exe)&&pipe1Writes;
assign forward0toRn0 = ~forward1toRn0 &&(addrRn0!=UNUSED)&&(addrRn0==addrRd0_exe)&&pipe0Writes;       
assign forward1toRn1 = (addrRn1!=UNUSED)&&(addrRn1==addrRd1_exe)&&pipe1Writes;
assign forward0toRn1 = ~forward1toRn1 &&(addrRn1!=UNUSED)&&(addrRn1==addrRd0_exe)&&pipe0Writes; 
     
 

//May be forward won't work based on Opcode in Execute (Specifically Stores)
assign hazardStall0 = (forward0toRm0&&!pipe0Resolvable) || (forward0toRn0&&!pipe0Resolvable) || (forward1toRm0&&!pipe1Resolvable)|| (forward1toRn0&&!pipe1Resolvable);
assign hazardStall1 = (forward0toRm1&&!pipe0Resolvable) || (forward0toRn1&&!pipe0Resolvable) || (forward1toRm1&&!pipe1Resolvable)|| (forward1toRn1&&!pipe1Resolvable);


//Actual Forwarding
wire ro0_maps_rn, ro1_maps_rn;
assign ro0_maps_rn = (opCode0_dec==STR)||(opCode0_dec==STRB)||(opCode0_dec==STRH)||(opCode0_dec==STRNEIGHBOR);
assign ro1_maps_rn = (opCode1_dec==STR)||(opCode1_dec==STRB)||(opCode1_dec==STRH)||(opCode0_dec==STRNEIGHBOR); //Last item left 0 intentionally

wire [39:0] rn0val,rn1val,ro0val,ro1val;
assign rm0_out = (forward1toRm0) ? execDataIn1 : ((forward0toRm0)? execDataIn0 : rm0_in);
assign rm1_out = (forward1toRm1) ? execDataIn1 : ((forward0toRm1)? execDataIn0 : rm1_in);

assign rn0val = (forward1toRn0) ? execDataIn1 : ((forward0toRn0)? execDataIn0 : rn0_in);
assign rn1val = (forward1toRn1) ? execDataIn1 : ((forward0toRn1)? execDataIn0 : rn1_in);

assign ro0val = (forward1toRn0) ? execDataIn1 : ((forward0toRn0)? execDataIn0 : ro0_in);
assign ro1val = (forward1toRn1) ? execDataIn1 : ((forward0toRn1)? execDataIn0 : ro1_in);

assign rn0_out = (ro0_maps_rn) ? rn0_in : rn0val; //If RO is the true conflict pass through
assign ro0_out = (ro0_maps_rn) ? ro0val : ro0_in; //If RO is not Rn then pass ro through


assign rn1_out = (ro1_maps_rn) ? rn1_in : rn1val; //If RO is the true conflict pass through
assign ro1_out = (ro1_maps_rn) ? ro1val : ro1_in; //If RO is not Rn then pass ro through


endmodule

