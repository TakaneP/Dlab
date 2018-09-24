`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 15:03:31
// Design Name: 
// Module Name: lab3
// Project Name: 
// Target Devices: 
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


module lab3(
  input  clk,            // System clock at 100 MHz
  input  reset_n,        // System reset signal, in negative logic
  input  [3:0] usr_btn,  // Four user pushbuttons
  output [3:0] usr_led   // Four yellow LEDs
);
  reg [3:0] but_pre;
  reg [3:0] bright;
  reg but0_pre;
  reg but1_pre;
  reg but2_pre;
  reg but3_pre;
  reg [23:0] count;
  reg [23:0] count2;
  reg [5:0] pwn_count;
  reg [2:0] ctrl = 3'd4;
always @ (posedge clk)
begin
    if(!reset_n)
    begin
        count = 24'b0;
        but_pre = 4'b0;
        but1_pre = 0;
        but0_pre = 0;
    end
    else
    begin
        if(but0_pre && but_pre != 4'b1000)
        begin
            but_pre = but_pre - 1;
            but0_pre = 0;
            count = 24'b0;
        end
        else if(but1_pre && but_pre != 4'b0111)
        begin
            but_pre = but_pre + 1;
            but1_pre = 0;
            count = 24'b0;
        end
        else
            but_pre = but_pre;  
    end
    if(usr_btn[0])
    begin
        count = count + 1;
        if(~count == 24'b0)
            but0_pre = 1;
        else
            but0_pre = but0_pre;
    end
    else
    begin
        but0_pre = 0;
    end
    if(usr_btn[1])
    begin
        count = count + 1;
        if(~count == 24'b0)
            but1_pre = 1;
        else
            but1_pre = but1_pre;
    end
    else
    begin
        but1_pre = 0;
    end
end

always @ (posedge clk)
begin
    if(!reset_n)
        pwn_count = 6'b0;
    else if(pwn_count == 6'd20)
        pwn_count = 6'b0;
    else
        pwn_count = pwn_count + 1;
end
        
always @ (posedge clk)
begin
    if(!reset_n)
    begin
        ctrl = 3'd4;
        count2 = 24'b0;
    end
    else
    begin
       if(but2_pre && ctrl != 3'b0)
        begin
            ctrl = ctrl - 1;
            but2_pre = 0;
            count2 = 24'b0;
        end
        else if(but3_pre && ctrl != 3'd4)
        begin
            ctrl = ctrl + 1;
            but3_pre = 0;
            count2 = 24'b0;
        end
        else
            bright = bright;
    end
    if(usr_btn[2])
    begin
        count2 = count2 + 1;
        if(~count2 == 24'b0)
            but2_pre = 1;
        else
            but2_pre = but2_pre;
    end
    else
    begin
        but2_pre = 0;
    end
    if(usr_btn[3])
    begin
        count2 = count2 + 1;
        if(~count2 == 24'b0)
            but3_pre = 1;
        else
            but3_pre = but3_pre;
    end
    else
    begin
        but3_pre = 0;
    end
    if(ctrl == 3'd4)
        bright = but_pre;
    else if(ctrl == 3'd3)
    begin
        bright = (pwn_count >= 20'd5) ? but_pre : 4'b0;
    end
    else if(ctrl == 3'd2)
        bright = (pwn_count >= 20'd10) ? but_pre : 4'b0;
    else if(ctrl == 3'd1)
        bright = (pwn_count >= 20'd15) ? but_pre : 4'b0;
    else
        bright = (pwn_count >= 20'd20) ? but_pre : 4'b0; 
end

assign usr_led = bright;

endmodule
