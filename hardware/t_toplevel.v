module t_toplevel();
    
    reg clk,clk_5x,rst;
     initial begin //is ignored by toplevel
      clk = 1'b0;
      forever #25 clk = ~clk;
     end
     

     initial begin
       rst = 1'b1;
       rst = #50 1'b0;
     end
    
    toplevel DUT(.CLK_100MHZ(clk), .rst(rst), .CLK_25MHZ(),
    .blank(), .comp_sync(), .hsync(), .vsync(), .pixel_r(), .pixel_g(), .pixel_b());
    
       //.addrWriteBack0(addrRd0_memR),.addrWriteBack1(addrRd1_memR),.writeBackEn0(wbEn0_decode),.writeBackEn1(wbEn1_decode),
      // .dataWriteBack0(dataWriteBack0),.dataWriteBack1(dataWriteBack1),
    
    always @(posedge DUT.clk) begin
       if (DUT.wbEn0_decode) begin
           $display("R%d Wrote %h -- PC Estimate:%h",DUT.addrRd0_memR,DUT.dataWriteBack0,DUT.pc_fetch-6);
       end
       
       if (DUT.wbEn1_decode) begin
           $display("R%d Wrote %h -- PC Estimate:%h",DUT.addrRd1_memR,DUT.dataWriteBack1,DUT.pc_fetch-5);
       end
        
    end
    
endmodule
