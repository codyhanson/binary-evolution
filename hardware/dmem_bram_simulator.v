module dmem_bram_simulator(addra,dina,wea,clka,addrb,dinb,web,clkb,douta,doutb);
   
	parameter ADDRWIDTH = 17;
	parameter DATAWIDTH = 8;
	
	input [ADDRWIDTH-1:0] addra, addrb;
   input [DATAWIDTH-1:0] dina,dinb;
   input wea,clka,web,clkb;
   output [DATAWIDTH-1:0] douta, doutb;
   
   
   reg [DATAWIDTH-1:0] memory [131071:0];
 
 
 integer i;
   initial begin
      for (i = 0; i < 131072; i = i + 1) begin
         memory[i] = i;
      end
   end
   
   reg [ADDRWIDTH-1:0] curaddra,curaddrb;
   always @(posedge clka) begin
      curaddra <= addra;
   end
   always @(posedge clkb) begin
       curaddrb <= addrb;
   end
   
   assign douta = memory[curaddra];
   assign doutb = memory[curaddrb];
   
   always @(posedge clka) begin
      if (wea) begin
         memory[addra] <= dina;
         $display("Wrote 0x%h to 0x%h",dina,addra);
      end
   end
   
	//no nhandling for race if write to both, forwarding
	
 always @(posedge clkb) begin
      if (web) begin
         memory[addrb] <= dinb;
         $display("Wrote 0x%h to %d",dinb,addrb);
      end
   end
   
endmodule
