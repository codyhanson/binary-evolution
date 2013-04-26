`timescale 1ns / 1ps
module ps2_tx_tb();
	reg clk,clk2,rst;
	wire ps2_data;
	tri ps2_clk;

	reg [7:0] data;
	wire sent;
	reg tbr;

	ps2_tx DUT(clk, rst, 1'b1, ps2_data, ps2_clk, 
	tbr, data, sent);

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end

	initial begin	
		clk2 = 1'b1;
		forever #250 clk2 = ~clk2;
	end
	
	assign ps2_clk = clk2 ? ((ps2_clk==0) ? 1'bz : 1'b1) : 1'b0;

	initial begin	
		rst = 1'b1;
		data = 8'hED;
		tbr = 1'b1;
		#10 rst = 1'b0;

		#50 tbr = 1'b0;
		#1000000 $stop;
	end
endmodule
