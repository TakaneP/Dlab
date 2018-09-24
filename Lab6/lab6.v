`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/05/08 15:29:41
// Design Name: 
// Module Name: lab6
// Project Name: 
// Target Devices: 
// Tool Versions:
// Description: The sample top module of lab 6: sd card reader. The behavior of
//              this module is as follows
//              1. When the SD card is initialized, display a message on the LCD.
//                 If the initialization fails, an error message will be shown.
//              2. The user can then press usr_btn[2] to trigger the sd card
//                 controller to read the super block of the sd card (located at
//                 block # 8192) into the SRAM memory.
//              3. During SD card reading time, the four LED lights will be turned on.
//                 They will be turned off when the reading is done.
//              4. The LCD will then displayer the sector just been read, and the
//                 first byte of the sector.
//              5. Everytime you press usr_btn[2], the next byte will be displayed.
// 
// Dependencies: clk_divider, LCD_module, debounce, sd_card
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab6(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // SD card specific I/O ports
  output spi_ss,
  output spi_sck,
  output spi_mosi,
  input  spi_miso,

  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

localparam [2:0] S_MAIN_INIT = 3'b000, S_MAIN_IDLE = 3'b001,
                 S_MAIN_WAIT = 3'b010, S_MAIN_READ = 3'b011,
                 S_MAIN_DONE = 3'b100, S_MAIN_FIND = 3'b101,
                 S_MAIN_END = 3'b110, S_MAIN_ANS = 3'b111;

// Declare system variables
wire btn_level, btn_pressed;
reg  prev_btn_level;
reg  [5:0] send_counter;
reg  [2:0] P, P_next;
reg  [9:0] sd_counter;
reg  [7:0] data_byte;
reg [7:0] out1;
reg [7:0] out2;
reg  [31:0] blk_addr;
reg blkbegin = 0;
reg [63:0] shift_reg;
reg [0:6] the_counter;
reg [3:0] ans_counter;
reg [3:0] ans1;
reg [3:0] ans2; 
reg  [127:0] row_A = "SD card cannot  ";
reg  [127:0] row_B = "be initialized! ";
reg  done_flag; // Signals the completion of reading one SD sector.
reg ansdone_flag = 0;
// Declare SD card interface signals
wire clk_sel;
wire clk_500k;
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finished;
wire [7:0] sd_dout;
wire sd_valid;

// Declare the control/data signals of an SRAM memory block
wire [7:0] data_in;
wire [7:0] data_out;
wire [8:0] sram_addr;
wire       sram_we, sram_en;

assign clk_sel = (init_finished)? clk : clk_500k; // clock for the SD controller
assign usr_led = P;

clk_divider#(200) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(clk_500k)
);

debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[2]),
  .btn_output(btn_level)
);

LCD_module lcd0( 
  .clk(clk),
  .reset(~reset_n),
  .row_A(row_A),
  .row_B(row_B),
  .LCD_E(LCD_E),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_D(LCD_D)
);

sd_card sd_card0(
  .cs(spi_ss),
  .sclk(spi_sck),
  .mosi(spi_mosi),
  .miso(spi_miso),

  .clk(clk_sel),
  .rst(~reset_n),
  .rd_req(rd_req),
  .block_addr(rd_addr),
  .init_finished(init_finished),
  .dout(sd_dout),
  .sd_valid(sd_valid)
);

sram ram0(
  .clk(clk),
  .we(sram_we),
  .en(sram_en),
  .addr(sram_addr),
  .data_i(data_in),
  .data_o(data_out)
);

//
// Enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 0;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

// ------------------------------------------------------------------------
// The following code sets the control signals of an SRAM memory block
// that is connected to the data output port of the SD controller.
// Once the read request is made to the SD controller, 512 bytes of data
// will be sequentially read into the SRAM memory block, one byte per
// clock cycle (as long as the sd_valid signal is high).
assign sram_we = sd_valid;          // Write data into SRAM when sd_valid is high.
assign sram_en = 1;                 // Always enable the SRAM block.
assign data_in = sd_dout;           // Input data always comes from the SD controller.
assign sram_addr = sd_counter[8:0]; // Set the driver of the SRAM address signal.
// End of the SRAM memory block
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the SD card reader that reads the super block (512 bytes)
always @(posedge clk) begin
  if (~reset_n) begin
    P <= S_MAIN_INIT;
    done_flag <= 0;
  end
  else begin
    P <= P_next;
    if (P == S_MAIN_DONE && (shift_reg[23:16] == 8'h45) && (shift_reg[15:8] == 8'h4E) && (shift_reg[7:0] == 8'h44))
      done_flag <= 1;
    else if (P == S_MAIN_FIND && P_next == S_MAIN_IDLE)
      done_flag <= 0;
    else
      done_flag <= done_flag;
  end
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // wait for SD card initialization
      if (init_finished == 1) P_next = S_MAIN_IDLE;
      else P_next = S_MAIN_INIT;
    S_MAIN_IDLE: // wait for button click
      if (btn_pressed == 1) P_next = S_MAIN_WAIT;
      else P_next = S_MAIN_IDLE;
    S_MAIN_WAIT: // issue a rd_req to the SD controller until it's ready
      P_next = S_MAIN_READ;
    S_MAIN_READ: // wait for the input data to enter the SRAM buffer
      if (sd_counter == 512) P_next = S_MAIN_DONE;
      else P_next = S_MAIN_READ;
    S_MAIN_DONE: // read byte 0 of the superblock from sram[]
      P_next = S_MAIN_FIND;
    S_MAIN_FIND:
      if(done_flag) P_next = S_MAIN_END;
      else if(!blkbegin && sd_counter == 9) P_next = S_MAIN_WAIT;
      else if (sd_counter < 512) P_next = S_MAIN_DONE;
      else P_next = S_MAIN_WAIT;
    S_MAIN_END:
      if(ansdone_flag) P_next = S_MAIN_ANS;
      else P_next = S_MAIN_END;
   S_MAIN_ANS:
      P_next = S_MAIN_ANS;
    default:
      P_next = S_MAIN_IDLE;
  endcase
end

always @(posedge clk) begin
    if(~reset_n) blkbegin = 0;
    else if(P == S_MAIN_DONE && shift_reg[63:56] == "D" && shift_reg[55:48] == "L" && shift_reg[47:40] == "A" && shift_reg[39:32] == "B" 
    && shift_reg[31:24] == "_" && shift_reg[23:16] == "T" && shift_reg[15:8] == "A" && shift_reg[7:0] == "G")
        blkbegin <= 1;
    else blkbegin <= blkbegin;
end

//Use the register to judge the
always @(posedge clk) begin
    if(~reset_n) shift_reg <= 64'b0;
    else if(sram_en && P == S_MAIN_DONE) shift_reg <= {shift_reg[55:48],shift_reg[47:40],shift_reg[39:32],shift_reg[31:24],shift_reg[23:16],shift_reg[15:8],shift_reg[7:0],data_out};
    else shift_reg <= shift_reg;
end
//judge the
always @(posedge clk) begin
    if(~reset_n) the_counter <= 7'b0;
    else if(!blkbegin) the_counter <= 7'b0;
    else if(P == S_MAIN_DONE && (shift_reg[39:32] == 8'h20 || shift_reg[39:32] == 8'h0A) && (shift_reg[31:24] == 8'h54 || shift_reg[31:24] == 8'h74) 
        && (shift_reg[23:16] == 8'h48 || shift_reg[23:16] == 8'h68) && (shift_reg[15:8] == 8'h45 || shift_reg[15:8] == 8'h65) && (shift_reg[7:0] == 8'h0A || shift_reg[7:0] == 8'h20))
        the_counter <= the_counter + 1;
    else the_counter <= the_counter;
end

// FSM output logic: controls the 'rd_req' and 'rd_addr' signals.
always @(*) begin
  rd_req = (P == S_MAIN_WAIT);
  rd_addr = blk_addr;
end

always @(posedge clk) begin
  if (~reset_n) blk_addr <= 32'h2000;
  else if(P == S_MAIN_FIND && P_next == S_MAIN_WAIT) blk_addr <= blk_addr + 32'h1;
  else blk_addr <= blk_addr; // In lab 6, change this line to scan all blocks
end

// FSM output logic: controls the 'sd_counter' signal.
// SD card read address incrementer
always @(posedge clk) begin
  if (~reset_n || (P == S_MAIN_READ && P_next == S_MAIN_DONE) || (P == S_MAIN_FIND && P_next == S_MAIN_WAIT))
    sd_counter <= 0;
  else if ((P == S_MAIN_READ && sd_valid) ||
           (P == S_MAIN_DONE && P_next == S_MAIN_FIND))
    sd_counter <= sd_counter + 1;
end

// FSM ouput logic: Retrieves the content of sram[] for display
always @(posedge clk) begin
  if (~reset_n) data_byte <= 8'b0;
  else if (sram_en && P == S_MAIN_DONE) data_byte <= data_out;
end
// End of the FSM of the SD card reader

always @(posedge clk) begin
    if(P == S_MAIN_END) begin
        if(ans1 >= 5) ans1 = ans1 + 3;
        else ans1 = ans1;
        if(ans2 >= 5) ans2 = ans2 + 3;
        else ans2 = ans2;
        ans1 = ans1 << 1;
        ans1[0] = ans2[3];
        ans2 = ans2 << 1;
        ans2[0] = the_counter[ans_counter];
        ans_counter = ans_counter + 1;
        ansdone_flag = 0;
        if(ans_counter == 4'd7)  ansdone_flag = 1;
        else ansdone_flag = ansdone_flag;
    end
    else ansdone_flag = ansdone_flag;
end
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// LCD Display function.
always @(posedge clk) begin
  if (~reset_n) begin
    row_A = "SD card cannot  ";
    row_B = "be initialized! ";
  end else if (ansdone_flag) begin
    out1 = ans1;
    out2 = ans2;
    row_A <= {"Found ",
              "0" + out1,
              "0" + out2,
              " matches"};
    row_B <= "in the text file";
  end
  else if (P == S_MAIN_IDLE) begin
    row_A <= "Hit BTN2 to read";
    row_B <= "the SD card ... ";
  end
end
// End of the LCD display function
// ------------------------------------------------------------------------

endmodule
