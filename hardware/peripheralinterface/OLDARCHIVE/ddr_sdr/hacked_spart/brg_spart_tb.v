`timescale 1ns / 1ns
module brg_spart_tb();


	reg clk,rst;
	reg [1:0] ioaddr;
	reg [7:0] databus;
	

	brg_spart DUT(.clk(clk),.rst(rst),.ioaddr(ioaddr),.databus(databus),
		.brg_en(brg_en),.brg_full(brg_full));


	initial begin	
		clk = 1'b1;
		forever #5 clk = ~clk;
	end


	initial begin	
		rst = 1'b1;
		ioaddr = 2'b00;
		databus = 8'h00;
	
		#10 rst = 1'b0;
		
		#50 databus = 8'h00; 
		#1 ioaddr = 2'b11;//load hi

		
		#10 databus = 8'h0F;
		 ioaddr = 2'b10; //load lo


		#10000 $stop;
	end
endmodule
