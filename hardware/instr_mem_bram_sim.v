module instr_mem_bram_sim (clka,addra,douta,clkb,addrb,doutb);
input clka, clkb;
input [9:0] addra, addrb;
output [31:0] douta, doutb;

reg [31:0] memory [255:0];

initial begin
    $readmemh("I:/Desktop/ece554/projectsvnwin/software/assembled_progs/exbyte/exbyte.bin",memory);
end


reg [9:0] latched_addra, latched_addrb;

//Simulates how BRAMs work
always @(posedge clka) begin
   latched_addra <= addra;
   latched_addrb <= addrb;
end 

assign douta = memory[latched_addra[7:0]]; 
assign doutb = memory[latched_addrb[7:0]];


endmodule

