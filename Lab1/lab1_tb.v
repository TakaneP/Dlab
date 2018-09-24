`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/15 17:23:22
// Design Name: 
// Module Name: Seqmultiplier_tb
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


module Seqmultiplier_tb;
    reg clk = 1;
    reg [7:0] A,B;
    reg enable;
    
    wire [15:0] C;
    SeqMultiplier uut(
        .clk(clk),
        .enable(enable),
        .A(A),
        .B(B),
        .C(C)
    );
    always
        #5 clk = !clk;
    initial begin
        A = 0; B = 0; enable = 0;
    #10;
    enable = 1;
    
    
   // A = 8'b00000101; B = 8'b00001010;

   A = 8'b11111010; B = 8'b00000100;
  //  #50;
  //  A = 4'b0000; B = 4'b1111;
 //   #50;
 //   A = 4'b0110; B = 4'b0001;
    end
endmodule
