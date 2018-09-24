`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/19 11:25:45
// Design Name: 
// Module Name: mmult
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


module mmult(
  input  clk,                 // Clock signal
  input  reset_n,             // Reset signal (negative logic)
  input  enable,              // Activation signal for matrix multiplication
  input  [0:9*8-1] A_mat,     // A matrix
  input  [0:9*8-1] B_mat,     // B matrix
  output valid,               // Signals that the output is valid to read
  output reg [0:9*17-1] C_mat // The result of A x B
);

    reg [7:0] A [0:2][0:2];
    reg [7:0] B [0:2][0:2];
    reg [15:0] C [0:2][0:2];
    reg [3:0] count;
    integer i,j,k;
    reg rdy = 0;
    
    always @ (posedge clk)
    begin
        if(!reset_n)
            count = 3'b100;
        else if(enable && (count == 0))
            count = 0;
        else if(enable)
            count = count - 1;
        else
            ;
    end
    always @ (posedge clk)
    begin
        if(!reset_n)
        begin
            {A[0][0],A[0][1],A[0][2],A[1][0],A[1][1],A[1][2],A[2][0],A[2][1],A[2][2]} = A_mat;
            {B[0][0],B[0][1],B[0][2],B[1][0],B[1][1],B[1][2],B[2][0],B[2][1],B[2][2]} = B_mat;
            {C[0][0],C[0][1],C[0][2],C[1][0],C[1][1],C[1][2],C[2][0],C[2][1],C[2][2]} = 144'b0;
        end
    end
   always @ (posedge clk)
   begin
        if(enable)
        begin
           if(count == 3)
           begin
               for(i = 0;i < 3;i = i + 1)
               begin
                    for(j = 0;j < 3;j = j + 1)
                    begin    
                            C[i][j] = C[i][j] + (A[i][0] * B[0][j]);
                    end
               end
          end
          else if(count == 2)
          begin
                 for(i = 0;i < 3;i = i + 1)
                 begin
                      for(j = 0;j < 3;j = j + 1)
                      begin    
                              C[i][j] = C[i][j] + (A[i][1] * B[1][j]);
                      end
                 end
           end
           else if(count == 1)
           begin
                for(i = 0;i < 3;i = i + 1)
                begin
                     for(j = 0;j < 3;j = j + 1)
                     begin    
                             C[i][j] = C[i][j] + (A[i][2] * B[2][j]);
                     end
                end
                rdy = 1;
            end
            else
                ;
           C_mat = {1'b0,C[0][0],1'b0,C[0][1],1'b0,C[0][2],1'b0,C[1][0],1'b0,C[1][1],1'b0,C[1][2],1'b0,C[2][0],1'b0,C[2][1],1'b0,C[2][2]};
       end         
    end
    assign valid = rdy;
endmodule
