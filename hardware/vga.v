//Module by Team Binary Evolution
//Spring 2011

module vga(rst,clk_25mhz,blank,comp_sync,hsync,vsync,pixel_r,pixel_g,pixel_b,
	read_bytes, input_bytes,fb_select,mem_addr);

	//input clk_100mhz;
	input rst;
	input [79:0] input_bytes; //the 6 bytes which are read from memory
	input clk_25mhz;
	input fb_select; //programmer decids which frame buffer to read from
	output blank;
	output comp_sync;
	output hsync;
	output vsync;
	output [7:0] pixel_r;
	output [7:0] pixel_g;
	output [7:0] pixel_b;
	output read_bytes; //asserted to signal to memory to send 10 bytes to the vga controller.
	output [39:0] mem_addr;

	wire [9:0] pixel_x;
	wire [9:0] pixel_y;
	
	vga_logic vgalog1 (.clk(clk_25mhz), .rst(rst), .blank(blank), .comp_sync(comp_sync),
						.hsync(hsync), .vsync(vsync), .pixel_x(pixel_x), .pixel_y(pixel_y));
	
	draw_logic drawlog1(.clk(clk_25mhz), .rst(rst), .pixel_r(pixel_r), .pixel_g(pixel_g), .pixel_b(pixel_b),.read_bytes(read_bytes), .input_bytes(input_bytes), .pixel_x(pixel_x), .pixel_y(pixel_y), .mem_addr(mem_addr),.fb_select(fb_select));	

endmodule


module vga_logic(clk, rst, blank, comp_sync, hsync, vsync, pixel_x, pixel_y);
	input clk;
	input rst;
	output blank;
	output comp_sync;
	output hsync;
	output vsync;
	output [9:0] pixel_x;
	output [9:0] pixel_y;

	reg [9:0] pixel_x;
	reg [9:0] pixel_y;

	// pixel_count logic
	wire [9:0] next_pixel_x;
	wire [9:0] next_pixel_y;
	assign next_pixel_x = (pixel_x == 10'd799)? 0 : pixel_x+1;
	assign next_pixel_y = (pixel_x == 10'd799)?  ((pixel_y == 10'd520) ? 0 : pixel_y+1) : pixel_y;
	 
	 always@(posedge clk, posedge rst)
	   if(rst) begin
		  pixel_x <= 10'h0;
		  pixel_y <= 10'h0;
		end else begin
		  pixel_x <= next_pixel_x;
		  pixel_y <= next_pixel_y;
		end
		
		assign hsync = (pixel_x < 10'd656) || (pixel_x > 10'd751); // 96 cycle pulse
		assign vsync = (pixel_y < 10'd490) || (pixel_y > 10'd491); // 2 cycle pulse
		assign blank = ~((pixel_x > 10'd639) | (pixel_y > 10'd479));
		assign comp_sync = 1'b0; // don't know, dont use
		
endmodule

module draw_logic(clk,rst,input_bytes,read_bytes,pixel_r, pixel_g, pixel_b,pixel_x,pixel_y,mem_addr,fb_select);
	input clk;
	input rst;
	input [79:0] input_bytes;
	input [9:0] pixel_x,pixel_y;
	input fb_select;

	output [7:0] pixel_r;
	output [7:0] pixel_g;
	output [7:0] pixel_b;
	output reg [39:0] mem_addr;
	output reg read_bytes; 

	wire [7:0] current_pixel_byte;
	reg [79:0] shift_reg;
	reg [79:0] next_shift_reg; //holds the input bytes and shifts them out as needed
	reg [3:0] shift_count;
	reg [3:0] next_shift_count; //count to 10
	wire pixel_change; //asserted when displaying next pixel 
	reg prev_x1,prev_y1;	

	always@(posedge clk) begin
	if (rst) begin
		shift_reg <= 48'd0;
		shift_count <= 4'h0;
		prev_x1 <= 1'b0;
		prev_y1 <= 1'b0;
		end
	else begin
		shift_reg <= next_shift_reg;
		shift_count <= next_shift_count;
		prev_x1 <= pixel_x[1];
		prev_y1 <= pixel_y[1];
		end
	end

always @(*) begin
	if (pixel_x==10'd798) begin
		if (pixel_y == 10'd520) begin
			next_shift_count = 4'dx;
			next_shift_reg = 80'hx;
			read_bytes = 1'b1;
			mem_addr = {23'd0,fb_select,16'h0};
		end
		else begin //end of a horiz line, but not at the end of the frame
			next_shift_count = 4'dx;
			next_shift_reg = 80'hx;
			read_bytes = 1'b1;
			mem_addr = {23'd0,fb_select,(pixel_y[7:0] + 8'd1),8'h0}; //TODO: add in framebuffer bit
		end
	end else if (pixel_x==10'd799 ) begin
		if (pixel_y==10'd520) begin //end of horiz line and end of frame
			next_shift_reg = input_bytes;
			next_shift_count = 4'd0;
			read_bytes = 1'b0;
			mem_addr = 40'hx;	
		end
		else begin //end of horiz line but not end of frame
			next_shift_reg = input_bytes;
			next_shift_count = 4'd0;
			read_bytes = 1'b0;
			mem_addr = 40'hx;	
		end
	end else if ((pixel_x < 10'd512)&&(pixel_y < 10'd256)) begin
		if (pixel_x[0]) begin
			read_bytes = 1'b0;
			mem_addr = 40'hx;					
			if (shift_count == 4'd9) begin
				next_shift_count = 4'd0;
				next_shift_reg = input_bytes;
			end else begin
				next_shift_count = shift_count + 4'd1;
				next_shift_reg = {8'h00,shift_reg[79:8]};
			end
		end else begin
			next_shift_count = shift_count;
			next_shift_reg = shift_reg;
			
			if (shift_count == 4'd9) begin
				read_bytes = 1'b1;
				if(pixel_x==10'd510) begin
					mem_addr = {23'd0,fb_select,pixel_y[7:0] + 8'd1,8'd0};
				end else begin
					mem_addr = {23'd0,fb_select,pixel_y[7:0],pixel_x[8:1]};
				end
			end else begin
				read_bytes = 1'b0;
				mem_addr = 40'hx;		
			end
		end
	end else begin
		next_shift_count = shift_count;
		next_shift_reg = shift_reg;
		read_bytes = 1'b0;
		mem_addr = 40'hx;
	end
end

	assign pixel_change = prev_x1^pixel_x[1]; //asserted 1 cycle during pixel change

	assign current_pixel_byte = (pixel_x > 10'd511 || pixel_y > 10'd255) ? 8'h00 : shift_reg[7:0];

	assign pixel_r = current_pixel_byte;	
	assign pixel_g = current_pixel_byte;	
	assign pixel_b = current_pixel_byte;	

	//gray scale for now
/*	always @(*) begin 
		next_pixel_r = current_pixel_byte;
		next_pixel_g = current_pixel_byte;
		next_pixel_b = current_pixel_byte; 
	end
*/
	 
endmodule
