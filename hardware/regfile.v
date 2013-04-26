/* Module:	Register File	

Description: Contains R0-R30. Does not contain register 31. I don't know what happens when you try to read/write it.	

Hierarchy:		


Team Binary Evolution
Ben Fuhrmann, Cody Hanson, Eric Harris, Ross Nordstrom, Eric Weisman

Module designed by: Eric H.
Edited by:		
Module interface by:	

Date:			

*/

module regFile(clk,rst,addrRd0,addrRd1,addrRd2,
   addrRd3,addrWr0,addrWr1,dataRd0,dataRd1,
      dataRd2,dataRd3,dataInWr0,dataInWr1,writeEn0, writeEn1);

input clk,rst;
input [4:0] addrRd0,addrRd1,addrRd2,addrRd3;
input [4:0] addrWr0, addrWr1;
input writeEn0, writeEn1;
input [39:0] dataInWr0, dataInWr1;
output [39:0] dataRd0, dataRd1, dataRd2, dataRd3;

//PC sits outside because it needs to be written every cycle.
//But this module contains an extra flip flop


reg [39:0] registers[31:0]; //Array of 40 bit words
wire [39:0] nextregisters[31:0];

 
  assign dataRd0 = nextregisters[addrRd0];
  assign dataRd1 = nextregisters[addrRd1];
  assign dataRd2 = nextregisters[addrRd2];
  assign dataRd3 = nextregisters[addrRd3];

  assign nextregisters[0] = ((addrWr1==5'd0)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd0)&&writeEn0) ? dataInWr0 : registers[0];
  assign nextregisters[1] = ((addrWr1==5'd1)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd1)&&writeEn0) ? dataInWr0 : registers[1];
  assign nextregisters[2] = ((addrWr1==5'd2)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd2)&&writeEn0) ? dataInWr0 : registers[2];
  assign nextregisters[3] = ((addrWr1==5'd3)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd3)&&writeEn0) ? dataInWr0 : registers[3];
  assign nextregisters[4] = ((addrWr1==5'd4)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd4)&&writeEn0) ? dataInWr0 : registers[4];
  assign nextregisters[5] = ((addrWr1==5'd5)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd5)&&writeEn0) ? dataInWr0 : registers[5];
  assign nextregisters[6] = ((addrWr1==5'd6)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd6)&&writeEn0) ? dataInWr0 : registers[6];
  assign nextregisters[7] = ((addrWr1==5'd7)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd7)&&writeEn0) ? dataInWr0 : registers[7];
  assign nextregisters[8] = ((addrWr1==5'd8)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd8)&&writeEn0) ? dataInWr0 : registers[8];
  assign nextregisters[9] = ((addrWr1==5'd9)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd9)&&writeEn0) ? dataInWr0 : registers[9];
  assign nextregisters[10] = ((addrWr1==5'd10)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd10)&&writeEn0) ? dataInWr0 : registers[10];
  assign nextregisters[11] = ((addrWr1==5'd11)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd11)&&writeEn0) ? dataInWr0 : registers[11];
  assign nextregisters[12] = ((addrWr1==5'd12)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd12)&&writeEn0) ? dataInWr0 : registers[12];
  assign nextregisters[13] = ((addrWr1==5'd13)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd13)&&writeEn0) ? dataInWr0 : registers[13];
  assign nextregisters[14] = ((addrWr1==5'd14)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd14)&&writeEn0) ? dataInWr0 : registers[14];
  assign nextregisters[15] = ((addrWr1==5'd15)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd15)&&writeEn0) ? dataInWr0 : registers[15];
  assign nextregisters[16] = ((addrWr1==5'd16)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd16)&&writeEn0) ? dataInWr0 : registers[16];
  assign nextregisters[17] = ((addrWr1==5'd17)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd17)&&writeEn0) ? dataInWr0 : registers[17];
  assign nextregisters[18] = ((addrWr1==5'd18)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd18)&&writeEn0) ? dataInWr0 : registers[18];
  assign nextregisters[19] = ((addrWr1==5'd19)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd19)&&writeEn0) ? dataInWr0 : registers[19];
  assign nextregisters[20] = ((addrWr1==5'd20)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd20)&&writeEn0) ? dataInWr0 : registers[20];
  assign nextregisters[21] = ((addrWr1==5'd21)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd21)&&writeEn0) ? dataInWr0 : registers[21];
  assign nextregisters[22] = ((addrWr1==5'd22)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd22)&&writeEn0) ? dataInWr0 : registers[22];
  assign nextregisters[23] = ((addrWr1==5'd23)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd23)&&writeEn0) ? dataInWr0 : registers[23];
  assign nextregisters[24] = ((addrWr1==5'd24)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd24)&&writeEn0) ? dataInWr0 : registers[24];
  assign nextregisters[25] = ((addrWr1==5'd25)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd25)&&writeEn0) ? dataInWr0 : registers[25];
  assign nextregisters[26] = ((addrWr1==5'd26)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd26)&&writeEn0) ? dataInWr0 : registers[26];
  assign nextregisters[27] = ((addrWr1==5'd27)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd27)&&writeEn0) ? dataInWr0 : registers[27];
  assign nextregisters[28] = ((addrWr1==5'd28)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd28)&&writeEn0) ? dataInWr0 : registers[28];
  assign nextregisters[29] = ((addrWr1==5'd29)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd29)&&writeEn0) ? dataInWr0 : registers[29];
  assign nextregisters[30] = ((addrWr1==5'd30)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd30)&&writeEn0) ? dataInWr0 : registers[30];
  assign nextregisters[31] = ((addrWr1==5'd31)&&writeEn1) ? dataInWr1 : ((addrWr0==5'd31)&&writeEn0) ? dataInWr0 : registers[31];
  

always @(posedge clk) begin
   registers[0] <= nextregisters[0];
   registers[1] <= nextregisters[1];
   registers[2] <= nextregisters[2];
   registers[3] <= nextregisters[3];
   registers[4] <= nextregisters[4];
   registers[5] <= nextregisters[5];
   registers[6] <= nextregisters[6];
   registers[7] <= nextregisters[7];
   registers[8] <= nextregisters[8];
   registers[9] <= nextregisters[9];
   registers[10] <= nextregisters[10];
   registers[11] <= nextregisters[11];
   registers[12] <= nextregisters[12];
   registers[13] <= nextregisters[13];
   registers[14] <= nextregisters[14];
   registers[15] <= nextregisters[15];
   registers[16] <= nextregisters[16];
   registers[17] <= nextregisters[17];
   registers[18] <= nextregisters[18];
   registers[19] <= nextregisters[19];
   registers[20] <= nextregisters[20];
   registers[21] <= nextregisters[21];
   registers[22] <= nextregisters[22];
   registers[23] <= nextregisters[23];
   registers[24] <= nextregisters[24];
   registers[25] <= nextregisters[25];
   registers[26] <= nextregisters[26];
   registers[27] <= nextregisters[27];
   registers[28] <= nextregisters[28];
   registers[29] <= nextregisters[29];
   registers[30] <= nextregisters[30];
   registers[31] <= nextregisters[31];
 end
endmodule