module clk_half(input CLKIN_IN, RST_IN,output CLKFX_OUT,CLK0_OUT,LOCKED_OUT);
 assign LOCKED_OUT = 1'b1;
 
 reg clk,clk_5x;
     initial begin
      clk = 1'b0;
      forever #10 clk = ~clk;
     end
     
     initial begin
      clk_5x = 1'b1;
      forever #5 clk_5x = ~clk_5x;
     end
     
     assign CLKFX_OUT = clk;
     assign CLK0_OUT = clk_5x;
     
endmodule

module  clk_prestage(input CLKIN_IN, RST_IN,output CLKFX_OUT,CLK0_OUT,LOCKED_OUT);
   assign CLKFX_OUT = 1'b0;
   assign CLK0_OUT = 1'b0;
   assign LOCKED_OUT = 1'b0;
endmodule

module clk_vga(input CLKIN_IN, RST_IN,output CLKFX_OUT,CLK0_OUT,LOCKED_OUT);
 assign LOCKED_OUT = 1'b1;
 
 reg clk,clk_5x;
     initial begin
      clk = 1'b0;
      forever #12 clk = ~clk;
     end
     
     initial begin
      clk_5x = 1'b1;
      forever #12 clk_5x = ~clk_5x;
     end
     
     assign CLKFX_OUT = clk;
     assign CLK0_OUT = clk_5x;
     
endmodule