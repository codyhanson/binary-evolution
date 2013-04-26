`timescale 1ns / 1ps
module top_level_tb();

	reg clk,rst;
	wire [1:0] br_cfg;
	assign br_cfg = 2'b00;
	//looping back txd to rxd
	top_level DUT(.clk(clk),.rst(rst),.br_cfg(br_cfg),.txd(rxd_txd),.rxd(rxd_txd));

	initial begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		rst = 1'b1;
		#10 rst = 1'b0;
		@(posedge DUT.rda) 
		@(posedge DUT.rda) 
		#1000 $stop;
	end

endmodule
