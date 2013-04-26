module t_dmem_bram_simulator();
    reg clk;
    initial begin
         clk = 1'b0;
         forever #1 clk = ~clk;
     end
     
  reg [16:0] addra, addrb;
   reg [39:0] dina,dinb;
   reg wea,web;
   
    dmem_bram_simulator DUT(.addra(addra),.dina(dina),.wea(wea),.clka(clk),.addrb(addrb),.dinb(dinb),.web(web),
      .clkb(clk),.douta(),.doutb());
      
      initial begin
         @(negedge clk);
         wea = 1'b1;
         web = 1'b1;
         addra = 17'h0;
         dina = 40'd1;
         addrb = 17'h1;
         dinb = 40'd2; 
        @(negedge clk);
         addra = 17'h2;
         dina = 40'd2;
         web = 1'b0;
         addrb = 17'h3;
         dinb = 40'd20; 
        @(negedge clk);
        web = 1'b1;
         addra = 17'h3;
         dina = 40'd3;
         addrb = 17'h4;
         dinb = 40'd4; 
        @(negedge clk);
         addra = 17'h5;
         dina = 40'd5;
         addrb = 17'h6;
         dinb = 40'd6; 
        @(negedge clk);
         addra = 17'h7;
         dina = 40'd7;
         addrb = 17'h1;
         dinb = 40'd8; 
        @(negedge clk);
        web = 1'b0;
        wea = 1'b0;
         addra = 17'h7;
         dina = 40'd1;
         addrb = 17'h8;
         dinb = 40'd2; 
        @(negedge clk);
        addra = 17'h0;
        addrb = 17'h0;
        @(negedge clk);
         addra = 17'h1;
         addrb = 17'h2;
        @(negedge clk);
         addra = 17'h3;
         addrb = 17'h4;
        @(negedge clk);
         addra = 17'h5;
         addrb = 17'h6;
        @(negedge clk);
         addra = 17'h7;
         addrb = 17'h8;
          
      end
    
endmodule
