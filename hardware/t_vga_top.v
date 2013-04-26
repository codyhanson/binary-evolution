module t_vga_top();
        reg clk,clk_5x,rst;
    initial begin
         clk = 1'b0;
         forever #5 clk = ~clk;
     end
    initial begin
        clk_5x = 1'b0;
        forever #1 clk_5x = ~clk_5x;
    end
    
     initial begin
         rst = 1'b1;
         @(negedge clk);
         @(negedge clk);
          @(negedge clk);
           @(negedge clk);
            @(negedge clk);
             @(negedge clk);
         rst = 1'b0;
     end
     
     vga_top DUT(.rst(rst));
endmodule
