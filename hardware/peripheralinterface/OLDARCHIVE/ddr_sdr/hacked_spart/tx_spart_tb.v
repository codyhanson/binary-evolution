`timescale 1ns / 1ns
module tx_spart_tb();

	reg clk,rst;
	reg iorw;
	reg [1:0] ioaddr;
	reg [7:0] databus;
	
	brg_spart BRG(.clk(clk),.rst(rst),.ioaddr(ioaddr),.databus(databus),
		.brg_en(brg_en),.brg_full(brg_full));

	tx_spart DUT(.txd(txd), .tbr(tbr), .clk(clk),.rst(rst),
		.iorw(iorw),.brg_full(brg_full),
		.databus(databus), .ioaddr(ioaddr));

	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end


	initial begin	
		rst = 1'b1;
		iorw = 1'b1; // "read", so TX shouldn't do anything
		ioaddr = 2'b00;
		#10 rst = 1'b0;
		ioaddr = 2'b10;
		databus = 8'h05;
		#10 ioaddr = 2'b11;
		databus = 8'h00;
		#10 ioaddr = 2'b00;
		
		#200 databus = 8'h6a; // should TX ...1111| 0| 0101 0110 |111111...
		iorw = 1'b0; // begin TX'ing
		#10 iorw = 1'b1;

		// Since we left iorw as "Write", TX should loop.
		@(posedge tbr)
		#10 databus = 8'hf3; // 0| 1111 0011
		#1000 iorw = 1'b0; // Begin TX'ing the new byte

		@(posedge tbr);
		@(posedge tbr);	
		 $stop;
	end
endmodule
