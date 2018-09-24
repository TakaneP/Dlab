`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of CS, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/10/16 14:21:33
// Design Name: 
// Module Name: lab5
// Project Name: 
// Target Devices: Xilinx FPGA @ 100MHz 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab5(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);


localparam [2:0] INIT = 0, CAL = 1, PRINT = 2, REVERSE = 3;


reg [2:0] P,P_next;
wire btn_level, btn_pressed;
reg prev_btn_level;
reg [127:0] row_A = "WAIT FOR PRIME  "; // Initialize the text of the first row. 
reg [127:0] row_B = "show a message.."; // Initialize the text of the second row.
reg [23:0] init_counter;
reg [1023:0] prime = {1024{1'b1}};
reg cal_done = 0,table_done = 0;
reg [11:0] idx = 2,jdx = 2,prime_counter = 2;
reg [7:0] table_counter = 1,index1,index2,index3; 
reg [11:0] primetable[0:172];
reg [7:0] data[0:9];
reg [31:0] delay_counter;
// turn off all the LEDs
assign usr_led = P;
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
  .btn_input(usr_btn[3]),
  .btn_output(btn_level)
);
always @(posedge clk)
begin
    if(~reset_n) delay_counter = 0;
    else if(btn_pressed) delay_counter = 0;
    else if(delay_counter <= 70000000)
        delay_counter = delay_counter + 1;
    else
        delay_counter = 0;
end
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);

//MAIN FSM
always @(posedge clk) begin
  if (~reset_n) P <= INIT;
  else P <= P_next;
end
always @(*) begin
    case(P)
        INIT:
            if (init_counter < 1000) P_next = INIT;
            else P_next = CAL;
        CAL:
            if(table_done) 
            P_next = PRINT;
            else P_next = CAL;
        PRINT:
            if(btn_pressed) P_next = REVERSE;
            else P_next = PRINT;
        REVERSE:
            if (btn_pressed) P_next = PRINT;
            else P_next = REVERSE;
    endcase
end
always@(posedge clk) begin
    if(P == CAL)begin
        if(prime[idx])
        begin
            jdx = jdx + idx;
            prime[jdx] = 0;
        end
        else prime[jdx] = prime[jdx];
        if(jdx > 1023 || !prime[idx])
        begin
            idx = idx + 1;
            jdx = idx;
        end
        if(idx == 1023)
            cal_done = 1;
        else
            cal_done = cal_done;
    end
    else cal_done = 0;
end
always@(posedge clk) begin
    if(cal_done)
    begin
        if(prime[prime_counter])
        begin
            primetable[table_counter] = prime_counter; 
            table_counter = table_counter + 1;
        end
        else primetable[table_counter] = primetable[table_counter];
        prime_counter = prime_counter + 1;
        if(prime_counter > 1023) table_done = 1;
        else table_done = table_done;
    end
    else table_done = 0;
end
always @(posedge clk) begin
  if (P == INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end

always @(posedge clk) begin
    if(P == INIT)
    begin
        index1 = 0;
        index2 = 0;
        index3 = 0;
    end
    else
    begin
        index1 = index1;
        index2 = index2;
        index3 = index3;
    end
    if(P == PRINT && delay_counter == 70000000)
    begin
        if(index1 == 172) index1 = 1;
        else index1 = index1 + 1;
        index2 = index1 + 1;
        if(index2 == 173) index2 = 1;
        else index2 = index2;
        if(index1[7:4] > 9) data[0] = index1[7:4] + 55;
        else data[0] = index1[7:4] + 48;
        if(index1[3:0] > 9) data[1] = index1[3:0] + 55;
        else data[1] = index1[3:0] + 48;
        if(primetable[index1][11:8] > 9) data[2] = primetable[index1][11:8] + 55;
        else data[2] = primetable[index1][11:7] + 48;
        if(primetable[index1][7:4] > 9) data[3] = primetable[index1][7:4] + 55;
        else data[3] = primetable[index1][7:4] + 48;
        if(primetable[index1][3:0] > 9) data[4] = primetable[index1][3:0] + 55;
        else data[4] = primetable[index1][3:0] + 48;
        
        if(index2[7:4] > 9) data[5] = index2[7:4] + 55;
        else data[5] = index2[7:4] + 48;
        if(index2[3:0] > 9) data[6] = index2[3:0] + 55;
        else data[6] = index2[3:0] + 48;
        if(primetable[index2][11:8] > 9) data[7] = primetable[index2][11:8] + 55;
        else data[7] = primetable[index2][11:7] + 48;
        if(primetable[index2][7:4] > 9) data[8] = primetable[index2][7:4] + 55;
        else data[8] = primetable[index2][7:4] + 48;
        if(primetable[index2][3:0] > 9) data[9] = primetable[index2][3:0] + 55;
        else data[9] = primetable[index2][3:0] + 48;
        row_A = {"Prime #",data[0],data[1]," is ",data[2],data[3],data[4]};
        row_B = {"Prime #",data[5],data[6]," is ",data[7],data[8],data[9]};
    end
    else if(P == REVERSE && delay_counter == 70000000)
    begin
        if(index1 == 1) index1 = 172;
        else index1 = index1 - 1;
        index2 = index1 - 1;
        if(index2 == 0) index2 = 172;
        else index2 = index2;
        if(index2[7:4] > 9) data[0] = index2[7:4] + 55;
        else data[0] = index2[7:4] + 48;
        if(index2[3:0] > 9) data[1] = index2[3:0] + 55;
        else data[1] = index2[3:0] + 48;
        if(primetable[index2][11:8] > 9) data[2] = primetable[index2][11:8] + 55;
        else data[2] = primetable[index2][11:7] + 48;
        if(primetable[index2][7:4] > 9) data[3] = primetable[index2][7:4] + 55;
        else data[3] = primetable[index2][7:4] + 48;
        if(primetable[index2][3:0] > 9) data[4] = primetable[index2][3:0] + 55;
        else data[4] = primetable[index2][3:0] + 48;
        
        if(index1[7:4] > 9) data[5] = index1[7:4] + 55;
        else data[5] = index1[7:4] + 48;
        if(index1[3:0] > 9) data[6] = index1[3:0] + 55;
        else data[6] = index1[3:0] + 48;
        if(primetable[index1][11:8] > 9) data[7] = primetable[index1][11:8] + 55;
        else data[7] = primetable[index1][11:7] + 48;
        if(primetable[index1][7:4] > 9) data[8] = primetable[index1][7:4] + 55;
        else data[8] = primetable[index1][7:4] + 48;
        if(primetable[index1][3:0] > 9) data[9] = primetable[index1][3:0] + 55;
        else data[9] = primetable[index1][3:0] + 48;
        row_A = {"Prime #",data[0],data[1]," is ",data[2],data[3],data[4]};
        row_B = {"Prime #",data[5],data[6]," is ",data[7],data[8],data[9]};
    end
    else
    begin
        data[0] = data[0];
        data[1] = data[1];
        data[2] = data[2];
        data[3] = data[3];
        data[4] = data[4];
        data[5] = data[5];
        data[6] = data[6];
        data[7] = data[7];
        data[8] = data[8];
        data[9] = data[9];   
    end
end
/*always @(posedge clk) begin
  if (~reset_n) begin
    // Initialize the text when the user hit the reset button
    row_A = "Press BTN3 to   ";
    row_B = "show a message..";
  end else if (btn_pressed) begin
    row_A <= "Hello, World!   ";
    row_B <= "Demo of the LCD.";
  end
end*/

endmodule
