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

module lab7(
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
  output [3:0] LCD_D,
  
  //uart
  input  uart_rx,
  output uart_tx
);

localparam [3:0] S_MAIN_INIT = 4'b0000, S_MAIN_IDLE = 4'b0001,
                 S_MAIN_WAIT = 4'b0010, S_MAIN_READ = 4'b1111,
                 S_MAIN_DONE = 4'b0100, S_MAIN_FIND = 4'b0101,
                 S_MAIN_END = 4'b0110, S_MAIN_ANS = 4'b0111,
                 S_MAIN_PRINT = 4'b1000,S_MAIN_PROMPT = 4'b1001,
                 S_MAIN_TRANS = 4'b1010,S_MAIN_STOP = 4'b1011;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                  S_UART_SEND = 2, S_UART_INCR = 3;
// Declare system variables
wire btn_level, btn_pressed;
reg  prev_btn_level;
reg [5:0] send_counter = 6'b0;
reg [3:0] P, P_next;
reg [1:0] Q,Q_next;
reg [9:0] sd_counter;
reg  [31:0] blk_addr;
reg blkbegin = 0;
reg [63:0] shift_reg;
//matrix
reg [4:0] state_counter;
wire [3:0] input_num;
reg [0:16*8-1] A_mat = 128'b0;
reg [0:16*8-1] B_mat = 128'b0;
reg [17:0] data_temp;
reg [4:0] matrix_counter;
reg [6:0] row_counter;
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
wire  sram_we, sram_en;


//answer sram signal
wire [17:0] answer_in;
wire [17:0] answer_out;
wire [4:0] answer_addr;
wire answer_we;

// declare UART signals
wire print_enable;
wire print_done;
wire transmit;
wire received;
wire [7:0] rx_byte;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;
reg [7:0] data[48:0];
assign clk_sel = (init_finished)? clk : clk_500k; // clock for the SD controller
//assign usr_led = send_counter;

clk_divider#(200) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(clk_500k)
);

debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[1]),
  .btn_output(btn_level)
);

/*LCD_module lcd0( 
  .clk(clk),
  .reset(~reset_n),
  .row_A(row_A),
  .row_B(row_B),
  .LCD_E(LCD_E),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_D(LCD_D)
);*/

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

sram #(.DATA_WIDTH(18),.ADDR_WIDTH(5),.RAM_SIZE(16))
ram1(
    .clk(clk),
    .we(answer_we),
    .en(sram_en),
    .addr(answer_addr),
    .data_i(answer_in),
    .data_o(answer_out)
);

