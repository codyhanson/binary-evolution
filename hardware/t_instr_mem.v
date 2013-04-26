module t_instr_mem();
    
    reg clk,rst;
 initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;
 end
 
 reg [29:0] addr = 10'd0;
 always @(posedge clk) begin
    addr = addr + 2'd2; 
 end
 
 initial begin
   rst = 1'b1;
   rst = #20 1'b0;
 end
 wire [31:0] dout0,dout1;
 instr_mem DUT(.clk(clk), .rst(rst), .addrIn(addr), .instr0(dout0), .instr1(dout1));
    
endmodule
