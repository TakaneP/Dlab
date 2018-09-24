`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/08/25 14:29:54
// Design Name: 
// Module Name: lab10
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A circuit that show the animation of a moon moving across a city
//              night view on a screen through the VGA interface of Arty I/O card.
// 
// Dependencies: vga_sync, clk_divider, sram
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab10(
    input  clk,
    input  reset_n,
    input  [3:0] usr_btn,
    output [3:0] usr_led,

    // VGA specific I/O ports
    output VGA_HSYNC,
    output VGA_VSYNC,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );

// Declare system variables
reg  [33:0] moon_clock;
reg [33:0] firework_clk = 34'b0;

wire [2:0] firework_page;
wire [9:0]  pos;
wire        moon_region;
wire firework_region;
wire firework_region2;
// declare SRAM control signals
wire [16:0] sram_addr;
wire [16:0] sram_addr2;
wire [16:0] sram_addr3;

wire [11:0] data_in;
wire [11:0] data_out;
wire [11:0] data_out2;
wire [11:0] data_out3;
wire        sram_we, sram_en;

assign usr_led = firework_page;
// General VGA control signals
wire vga_clk;       // 50MHz clock for VGA control
wire video_on;      // when video_on is 0, the VGA controller is sending
                    // synchronization signals to the display device.
  
wire pixel_tick;    // when pixel tick is 1, we must update the RGB value
                    // based for the new coordinate (pixel_x, pixel_y)
  
wire [9:0] pixel_x; // x coordinate of the next pixel (between 0 ~ 639) 
wire [9:0] pixel_y; // y coordinate of the next pixel (between 0 ~ 479)

reg [11:0] rgb_pre;

reg  [11:0] rgb_reg;  // RGB value for the current pixel
reg  [11:0] rgb_next; // RGB value for the next pixel
  
// Application-specific VGA signals
reg  [16:0] pixel_addr;
reg [16:0] pixel_addr2 = 17'b0;
reg [16:0] pixel_addr3 = 17'd0;

// Declare the video buffer size
localparam VBUF_W = 320; // video buffer width
localparam VBUF_H = 240; // video buffer height
  
// Instiantiate a VGA sync signal generator
vga_sync vs0(
  .clk(vga_clk), .reset(~reset_n), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
  .visible(video_on), .p_tick(pixel_tick),
  .pixel_x(pixel_x), .pixel_y(pixel_y)
);

clk_divider#(2) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(vga_clk)
);

// ------------------------------------------------------------------------
// The following code describes an initialized SRAM memory block that
// stores an 320x240 12-bit city image, plus a 64x40 moon image.
sram #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(VBUF_W*VBUF_H))
  ram0 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out));

sram1 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(64*40))
  ram1 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr2), .data_i(data_in), .data_o(data_out2));

sram2 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(62*62*5))
  ram2 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr3), .data_i(data_in), .data_o(data_out3));

assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                             // if you set 'we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_en = 1;          // Here, we always enable the SRAM block.
assign sram_addr = pixel_addr;
assign sram_addr2 = pixel_addr2;
assign sram_addr3 = pixel_addr3;
assign data_in = 12'h000; // SRAM is read-only so we tie inputs to zeros.
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// VGA color pixel generator
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;

// ------------------------------------------------------------------------
// An animation clock for the motion of the moon, upper bits of the
// moon clock is the x position of the moon in the VGA screen
assign pos = moon_clock[33:24];

always @(posedge clk) begin
  if (~reset_n || moon_clock[33:25] > VBUF_W + 64)
    moon_clock <= 0;
  else
    moon_clock <= moon_clock + 1;
end
// End of the animation clock code.
// ------------------------------------------------------------------------
assign firework_page = firework_clk[26:24];

always @(posedge clk) begin
  if(~reset_n || firework_clk[33:25] > VBUF_W + 65)
    firework_clk <= 0;
 // else if(pixel_x == 799 && pixel_y == 524 && video_on == 0)
    //firework_clk <= firework_clk + 1;
  else firework_clk <= firework_clk + 1;
end

/*always @(posedge clk) begin
    if(~reset_n) firework_page <= 0;
    else if(firework_page == 4) firework_page <= 0;
    else if(~firework_clk == ) firework_page <= firework_page + 1;
    else firework_page <= firework_page;
end*/
// ------------------------------------------------------------------------
// Video frame buffer address generation unit (AGU) with scaling control
// Note that the width x height of the moon image is 64x40, when scaled
// up to the screen, it becomes 128x80
assign moon_region = pixel_y >= 0 && pixel_y < 80 &&
                     (pixel_x + 127) >= pos && pixel_x < pos + 1 ;

assign firework_region = pixel_y >= 80 && pixel_y < 204 &&
                        pixel_x >= 160 && pixel_x < 284;

assign firework_region2 =  pixel_y >= 111 && pixel_y < 173 &&
                        pixel_x >= 450 && pixel_x < 512;                        
always @(posedge clk) begin
    if (~reset_n)
        pixel_addr <= 0;
    else
        // Scale up a 320x240 image for the 640x480 display.
        // (pixel_x, pixel_y) ranges from (0,0) to (639, 379)
        pixel_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
end
always @ (posedge clk) begin
  if (~reset_n)
    pixel_addr2 <= 0;
  else if (moon_region)
    pixel_addr2 <= ((pixel_y&10'h2FE)<<5) + ((pixel_x-pos+127)>>1);
end

always @(posedge clk) begin
    if(~reset_n) pixel_addr3 <= 0;
    else if(firework_region) pixel_addr3 <= (firework_page * 3844 + 1) + ((pixel_y-80) >> 1) * 62 + ((pixel_x - 160) >> 1);
    else if(firework_region2) pixel_addr3 <= (firework_page * 3844 + 1) + ((pixel_y-111)) * 62 + ((pixel_x - 450));
end
// End of the AGU code.
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
// Send the video data in the sram to the VGA controller
always @(posedge clk) begin
  if (pixel_tick) rgb_reg <= rgb_next;
end

always @(*) begin
  if (~video_on)
    rgb_next = 12'h000; // Synchronization period, must set RGB values to zero.
  else if(moon_region) begin
    if(data_out2 == 12'h0f0) rgb_next = data_out;
    else rgb_next = data_out2;
  end
  else if(firework_region) begin
    if(data_out3 == 12'h000) rgb_next = data_out;
    else rgb_next = data_out3;
  end
  else if(firework_region2) begin
    if(data_out3 == 12'h000) rgb_next = data_out;
    else rgb_next = data_out3;
  end
  else begin
    rgb_next = data_out; // RGB value at (pixel_x, pixel_y)
  end
end
// End of the video data display code.
// ------------------------------------------------------------------------

endmodule