uart uart(
.clk(clk),
.rst(~reset_n),
.rx(uart_rx),
.tx(uart_tx),
.transmit(transmit),
.tx_byte(tx_byte),
.received(received),
.rx_byte(rx_byte),
.is_receiving(is_receiving),
.is_transmitting(is_transmitting),
.recv_error(recv_error)
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
  end
  else begin
    P <= P_next;
  end
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // wait for SD card initialization
      if (init_finished == 1) 
      P_next = S_MAIN_IDLE;
      else P_next = S_MAIN_INIT;
    S_MAIN_IDLE: // wait for button click
      if (btn_pressed == 1)
       P_next = S_MAIN_WAIT;
      else P_next = S_MAIN_IDLE;
    S_MAIN_WAIT: // issue a rd_req to the SD controller until it's ready
      P_next = S_MAIN_READ;
    S_MAIN_READ: // wait for the input data to enter the SRAM buffer
      if (sd_counter == 512) 
      P_next = S_MAIN_DONE;
      else P_next = S_MAIN_READ;
    S_MAIN_DONE: // read byte 0 of the superblock from sram[]
      P_next = S_MAIN_FIND;
    S_MAIN_FIND:
      if(sd_counter == 138) P_next = S_MAIN_TRANS;
      else if(!blkbegin && sd_counter == 9) P_next = S_MAIN_WAIT;
      else if (sd_counter < 138) P_next = S_MAIN_DONE;
      else P_next = S_MAIN_FIND;
    S_MAIN_TRANS:
      P_next = S_MAIN_END;
    S_MAIN_END:
      P_next = S_MAIN_ANS;
   S_MAIN_ANS:
      if(state_counter == 15) P_next = S_MAIN_PRINT;
      else P_next = S_MAIN_END;
   S_MAIN_PRINT:
      P_next = S_MAIN_PROMPT;
   S_MAIN_PROMPT:
      if(state_counter == 15) P_next = S_MAIN_STOP;
      else if(tx_byte == 8'h00) P_next = S_MAIN_PRINT;
      else P_next = S_MAIN_PROMPT;
   S_MAIN_STOP:
      P_next = S_MAIN_STOP;
    default:
      P_next = S_MAIN_IDLE;
  endcase
end

always @(posedge clk) begin
    if(~reset_n || (P == S_MAIN_ANS && P_next == S_MAIN_PRINT)) state_counter <= 0;
    else if((P == S_MAIN_ANS && P_next == S_MAIN_END) || (Q == S_UART_INCR && send_counter == 6'd23) ||(Q == S_UART_INCR && send_counter == 6'd30) || (Q == S_UART_INCR && send_counter == 6'd37) || (Q == S_UART_INCR && send_counter == 6'd44)) state_counter <= state_counter + 5'b1;
    else state_counter <= state_counter;
end



always @(posedge clk) begin
    if(~reset_n) blkbegin = 0;
    else if(P == S_MAIN_DONE && shift_reg[63:56] == "M" && shift_reg[55:48] == "A" && shift_reg[47:40] == "T" && shift_reg[39:32] == "X" 
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


assign input_num = data_out - ((data_out >= "A")? "7" : "0");

//INPUT A_MAT B_MAT
always @(posedge clk)begin
    if(~reset_n) A_mat = 128'b0;
    else if(P == S_MAIN_DONE && data_out != 8'h0A && blkbegin && sd_counter < 73 && data_out != 8'h0D)
        A_mat = {A_mat[4:127],input_num};
    else A_mat = A_mat;
    if(P == S_MAIN_TRANS) begin
        A_mat[8:15] <= A_mat[32:39];
        A_mat[32:39] <= A_mat[8:15];
        A_mat[16:23] <= A_mat[64:71];
        A_mat[64:71] <= A_mat[16:23];
        A_mat[24:31] <= A_mat[96:103];
        A_mat[96:103] <= A_mat[24:31];
        A_mat[48:55] <= A_mat[72:79];
        A_mat[72:79] <= A_mat[48:55];
        A_mat[56:63] <= A_mat[104:111];
        A_mat[104:111] <= A_mat[56:63];
        A_mat[112:119] <= A_mat[88:95];
        A_mat[88:95] <= A_mat[112:119];
    end
    else A_mat = A_mat;
end

always @(posedge clk)begin
    if(~reset_n) B_mat = 128'b0;
    else if(P == S_MAIN_DONE && data_out != 8'h0A && blkbegin && sd_counter > 72 && data_out != 8'h0D)
        B_mat = {B_mat[4:127],input_num};
    else B_mat = B_mat;
    if(P == S_MAIN_TRANS) begin
        B_mat[8:15] <= B_mat[32:39];
        B_mat[32:39] <= B_mat[8:15];
        B_mat[16:23] <= B_mat[64:71];
        B_mat[64:71] <= B_mat[16:23];
        B_mat[24:31] <= B_mat[96:103];
        B_mat[96:103] <= B_mat[24:31];
        B_mat[48:55] <= B_mat[72:79];
        B_mat[72:79] <= B_mat[48:55];
        B_mat[56:63] <= B_mat[104:111];
        B_mat[104:111] <= B_mat[56:63];
        B_mat[112:119] <= B_mat[88:95];
        B_mat[88:95] <= B_mat[112:119];
    end
    else B_mat = B_mat;
end


always @(posedge clk)begin
    if(~reset_n) matrix_counter <= 0;
    //else if(matrix_counter == 24) matrix_counter <= 0;
    else if(P == S_MAIN_ANS && P_next == S_MAIN_END) 
    begin
        if(matrix_counter == 24) matrix_counter <= 0;
        else matrix_counter <= matrix_counter + 5'd8;
    end
    else matrix_counter <= matrix_counter;
end
always @(posedge clk) begin
    if(~reset_n) row_counter <= 0;
    else if(state_counter == 0) row_counter <= 0;
    else if(state_counter == 3) row_counter <= 32;
    else if(state_counter == 7) row_counter <= 64;
    else if (state_counter == 11)row_counter <= 96;
    else row_counter <= row_counter;
end

always @(posedge clk) begin
    if(~reset_n) data_temp = 18'b0;
    else if(P == S_MAIN_END) begin
        if(state_counter < 16) data_temp <= 
          A_mat[(row_counter+ 0)+:8] * B_mat[(matrix_counter +  0)+:8] +
          A_mat[(row_counter+ 8)+:8] * B_mat[(matrix_counter + 32)+:8] +
          A_mat[(row_counter+ 16)+:8] * B_mat[(matrix_counter + 64)+:8] +
          A_mat[(row_counter+ 24)+:8] * B_mat[(matrix_counter + 96)+:8];
        else data_temp <= data_temp;
    end
    else data_temp <= data_temp;
end

//answer sram signal
assign answer_addr = state_counter;
assign answer_we = (P == S_MAIN_ANS);
assign answer_in = data_temp;




// FSM output logic: controls the 'rd_req' and 'rd_addr' signals.
always @(*) begin
  rd_req = (P == S_MAIN_WAIT);
  rd_addr = blk_addr;
end
/*assign rd_req = (P == S_MAIN_WAIT);
assign rd_addr = blk_addr;*/
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
  else sd_counter <= sd_counter;
end


// ------------------------------------------------------------------------
//uart
always @(*) begin
    {data[ 0],data[ 1],data[ 2],data[ 3],data[ 4],
    data[ 5],data[ 6],data[ 7],data[ 8],data[ 9],
    data[ 10],data[11],data[12],data[13]} = "The result is:";
    data[14] = 8'h0D;
    data[15] = 8'h0A;
	data[16] = "[";
	data[17] = " ";
	data[18] = ((answer_out[17:16] > 9)? "7":"0") + answer_out[17:16]; 
    data[19] = ((answer_out[15:12] > 9)? "7":"0") + answer_out[15:12];
    data[20] = ((answer_out[11:8] > 9)? "7":"0") + answer_out[11:8];
    data[21] = ((answer_out[7:4] > 9)? "7":"0") + answer_out[7:4];
    data[22] = ((answer_out[3:0] > 9)? "7":"0") + answer_out[3:0];
    data[23] = ",";
    data[24] = " ";
    data[25] = ((answer_out[17:16] > 9)? "7":"0") + answer_out[17:16]; 
    data[26] = ((answer_out[15:12] > 9)? "7":"0") + answer_out[15:12];
    data[27] = ((answer_out[11:8] > 9)? "7":"0") + answer_out[11:8];
    data[28] = ((answer_out[7:4] > 9)? "7":"0") + answer_out[7:4];
    data[29] = ((answer_out[3:0] > 9)? "7":"0") + answer_out[3:0];
    data[30] = ",";
    data[31] = " ";
    data[32] = ((answer_out[17:16] > 9)? "7":"0") + answer_out[17:16]; 
    data[33] = ((answer_out[15:12] > 9)? "7":"0") + answer_out[15:12];
    data[34] = ((answer_out[11:8] > 9)? "7":"0") + answer_out[11:8];
    data[35] = ((answer_out[7:4] > 9)? "7":"0") + answer_out[7:4];
    data[36] = ((answer_out[3:0] > 9)? "7":"0") + answer_out[3:0];
    data[37] = ",";
    data[38] = " ";
    data[39] = ((answer_out[17:16] > 9)? "7":"0") + answer_out[17:16]; 
    data[40] = ((answer_out[15:12] > 9)? "7":"0") + answer_out[15:12];
    data[41] = ((answer_out[11:8] > 9)? "7":"0") + answer_out[11:8];
    data[42] = ((answer_out[7:4] > 9)? "7":"0") + answer_out[7:4];
    data[43] = ((answer_out[3:0] > 9)? "7":"0") + answer_out[3:0];
    data[44] = " ";
    data[45] = "]";
    data[46] = 8'h0D;
    data[47] = 8'h0A;
    data[48] = 8'h00;
end


assign print_enable = (P == S_MAIN_PRINT && P_next == S_MAIN_PROMPT);
assign print_done = (tx_byte == 8'h00);

//uart transmit
always @(posedge clk) begin
  if (~reset_n) Q <= S_UART_IDLE;
  else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
  case (Q)
    S_UART_IDLE: // wait for the print_string flag
      if (print_enable) Q_next = S_UART_WAIT;
      else Q_next = S_UART_IDLE;
    S_UART_WAIT: // wait for the transmission of current data byte begins
      if (is_transmitting == 1) Q_next = S_UART_SEND;
      else Q_next = S_UART_WAIT;
    S_UART_SEND: // wait for the transmission of current data byte finishes
      if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
      else Q_next = S_UART_SEND;
    S_UART_INCR:
      if (tx_byte == 8'h00) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end

// FSM output logics
assign transmit = (Q_next == S_UART_WAIT ||
                  //(P == S_MAIN_WAIT_KEYIN1 && received) ||
                  //(P == S_MAIN_WAIT_KEYIN2 && received) ||
                  print_enable);
assign tx_byte = data[send_counter];

// UART send_counter control circuit
always @(posedge clk) begin
    if(~reset_n) send_counter <=0;
    else if(tx_byte == 8'h00) send_counter <= 6'd16;
    else send_counter <= send_counter + (Q_next == S_UART_INCR);
    /*if(Q_next == S_UART_INCR) send_counter <=  send_counter + 1;  
    else send_counter <= send_counter;*/
  /*case (P_next)
    S_MAIN_INIT: send_counter <= PROMPT1_STR;
    S_MAIN_WAIT_KEYIN1: send_counter <= PROMPT2_STR;
    S_MAIN_WAIT_KEYIN2: send_counter <= REPLY_STR;
    default: send_counter <= send_counter + (Q_next == S_UART_INCR);
  endcase*/
end


endmodule
