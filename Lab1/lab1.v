`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 14:35:55
// Design Name: 
// Module Name: multiplier
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


module SeqMultiplier(
    input wire clk,
    input wire enable,
    input wire [7:0] A,
    input wire [7:0] B,
    output wire [15:0] C
    );
     
    reg [3:0] count;
    reg [7:0] Q;
    reg [7:0] D;
    reg [15:0] E;
    reg Cout;
    always @ (posedge clk) begin
        if(!enable)
        begin
            count = 4'b1001;
            E = 16'b0;
            Cout = 0;
        end
        else if(count == 0)
            count = 0;
        else
            count = count - 1;
    end
    always @ (posedge clk) 
    begin
        if(count == 8)
        begin
            D = {B[7:0]};
            Q = 8'b00000000;
        end
        if(enable && (count > 0) && (count <= 8))
        begin
            if(!D[0])
            begin
               D = {Q[0],D[7:1]};
               Q = {Cout,Q[7:1]};
            end
            else
            begin   
                {Cout,Q} = (Q + A);
                D = {Q[0],D[7:1]};
                Q = {Cout,Q[7:1]};
                Cout = 0;
            end
            E = {Q[7:0],D[7:0]};
        end
        else
            ;         
    end
    assign C = E;
endmodule

