`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/12/06 20:44:08
// Design Name: 
// Module Name: lab9
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This is a sample circuit to show you how to initialize an SRAM
//              with a pre-defined data file. Hit BTN0/BTN1 let you browse
//              through the data.
// 
// Dependencies: LCD_module, debounce
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab9(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

localparam [3:0] S_MAIN_INIT = 4,S_MAIN_ADDR = 4'b0000, S_MAIN_READ = 4'b0001,
                 S_MAIN_SHOW = 4'b0010, S_MAIN_WAIT = 4'b0011,S_MAIN_INCR = 5,
                 S_MAIN_FOR1 = 6,S_MAIN_FOR2_PART1 = 7,S_MAIN_FOR2_PART2 = 8,
                 S_MAIN_JUDGE = 9,S_MAIN_FOR2_PART3 = 10,S_MAIN_FOR2_PART4 = 11,
                 S_MAIN_SHIFT = 12,S_MAIN_CMP = 13,S_MAIN_CMP2 = 14;

// declare system variables
reg [23:0] init_counter = 0;
wire btn_level, btn_pressed;
reg  [1:0]        prev_btn_level;
reg  [3:0]        P, P_next;
reg  [11:0]       sample_addr = 0;
reg  signed [23:0] max = 0;
reg signed [23:0] temp;
reg signed [23:0] temp1;
reg signed [23:0] temp2;
reg signed [23:0] sum;
reg [11:0] max_pos = 0;
wire [7:0]        abs_data;
reg sign = 0;
reg  [127:0] row_A = "Press BTN0 to do", row_B = "x-correlation...";

reg signed [7:0] f[0:1023];
reg signed [7:0] g[0:63];
reg signed [7:0] calf;
reg signed [7:0] calg;
reg [9:0] x_counter = 0;
reg [6:0] k_counter = 0;
reg [9:0] tempcount;
reg done = 0;
// declare SRAM control signals
wire [10:0] sram_addr;
wire [7:0]  data_in;
wire [7:0]  data_out;
wire        sram_we, sram_en;

assign usr_led = 4'h00;

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
  
debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[0]),
  .btn_output(btn_level)
);

//
// Enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);
//assign btn_pressed = (P == S_MAIN_WAIT);
// ------------------------------------------------------------------------
// The following code describes an initialized SRAM memory block that
// stores an 1024+64 8-bit signed data samples.
sram ram0(.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out));

assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                             // if you set 'we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_en = (P == S_MAIN_ADDR || P == S_MAIN_READ); // Enable the SRAM block.
assign sram_addr = sample_addr[11:0];
assign data_in = 8'b0; // SRAM is read-only so we tie inputs to zeros.
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the main controller
always @(posedge clk) begin
  if (~reset_n) begin
    P <= S_MAIN_INIT; // read samples at 000 first
  end
  else begin
    P <= P_next;
  end
end

always @(posedge clk) begin
  if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT:
        if (init_counter < 1000) P_next = S_MAIN_INIT;
        else P_next =S_MAIN_WAIT;
    S_MAIN_WAIT: // wait for a button click
        if (btn_pressed == 1) P_next = S_MAIN_ADDR;
        else P_next = S_MAIN_WAIT;
    S_MAIN_ADDR: // send an address to the SRAM 
      P_next = S_MAIN_READ;
    S_MAIN_READ: // fetch the sample from the SRAM
      P_next = S_MAIN_INCR;
    S_MAIN_INCR:
        if(sample_addr < 1088) P_next = S_MAIN_ADDR;
        else P_next = S_MAIN_FOR1;
    S_MAIN_FOR1:
        P_next = S_MAIN_FOR2_PART1;
    S_MAIN_FOR2_PART1:
        P_next = S_MAIN_CMP;
    S_MAIN_CMP:
        P_next = S_MAIN_FOR2_PART2;
    S_MAIN_FOR2_PART2:
        P_next = S_MAIN_SHIFT;
     S_MAIN_SHIFT:
       P_next = S_MAIN_FOR2_PART3;
    S_MAIN_FOR2_PART3:
        P_next = S_MAIN_CMP2;
    S_MAIN_CMP2:
        P_next = S_MAIN_FOR2_PART4;
    S_MAIN_FOR2_PART4:
        if(k_counter < 63) P_next = S_MAIN_FOR2_PART1;
        else P_next = S_MAIN_JUDGE;
    S_MAIN_JUDGE:
        if(x_counter > 959) P_next = S_MAIN_SHOW;
        else P_next = S_MAIN_FOR1;
    S_MAIN_SHOW:
      P_next = S_MAIN_SHOW;
    
  endcase
end

// FSM ouput logic: Fetch the data bus of sram[] for display
always @(posedge clk) begin
  if (~reset_n) f[0] <= 8'b0;
  else if (P == S_MAIN_READ  && sample_addr >= 0 && sample_addr < 1024) f[sample_addr] <= data_out;
  else if(P == S_MAIN_READ && sample_addr > 1023 && sample_addr < 1088) g[sample_addr-1024] <= data_out;
  else f[0] <= f[0];
end
// End of the main controller
// ------------------------------------------------------------------------

always @(posedge clk)begin
    if(P == S_MAIN_CMP)begin
          if(f[tempcount] < 0) calf <= ~(f[tempcount] - 1);
          else calf <= f[tempcount];
          if(g[k_counter] < 0) calg <= ~(g[k_counter] - 1);
          else calg <= g[k_counter]; 
          sign <= (f[tempcount][7] ^ g[k_counter][7])? 1:0; 
      end
end



always @(posedge clk) begin
    if(P == S_MAIN_FOR1) sum <= 0;
    else if(P == S_MAIN_FOR2_PART4) sum <= sum + temp;
end

always @(posedge clk) begin
    if(~reset_n) x_counter <= 0;
    else if(P == S_MAIN_JUDGE && P_next == S_MAIN_FOR1) x_counter <= x_counter + 1;
    else x_counter <= x_counter;
end

always @(posedge clk) begin
    if(~reset_n) k_counter <= 0;
    else if(P == S_MAIN_FOR2_PART4 && k_counter < 63) k_counter <= k_counter + 1;
    else if(P == S_MAIN_JUDGE) k_counter <= 0;
    else k_counter <= k_counter;
end
always @(posedge clk) begin
    if(P == S_MAIN_FOR2_PART1) tempcount <= k_counter + x_counter;
    else tempcount <= tempcount;
end



always @(posedge clk) begin
    if(P == S_MAIN_FOR2_PART2 && k_counter < 64) begin
        temp1 <= calf[3:0] * calg;
        temp2 <= calf[7:4] * calg;
    end
    else if(P == S_MAIN_SHIFT) begin
            temp2 <= {temp2[18:0],1'b0,1'b0,1'b0,1'b0};
    end
    else temp1 <= temp1;
end


always @(posedge clk) begin
    if(P == S_MAIN_FOR2_PART3) begin
        temp <= temp1 + temp2;
    end
    else if(P == S_MAIN_CMP2 && sign) temp <= ~temp + 1;
    else temp <= temp;
end



always @(posedge clk) begin
    if(P == S_MAIN_JUDGE && sum > max) begin
        max <= sum;
        max_pos <= x_counter;
    end
    else max <= max; 
end
// ------------------------------------------------------------------------
// The following code updates the 1602 LCD text messages.
always @(posedge clk) begin
  if (~reset_n) begin
    row_A <= "Max value ";
  end
  else if (P == S_MAIN_SHOW) begin
    row_A[127:48] <= "Max value ";   
    row_A[47:40] <= ((max[23:20] > 9)? "7" : "0") + max[23:20];
    row_A[39:32] <= ((max[19:16] > 9)? "7" : "0") + max[19:16];
    row_A[31:24] <= ((max[15:12] > 9)? "7" : "0") + max[15:12];
    row_A[23:16] <= ((max[11:08] > 9)? "7" : "0") + max[11:08];
    row_A[15:8] <= ((max[07:04] > 9)? "7" : "0") + max[07:04];
    row_A[7:0] <= ((max[03:00] > 9)? "7" : "0") + max[03:00];
  end
end


always @(posedge clk) begin
  if (~reset_n) begin
    row_B <= "Max location ";
  end
  else if (P == S_MAIN_SHOW) begin
    row_B[127:24] <= "Max location ";
    row_B[23:16]<=((max_pos[11:8] > 9)? "7" : "0") + max_pos[11:8];
    row_B[15:8] <= ((max_pos[7:4] > 9)? "7" : "0") + max_pos[7:4];
    row_B[7: 0] <= ((max_pos[3:0] > 9)? "7" : "0") + max_pos[3:0];
  end
end
// End of the 1602 LCD text-updating code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// The circuit block that processes the user's button event.
always @(posedge clk) begin
  if (~reset_n)
    sample_addr <= 12'h000;
  else if (P == S_MAIN_INCR)
    sample_addr <= sample_addr + 1;
  else
    sample_addr <= sample_addr;
end
// End of the user's button control.
// ------------------------------------------------------------------------

endmodule
