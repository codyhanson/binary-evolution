module fake_physical_memory(clk,addrIn0, addrIn1, we0, we1, rden0, rden1, NeighborMode, length0, length1, dataIn0, dataIn1, dataOut0, dataOut1);
  input [39:0] addrIn0, addrIn1;
  input clk,we0,we1,rden0,rden1,NeighborMode;
  input [1:0] length0,length1; //Ignored for reads right now
  input [39:0] dataIn0, dataIn1;
  output reg [39:0] dataOut0, dataOut1;

  localparam BYTEWIDE = 2'b00;
  localparam HALFWIDE = 2'b01;
  localparam WORDWIDE = 2'b10;
  
  localparam MEMWIDTH = 7'd10;

  //Sample using a 10 x 10 grid of bytes
  reg [7:0] memory[99:0];
  
  //Read logic
  //SYNTH VERSION
  always @(rden0,NeighborMode,addrIn0,addrIn1,rden1,dataIn0,we0) begin
//SIM VERSION
//always @(*) begin
      if (rden0&&NeighborMode) begin
          //Nothing yet
             dataOut0[7:0]=memory[addrIn0[6:0]+7'd1];
             dataOut0[15:8]=memory[addrIn0[6:0]- MEMWIDTH + 7'd1];
             dataOut0[23:16]=memory[addrIn0[6:0]- MEMWIDTH];
             dataOut0[31:24]=memory[addrIn0[6:0]- MEMWIDTH - 7'd1];
             dataOut0[39:32]=8'd0;
             dataOut1[7:0]=memory[addrIn0[6:0]+ MEMWIDTH + 7'd1];
             dataOut1[15:8]=memory[addrIn0[6:0]+ MEMWIDTH];
             dataOut1[23:16]=memory[addrIn0[6:0]+MEMWIDTH - 7'd1];
             dataOut1[31:24]=memory[addrIn0[6:0]-7'd1];
             dataOut1[39:32]=memory[addrIn0[6:0]];
      end else begin
          if (rden0) begin
             dataOut0[7:0]=memory[addrIn0[6:0]+7'd4];
             dataOut0[15:8]=memory[addrIn0[6:0]+7'd3];
             dataOut0[23:16]=memory[addrIn0[6:0]+7'd2];
             dataOut0[31:24]=memory[addrIn0[6:0]+7'd1];
             dataOut0[39:32]=memory[addrIn0[6:0]];
          end else begin
			    dataOut0 = 40'hx;
			 end
          if (rden1) begin
              if (addrIn1==addrIn0 && we0) begin
               dataOut1=dataIn0; //Detect data collison   
              end else begin
               dataOut1[7:0]=memory[addrIn1[6:0]+7'd4];
               dataOut1[15:8]=memory[addrIn1[6:0]+7'd3];
               dataOut1[23:16]=memory[addrIn1[6:0]+7'd2];
               dataOut1[31:24]=memory[addrIn1[6:0]+7'd1];
               dataOut1[39:32]=memory[addrIn1[6:0]];
             end
          end else begin
               dataOut1 = 40'hx;
          end			 
      end
      
  end
  
  //Write Logic
  always @(posedge clk) begin
      //Nobody really knows what to do on conflicts
     if (NeighborMode&&we0) begin
         memory[addrIn0[6:0]-MEMWIDTH-7'd1] <= dataIn0[31:24];
         memory[addrIn0[6:0]-MEMWIDTH] <= dataIn0[23:16];
         memory[addrIn0[6:0]-MEMWIDTH+7'd1] <= dataIn0[15:8];
         memory[addrIn0[6:0] - 7'd1] <= dataIn1[31:24];
         memory[addrIn0[6:0]] <= dataIn1[39:32]; 
         memory[addrIn0[6:0] + 7'd1] <= dataIn0[7:0];
         memory[addrIn0[6:0] + MEMWIDTH - 7'd1] <= dataIn1[23:16];
         memory[addrIn0[6:0] + MEMWIDTH] <= dataIn1[15:8];
         memory[addrIn0[6:0] + MEMWIDTH + 7'd1] <= dataIn1[7:0];
     end else begin    
      if (we0) begin
		   if (length0==BYTEWIDE) begin
			 memory[addrIn0[6:0]+7'd4] <= dataIn0[7:0];
			end else if (length0==HALFWIDE) begin
			 memory[addrIn0[6:0]+7'd4] <= dataIn0[7:0];
          memory[addrIn0[6:0]+7'd3] <= dataIn0[15:8];
			end else begin
          memory[addrIn0[6:0]+7'd4] <= dataIn0[7:0];
          memory[addrIn0[6:0]+7'd3] <= dataIn0[15:8];
          memory[addrIn0[6:0]+7'd2] <= dataIn0[23:16];
          memory[addrIn0[6:0]+7'd1] <= dataIn0[31:24];
          memory[addrIn0[6:0]] <= dataIn0[39:32];
			end
      end 
      if (we1) begin
		  if (length1==BYTEWIDE) begin
         memory[addrIn1[6:0]+7'd4] <= dataIn1[7:0];
         memory[addrIn1[6:0]+7'd3] <= dataIn1[15:8];
		  end else if (length1==HALFWIDE) begin
         memory[addrIn1[6:0]+7'd4] <= dataIn1[7:0];
         memory[addrIn1[6:0]+7'd3] <= dataIn1[15:8];
		  end else begin
         memory[addrIn1[6:0]+7'd4] <= dataIn1[7:0];
         memory[addrIn1[6:0]+7'd3] <= dataIn1[15:8];
         memory[addrIn1[6:0]+7'd2] <= dataIn1[23:16];
         memory[addrIn1[6:0]+7'd1] <= dataIn1[31:24];
         memory[addrIn1[6:0]] <= dataIn1[39:32]; 
		 end
      end
    end //End NeighborMode If
  end
  
endmodule