module vga_top(CLK_100MHZ,
//clk_25mhz,clk_75mhz_internal, 
rst, blank,comp_sync,hsync,vsync,pixel_r,pixel_g,pixel_b, CLK_25MHZ,CLK_75MHZ);
	input CLK_100MHZ,rst;
	//input clk_25mhz,clk_75mhz_internal;
	output blank;
	output comp_sync;
	output hsync;
	output vsync;
	output CLK_25MHZ;
	output CLK_75MHZ;
	output [7:0] pixel_r;
	output [7:0] pixel_g;
	output [7:0] pixel_b;
	
	
	
	wire clk_25mhz, clk_25mhz_c;
	wire clk_75mhz_internal;
	assign CLK_25MHZ = clk_25mhz;
	assign CLK_75MHZ = clk_75mhz_internal;
	
	clk_25 clk_25x2(
    .CLKIN_IN(clk_25mhz_c), 
   .RST_IN(rst|~locked_dcm_first), 
    //.CLKFX_OUT(clk_25mhz), 
	 .CLKFX_OUT(clk_75_mhz_internal),
    .CLK0_OUT(clk_25mhz), 
    .LOCKED_OUT(locked_dcm)
    );
	 
	 clk_prestage clk_25(
    .CLKIN_IN(CLK_100MHZ), 
    .RST_IN(rst), 
    .CLKFX_OUT(clk_25mhz_c), 
    //.CLKIN_IBUFG_OUT(clk_100mhz_internal1), 
    .LOCKED_OUT(locked_dcm_first)
    );
	 
	
	
    wire vga_request;   
    reg [47:0] data;
    wire [39:0] vga_addr;
    
    reg [16:0] addr0;
    reg [16:0] last_addr0;
    
    always @(posedge clk_75mhz_internal) begin
       last_addr0 <= addr0;
    end
    
    wire [7:0] byte0, byte1;
    
    reg [1:0] count;
    
    reg slow_registered_rst;
    always @(posedge clk_25mhz) begin
       slow_registered_rst <= rst | ~locked_dcm; 
    end
    
    always @ (posedge clk_75mhz_internal) begin
       if (rst | slow_registered_rst | ~locked_dcm) begin
          count <= 2'd0;
       end else if (count == 2'd2) begin
          count <= 2'd0; 
       end else begin
          count <= count + 2'd1; 
       end
    end
    
    always @(*) begin
       case(count)
           2'd2: begin addr0 = vga_addr[16:0]; end
           default: begin addr0 = last_addr0 + 17'd2; end
       endcase
    end
    
    always @(posedge clk_75mhz_internal) begin
       case(count)
          2'd0: begin data <= {data[47:16],byte1,byte0}; end 
          2'd1: begin data <= {data[47:32],byte1,byte0,data[15:0]}; end
          2'd2: begin data <= {byte1,byte0,data[31:0]}; end
          default: begin data <= data; end
       endcase
        
    end
    reg last_request;
	 always @(posedge clk_25mhz) begin
		last_request <= vga_request;
	 end
    dmem_bram_simulator dmem(.addra(addr0),.dina(),
       .wea(1'b0),.clka(clk_75mhz_internal),.addrb(addr0 + 17'd1),.dinb(),
       .web(1'b0),.clkb(clk_75mhz_internal),.douta(byte0),.doutb(byte1));
       
    vga vga0(.rst(rst|~locked_dcm),.clk_25mhz(clk_25mhz),
    .blank(blank),.comp_sync(comp_sync),.hsync(hsync),.vsync(vsync),.pixel_r(pixel_r),.pixel_g(pixel_g),.pixel_b(pixel_b),
	.read_bytes(vga_request), .input_bytes((last_request) ? {byte1,byte0,data[31:0]} : 80'h0),.fb_select(1'b0),
	.mem_addr(vga_addr));
    
endmodule
