`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of CS, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/04/27 15:06:57
// Design Name: UART I/O example for Arty
// Module Name: lab4
// Project Name: 
// Target Devices: Xilinx FPGA @ 100MHz
// Tool Versions: 
// Description: 
// 
// The parameters for the UART controller are 9600 baudrate, 8-N-1-N
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab4(
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,
  input  uart_rx,
  output uart_tx
);

localparam [3:0] S_MAIN_INIT = 0, S_MAIN_PROMPT = 1,
                 S_MAIN_WAIT_KEY = 2, S_MAIN_KEYSTROKE = 3,S_MAIN_PROMPT2 = 5,S_MAIN_ANSWER = 7,S_MAIN_WAIT_GCD = 8;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                 S_UART_SEND = 2, S_UART_INCR = 3;
// declare system variables
wire print_enable, print_done;
reg [6:0] send_counter;
reg [3:0] P, P_next;
reg [1:0] Q, Q_next;
reg [2:0] R, R_next;
reg [23:0] init_counter;
wire enter_pressed;
wire keystroke;
reg num_pressed;
reg [15:0] A;
reg [15:0] B;
reg [39:0] store;
reg [15:0] next_A;
reg [15:0] next_B;
reg [15:0] C;
reg [15:0] Swap;
reg [7:0] Answer[3:0];
wire rdy;
wire result_taken;
reg done;
reg flag = 1'b0;
wire do_enable;
reg answer_done = 0;
reg [15:0]num_counter;
// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

/* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
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

// Initializes some strings.
// System Verilog has an easier way to initialize an array,
// but we are using Verilog 2005 :(
//
localparam MEM_SIZE = 91;
localparam PROMPT_STR = 0;
localparam SECOND_STR = 34;
localparam HELLO_STR = 69;
reg [7:0] data[0:MEM_SIZE-1];

initial begin
  num_counter = 16'b0;
  A = 16'b0;
  B = 16'b0;
  next_A = 16'b0;
  next_B = 16'b0;
  C = 16'b0;
  { data[ 0], data[ 1], data[ 2], data[ 3], data[ 4], data[ 5], data[ 6], data[ 7],
    data[ 8], data[ 9], data[10], data[11], data[12], data[13], data[14], data[15],
    data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
    data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],data[32],data[33]}
  <= { 8'h0D,8'h0A,"Enter the first decimal number:", 8'h00};
   { data[34],data[35],data[36], data[37], data[38], data[39], data[40], data[41],
     data[42], data[43], data[44], data[45], data[46], data[47], data[48], data[49],
     data[50], data[51], data[52], data[53], data[54], data[55], data[56], data[57],
     data[58], data[59], data[60], data[61], data[62], data[63], data[64], data[65],data[66],data[67],data[68]}
  <= { 8'h0D,8'h0A,"Enter the second decimal number:", 8'h00};
  { data[69],data[70],data[71], data[72], data[73], data[74], data[75], data[76],
    data[77], data[78], data[79], data[80], data[81], data[82], data[83], data[84]}
  <= { "Hello, World!", 8'h0D, 8'h0A, 8'h00 };
end


always @ (posedge clk)
begin
    if(~reset_n)
    begin
      A = 16'b0;
      B = 16'b0;
      C = 16'b0;
      { data[ 0], data[ 1], data[ 2], data[ 3], data[ 4], data[ 5], data[ 6], data[ 7],
        data[ 8], data[ 9], data[10], data[11], data[12], data[13], data[14], data[15],
        data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
        data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],data[32],data[33]}
      <= { 8'h0D,8'h0A,"Enter the first decimal number:", 8'h00};
      { data[34],data[35],data[36], data[37], data[38], data[39], data[40], data[41],
       data[42], data[43], data[44], data[45], data[46], data[47], data[48], data[49],
       data[50], data[51], data[52], data[53], data[54], data[55], data[56], data[57],
       data[58], data[59], data[60], data[61], data[62], data[63], data[64], data[65],data[66],data[67],data[68]}
        <= { 8'h0D,8'h0A,"Enter the second decimal number:", 8'h00};
      { data[69],data[70],data[71], data[72], data[73], data[74], data[75], data[76],
        data[77], data[78], data[79], data[80], data[81], data[82], data[83], data[84]}
          <= { "Hello, World!", 8'h0D, 8'h0A, 8'h00 };
    end
    else
    begin
      if(keystroke && !flag) 
      begin
        A = A*10 + rx_temp - 48;
      end
      else if(keystroke && flag) 
      begin
        B = B*10 + rx_temp - 48;
      end
      else  A = A;
      { data[ 0], data[ 1], data[ 2], data[ 3], data[ 4], data[ 5], data[ 6], data[ 7],
        data[ 8], data[ 9], data[10], data[11], data[12], data[13], data[14], data[15],
        data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
        data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],data[32],data[33]}
      <= { 8'h0D,8'h0A,"Enter the first decimal number:", 8'h00};
      { data[34],data[35],data[36], data[37], data[38], data[39], data[40], data[41],
       data[42], data[43], data[44], data[45], data[46], data[47], data[48], data[49],
       data[50], data[51], data[52], data[53], data[54], data[55], data[56], data[57],
       data[58], data[59], data[60], data[61], data[62], data[63], data[64], data[65],data[66],data[67],data[68]}
        <= { 8'h0D,8'h0A,"Enter the second decimal number:", 8'h00};
      { data[69],data[70],data[71], data[72], data[73], data[74], data[75], data[76],
        data[77], data[78], data[79], data[80], data[81], data[82], data[83], data[84],
        data[85],data[86],data[87],data[88],data[89],data[90]}
      <= {8'h0D,8'h0A, "The GCD is: 0X",Answer[3],Answer[2],Answer[1],Answer[0], 8'h0D,  8'h00 };
    end

    if(do_enable)
      begin
         if ( A < B )
         begin
             Swap = A;
             A = B;
             B = Swap;
         end
         else if ( B != 0)
             A = A - B;
         else
         begin
             done = 1;
             C = A;
         end
     end
     else
     begin
         done = 0;
         Swap = 0;
         A = A;
         B = B;
         C = C;
     end
     if(result_taken)
     begin
         A = 0;
         B = 0;
     end
     else
     begin
         A = A;
         B = B;
         C = C;
         Swap = Swap;
     end
 end
always @(posedge clk)
begin
    if(rdy)
    begin
        if(C[3:0] == 4'b0) Answer[0] = 8'h30;
        else if(C[3:0] == 4'd1)Answer[0] = 8'h31;
        else if(C[3:0] == 4'd2)Answer[0] = 8'h32;
        else if(C[3:0] == 4'd3)Answer[0] = 8'h33;
        else if(C[3:0] == 4'd4)Answer[0] = 8'h34;
        else if(C[3:0] == 4'd5)Answer[0] = 8'h35;
        else if(C[3:0] == 4'd6)Answer[0] = 8'h36;
        else if(C[3:0] == 4'd7)Answer[0] = 8'h37;
        else if(C[3:0] == 4'd8)Answer[0] = 8'h38;
        else if(C[3:0] == 4'd9)Answer[0] = 8'h39;
        else if(C[3:0] == 4'd10)Answer[0] = 8'h41;
        else if(C[3:0] == 4'd11)Answer[0] = 8'h42;
        else if(C[3:0] == 4'd12)Answer[0] = 8'h43;
        else if(C[3:0] == 4'd13)Answer[0] = 8'h44;
        else if(C[3:0] == 4'd14)Answer[0] = 8'h45;
        else Answer[0] = 8'h46;
        if(C[7:4] == 4'b0) Answer[1] = 8'h30;
        else if(C[7:4] == 4'd1)Answer[1] = 8'h31;
        else if(C[7:4] == 4'd2)Answer[1] = 8'h32;
        else if(C[7:4] == 4'd3)Answer[1] = 8'h33;
        else if(C[7:4] == 4'd4)Answer[1] = 8'h34;
        else if(C[7:4] == 4'd5)Answer[1] = 8'h35;
        else if(C[7:4] == 4'd6)Answer[1] = 8'h36;
        else if(C[7:4] == 4'd7)Answer[1] = 8'h37;
        else if(C[7:4] == 4'd8)Answer[1] = 8'h38;
        else if(C[7:4] == 4'd9)Answer[1] = 8'h39;
        else if(C[7:4] == 4'd10)Answer[1] = 8'h41;
        else if(C[7:4] == 4'd11)Answer[1] = 8'h42;
        else if(C[7:4] == 4'd12)Answer[1] = 8'h43;
        else if(C[7:4] == 4'd13)Answer[1] = 8'h44;
        else if(C[7:4] == 4'd14)Answer[1] = 8'h45;
        else Answer[1] = 8'h46;
        if(C[11:8] == 4'b0) Answer[2] = 8'h30;
        else if(C[11:8] == 4'd1)Answer[2] = 8'h31;
        else if(C[11:8] == 4'd2)Answer[2] = 8'h32;
        else if(C[11:8] == 4'd3)Answer[2] = 8'h33;
        else if(C[11:8] == 4'd4)Answer[2] = 8'h34;
        else if(C[11:8] == 4'd5)Answer[2] = 8'h35;
        else if(C[11:8] == 4'd6)Answer[2] = 8'h36;
        else if(C[11:8] == 4'd7)Answer[2] = 8'h37;
        else if(C[11:8] == 4'd8)Answer[2] = 8'h38;
        else if(C[11:8] == 4'd9)Answer[2] = 8'h39;
        else if(C[11:8] == 4'd10)Answer[2] = 8'h41;
        else if(C[11:8] == 4'd11)Answer[2] = 8'h42;
        else if(C[11:8] == 4'd12)Answer[2] = 8'h43;
        else if(C[11:8] == 4'd13)Answer[2] = 8'h44;
        else if(C[11:8] == 4'd14)Answer[2] = 8'h45;
        else Answer[2] = 8'h46;
        if(C[15:12] == 4'b0) Answer[3] = 8'h30;
        else if(C[15:12] == 4'd1)Answer[3] = 8'h31;
        else if(C[15:12] == 4'd2)Answer[3] = 8'h32;
        else if(C[15:12] == 4'd3)Answer[3] = 8'h33;
        else if(C[15:12] == 4'd4)Answer[3] = 8'h34;
        else if(C[15:12] == 4'd5)Answer[3] = 8'h35;
        else if(C[15:12] == 4'd6)Answer[3] = 8'h36;
        else if(C[15:12] == 4'd7)Answer[3] = 8'h37;
        else if(C[15:12] == 4'd8)Answer[3] = 8'h38;
        else if(C[15:12] == 4'd9)Answer[3] = 8'h39;
        else if(C[15:12] == 4'd10)Answer[3] = 8'h41;
        else if(C[15:12] == 4'd11)Answer[3] = 8'h42;
        else if(C[15:12] == 4'd12)Answer[3] = 8'h43;
        else if(C[15:12] == 4'd13)Answer[3] = 8'h44;
        else if(C[15:12] == 4'd14)Answer[3] = 8'h45;
        else Answer[3] = 8'h46;
        answer_done = 1;
    end
    else
    begin 
        Answer[0] = Answer[0];
        answer_done = 0;
    end
end



// Combinational I/O logics
assign result_taken = answer_done;
assign rdy = done;
assign usr_led = P;
assign enter_pressed = (rx_temp == 8'h0D);
assign keystroke = (num_counter < 5) ? (rx_temp == 8'h30 || rx_temp == 8'h31 || rx_temp == 8'h32 || rx_temp == 8'h33 || rx_temp == 8'h34 || rx_temp == 8'h35 || rx_temp == 8'h36 || rx_temp == 8'h37 || rx_temp == 8'h38 || rx_temp == 8'h39) : 0;
// ------------------------------------------------------------------------
// Main FSM that reads the UART input and triggers
// the output of the string "Hello, World!".324
always @(posedge clk) begin
  if (~reset_n) P <= S_MAIN_INIT;
  else P <= P_next;
end
always @ (posedge clk)
begin
    if (~reset_n) num_counter = 0;
    else if(enter_pressed) num_counter = 0;
    else  if(keystroke)num_counter = num_counter + 1;
    else num_counter = num_counter;
end
always @ (posedge clk)
begin
    if((keystroke && P_next == S_MAIN_KEYSTROKE)) num_pressed = 1;
    else if(P_next == S_MAIN_WAIT_KEY) num_pressed = 0;
    else num_pressed = num_pressed;
end
always @(posedge clk)
begin
    if(enter_pressed)
        flag = ~flag;
    else
        flag = flag;
end
always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // Delay 10 us.
	   if (init_counter < 1000) P_next = S_MAIN_INIT;
		else P_next = S_MAIN_PROMPT;
    S_MAIN_PROMPT: // Print the prompt message.
      if (print_done) P_next = S_MAIN_WAIT_KEY;
      else P_next = S_MAIN_PROMPT;
    S_MAIN_WAIT_KEY: // wait for <Enter> key.
      if (enter_pressed) 
      begin
        if(!flag)P_next = S_MAIN_PROMPT2;
        else P_next = S_MAIN_WAIT_GCD;
      end
      else if(keystroke) P_next = S_MAIN_KEYSTROKE;                                   
      else P_next = S_MAIN_WAIT_KEY;
    S_MAIN_KEYSTROKE: //PRINT keystroke
      if (print_done)  P_next = S_MAIN_WAIT_KEY;
      else P_next = S_MAIN_KEYSTROKE;
    S_MAIN_PROMPT2: //Print the second prompt mwssage
      if(print_done) P_next = S_MAIN_WAIT_KEY;
      else P_next = S_MAIN_PROMPT2;
    S_MAIN_WAIT_GCD:
      if(result_taken) P_next = S_MAIN_ANSWER;
      else P_next = S_MAIN_WAIT_GCD;
    S_MAIN_ANSWER: // Print the hello message.
      if (print_done) P_next = S_MAIN_INIT;
      else P_next = S_MAIN_ANSWER;
  endcase
end

// FSM output logics: print string control signals.
assign print_enable = (P != S_MAIN_PROMPT && P_next == S_MAIN_PROMPT) ||(P == S_MAIN_WAIT_KEY && P_next == S_MAIN_PROMPT2)||
                  (P == S_MAIN_WAIT_GCD  && P_next == S_MAIN_ANSWER) ||(P == S_MAIN_WAIT_KEY && P_next == S_MAIN_KEYSTROKE);
assign print_done = (tx_byte == 8'h0) || (num_pressed && Q_next == S_UART_IDLE);
assign do_enable = (P == S_MAIN_WAIT_KEY && P_next == S_MAIN_WAIT_GCD) || (P == S_MAIN_WAIT_GCD && P_next == S_MAIN_WAIT_GCD);
// Initialization counter.
always @(posedge clk) begin
  if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the controller to send a string to the UART.
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
      if (tx_byte == 8'h0)
      Q_next = S_UART_IDLE; // string transmission ends
      else if (num_pressed)  Q_next = S_UART_IDLE;
      else Q_next = S_UART_WAIT;
  endcase
end

// FSM output logics
assign transmit = (Q_next == S_UART_WAIT || print_enable);
assign tx_byte = (keystroke) ? rx_temp : data[send_counter];

// UART send_counter control circuit
always @(posedge clk) begin
    if(P_next ==  S_MAIN_INIT) send_counter <= PROMPT_STR;
    else if (P == S_MAIN_WAIT_GCD) send_counter <= HELLO_STR;
    else if (P_next == S_MAIN_WAIT_KEY) send_counter <= SECOND_STR;
    else send_counter <= keystroke ? send_counter : send_counter + (Q_next == S_UART_INCR);
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// The following logic stores the UART input in a temporary buffer.
// The input character will stay in the buffer for one clock cycle.
always @(posedge clk) begin
  rx_temp <= (received)? rx_byte : 8'h0;
end
// ------------------------------------------------------------------------
endmodule
