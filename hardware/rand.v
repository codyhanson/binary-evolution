//Module by Team Binary Evolution
//Spring 2011

//IMPLEMENTS LFSR


module rand(rst,clk,randNum);


	input rst;
	input clk;
   wire xnor2,xnor1,xnor0;
	output [7:0] randNum;

	dff d7 (.rst(rst),.clk(clk),.in(xnor2),.out(randNum[7]));
	dff d6 (.rst(rst),.clk(clk),.in(randNum[7]),.out(randNum[6]));
	dff d5 (.rst(rst),.clk(clk),.in(randNum[6]),.out(randNum[5]));
	dff d4 (.rst(rst),.clk(clk),.in(randNum[5]),.out(randNum[4]));
	dff d3 (.rst(rst),.clk(clk),.in(randNum[4]),.out(randNum[3]));	
	dff d2 (.rst(rst),.clk(clk),.in(randNum[3]),.out(randNum[2]));	
	dff d1 (.rst(rst),.clk(clk),.in(randNum[2]),.out(randNum[1]));
	dff d0 (.rst(rst),.clk(clk),.in(randNum[1]),.out(randNum[0]));

	assign xnor0 = ~(randNum[0] ^ randNum[2]);
	assign xnor1 = ~(xnor0 ^ randNum[3]);
	assign xnor2 = ~(xnor1 ^ randNum[4]);




endmodule

module dff(rst,clk,in,out);
	input rst;
	input clk;
	input in;
	output reg out;

	always @ (posedge clk)begin
		
		if(rst)	out <=0;
		else out <= in; 
	end
endmodule

