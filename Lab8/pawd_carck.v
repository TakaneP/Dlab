`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 01:46:52
// Design Name: 
// Module Name: pawd_crack
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


module pawd_crack(
    input clk,
    input reset_n,
    input [0:127]password_hash,
    input [4:0]blocknum,
    input btn_pressed,
    output reg find,
    output reg [7:0] out0,
    output reg [7:0] out1,
    output reg [7:0] out2,
    output reg [7:0] out3,
    output reg [7:0] out4,
    output reg [7:0] out5,
    output reg [7:0] out6,
    output reg [7:0] out7
    );
    localparam [3:0] INIT = 0,Pre = 1, For1 = 2, For2part1 = 3, Store = 4, Cmp = 5, Show = 6,Wait = 7,Sprintf = 8,For2part2 = 9, For2part3 = 10,For2part4 = 11,Sprintf2 = 12,Initialidx = 13;
    
    reg [3:0] P,P_next;
    reg [23:0] init_counter = 0;
    reg pre_done = 0,for1_done = 0,store_done = 0;
    wire for2_done;
      
    //CHUNK1
    reg [6:0] for2_counter = 0;
    reg sprintf_done = 0;
    reg [7:0] msg[0:119];
    
    reg [7:0] hash[0:15];
    
    reg [3:0] idx[0:8];
    reg [3:0] idx2[0:8];
    reg [3:0] idx3[0:8];
    reg [3:0] idx4[0:8];
    
    reg [31:0] r[0:63];
    reg [31:0] k[0:63];
    
    reg [31:0] h0,h1,h2,h3;
    
    
    reg [31:0] w[0:15];
    
    reg [31:0] a,b,c,d,f,g,rotatepart1,rotatepart2,temp;
    
    
    
    
    initial begin
        {r[0 ],r[1 ],r[2 ],r[3 ],r[4 ],r[5 ],r[6 ],r[7 ],r[8 ],r[9 ],r[10],r[11],r[12],r[13],r[14],r[15],
        r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],
        r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47],
        r[48],r[49],r[50],r[51],r[52],r[53],r[54],r[55],r[56],r[57],r[58],r[59],r[60],r[61],r[62],r[63]} <=
        {
            32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22,
            32'd5,  32'd9, 32'd14, 32'd20, 32'd5,  32'd9, 32'd14, 32'd20, 32'd5,  32'd9, 32'd14, 32'd20, 32'd5,  32'd9, 32'd14, 32'd20,
            32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23,
            32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21
        };
        { k[0 ], k[1 ], k[2 ], k[3 ], k[4 ], k[5 ], k[6 ], k[7 ], k[8 ], k[9 ], k[10], k[11], k[12], k[13], k[14], k[15], 
          k[16], k[17], k[18], k[19], k[20], k[21], k[22], k[23], k[24], k[25], k[26], k[27], k[28], k[29], k[30], k[31], 
          k[32], k[33], k[34], k[35], k[36], k[37], k[38], k[39], k[40], k[41], k[42], k[43], k[44], k[45], k[46], k[47], 
          k[48], k[49], k[50], k[51], k[52], k[53], k[54], k[55], k[56], k[57], k[58], k[59], k[60], k[61], k[62], k[63]} <=
        { 32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501,
          32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821,
          32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8,
          32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a,
          32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70,
          32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665,
          32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1,
          32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};
    
        { w[0 ], w[1 ], w[2 ], w[3 ], w[4 ], w[5 ], w[6 ], w[7 ], w[8 ], w[9 ], w[10], w[11], w[12], w[13], w[14], w[15]} <=
        {32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0,32'd0};
       
        a <= 0;
        b <= 0;c <= 0;d <= 0;f <= 0;g <= 0;rotatepart1 <= 0;rotatepart2 <= 0;
        find <= 0;
    end
    
    
    

always @(posedge clk) begin
      if (P == INIT) init_counter <= init_counter + 1;
      else init_counter <= 0;
    end
    
    
    //MAIN FSM
    always @(posedge clk) begin
      if (~reset_n) P <= INIT;
      else P <= P_next;
    end
    always @(*) begin
        case(P)
            INIT:
                if (init_counter < 1000) P_next = INIT;
                else P_next = Wait;
            Wait:
                if(btn_pressed)  P_next = Initialidx;
                else P_next = Wait;
            Initialidx:
                P_next = Sprintf;
            Sprintf:
                if(sprintf_done) P_next = Sprintf2;
                else P_next = Sprintf;
            Sprintf2:
                P_next = Pre;
            Pre:
                if(pre_done) P_next = For1;
                else P_next = Pre;
            For1:
                if(for1_done) P_next = For2part1;
                else P_next = For1;
            For2part1:
                P_next = For2part2;
            For2part2:
                P_next = For2part3;
            For2part3:
                P_next = For2part4;
            For2part4:
                if (for2_done) P_next = Store;
                else P_next = For2part1;
            Store:
                if(store_done) P_next = Cmp;
                else P_next = Store;
            Cmp:
                if(find) P_next = Show;
                else P_next = Sprintf;
            Show:
                P_next = Show;
        endcase
    end
    always @(posedge clk)begin
        if(P == Initialidx) begin
            if(blocknum == 0) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 1) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd0,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 2) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 3) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd1,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 4) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                 {4'd0,4'd2,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 5) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd2,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 6) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd3,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 7) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd3,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 8) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd4,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 9) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd4,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 10) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 11) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd5,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 12) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd6,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 13) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd6,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 14) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd7,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 15) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                 {4'd0,4'd7,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 16) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd8,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 17) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd8,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 18) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd9,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else if(blocknum == 19) begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd9,4'd5,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
            else  begin
                {idx[0],idx[1],idx[2],idx[3],idx[4],idx[5],idx[6],idx[7],idx[8]} <=
                {4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0};
            end
        end
        else if(P == Sprintf2 && idx[8] < 9) 
        begin
            idx[8] <= idx[8] + 1;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] < 9) begin
            idx[7] <= idx[7] + 1;
            idx[8] <= 0;
            
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] < 9)begin
            idx[6] <= idx[6] + 1;
            idx[7] <= 0;
            idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] < 9)begin
            idx[5] <= idx[5] + 1;
            idx[6] <= 0;
            idx[7] <= 0;
            idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] == 9 && idx[4] < 9)begin
            idx[4] <= idx[4] + 1;
            idx[5] <= 0;
            idx[6] <= 0;
            idx[7] <= 0;
            idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] == 9 && idx[4] == 9 && idx[3] < 9)begin
           idx[3] <= idx[3] + 1;
           idx[4] <= 0;
           idx[5] <= 0;
           idx[6] <= 0;
           idx[7] <= 0;
           idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] == 9 && idx[4] == 9 && idx[3] == 9 && idx[2] < 9)begin
          idx[2] <= idx[2] + 1;
          idx[3] <= 0;
          idx[4] <= 0;
          idx[5] <= 0;
          idx[6] <= 0;
          idx[7] <= 0;
          idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] == 9 && idx[4] == 9 && idx[3] == 9 && idx[2] == 9 && idx[1] < 9)begin
            idx[1] <= idx[1] + 1;
            idx[2] <= 0;
            idx[3] <= 0;
            idx[4] <= 0;
            idx[5] <= 0;
            idx[6] <= 0;
            idx[7] <= 0;
            idx[8] <= 0;
        end
        else if(P == Sprintf2 && idx[8] == 9 && idx[7] == 9 && idx[6] == 9 && idx[5] == 9 && idx[4] == 9 && idx[3] == 9 && idx[2] == 9 && idx[1] == 9)begin
            idx[0] <= 0;
            idx[1] <= 0;
            idx[2] <= 0;
            idx[3] <= 0;
            idx[4] <= 0;
            idx[5] <= 0;
            idx[6] <= 0;
            idx[7] <= 0;
            idx[8] <= 0;
        end
        else idx[0] <= idx[0];
    end
    
    always @(posedge clk)begin
        if(P == Store) sprintf_done <= 0;
        else if(P == Sprintf) begin
            out0 <= "0" +idx[1];
            out1 <= "0" +idx[2];
            out2 <= "0" +idx[3];
            out3 <= "0" +idx[4];
            out4 <= "0" +idx[5];
            out5 <= "0" +idx[6];
            out6 <= "0" +idx[7];
            out7 <= "0" +idx[8];
            
            sprintf_done <= 1;
        end
        else out0 <= out0;
    end
    
    
    always @(posedge clk)begin
        if(P == Pre)begin
            h0 <= 32'h67452301;
            h1 <= 32'hefcdab89;
            h2 <= 32'h98badcfe;
            h3 <= 32'h10325476;
        end
        else if(P == For2part4 && for2_counter > 63)begin
            h0 <= h0 + a;
            h1 <= h1 + b;
            h2 <= h2 + c;
            h3 <= h3 + d;
        end
        else begin
            h0 <= h0;
            h1 <= h1;
            h2 <= h2;
            h3 <= h3;
        end
    end
    
    always @(posedge clk)begin
        if(P == Sprintf) pre_done <= 0;
        else if(P == Pre) begin
            {/*msg[0  ],msg[1  ],msg[2  ],msg[3  ],msg[4  ],msg[5  ],msg[6  ],msg[7  ],msg[8  ],*/msg[9  ],
            msg[10 ],msg[11 ],msg[12 ],msg[13 ],msg[14 ],msg[15 ],msg[16 ],msg[17 ],msg[18 ],msg[19 ],
            msg[20 ],msg[21 ],msg[22 ],msg[23 ],msg[24 ],msg[25 ],msg[26 ],msg[27 ],msg[28 ],msg[29 ],
            msg[30 ],msg[31 ],msg[32 ],msg[33 ],msg[34 ],msg[35 ],msg[36 ],msg[37 ],msg[38 ],msg[39 ],
            msg[40 ],msg[41 ],msg[42 ],msg[43 ],msg[44 ],msg[45 ],msg[46 ],msg[47 ],msg[48 ],msg[49 ],
            msg[50 ],msg[51 ],msg[52 ],msg[53 ],msg[54 ],msg[55 ]/*,msg[56 ]*/,msg[57 ],msg[58 ],msg[59 ],
            msg[60 ],msg[61 ],msg[62 ],msg[63 ],msg[64 ],msg[65 ],msg[66 ],msg[67 ],msg[68 ],msg[69 ],
            msg[70 ],msg[71 ],msg[72 ],msg[73 ],msg[74 ],msg[75 ],msg[76 ],msg[77 ],msg[78 ],msg[79 ],
            msg[80 ],msg[81 ],msg[82 ],msg[83 ],msg[84 ],msg[85 ],msg[86 ],msg[87 ],msg[88 ],msg[89 ],
            msg[90 ],msg[91 ],msg[92 ],msg[93 ],msg[94 ],msg[95 ],msg[96 ],msg[97 ],msg[98 ],msg[99 ],
            msg[100],msg[101],msg[102],msg[103],msg[104],msg[105],msg[106],msg[107],msg[108],msg[109],
            msg[110],msg[111],msg[112],msg[113],msg[114],msg[115],msg[116],msg[117],msg[118],msg[119]} <=
            {/*8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,*/8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,
            8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0/*,8'd0*/};
            
            msg[0] <= out0;
            msg[1] <= out1;
            msg[2] <= out2;
            msg[3] <= out3;
            msg[4] <= out4;
            msg[5] <= out5;
            msg[6] <= out6;
            msg[7] <= out7; 
            msg[8] <= 8'd128;
            msg[56] <= 8'd64;
            
            pre_done <= 1;
        end
        else msg[0] <= msg[0];
    end
    
    always @(posedge clk) begin
        if(P == Cmp) for1_done <= 0;
        else if(P == For1) begin
            w[0 ] <= {msg[3 ],msg[2 ],msg[1 ],msg[0 ]};
            w[1 ] <= {msg[7 ],msg[6 ],msg[5 ],msg[4 ]};
            w[2 ] <= {msg[11],msg[10],msg[9 ],msg[8 ]};
            w[3 ] <= {msg[15],msg[14],msg[13],msg[12]};
            w[4 ] <= {msg[19],msg[18],msg[17],msg[16]};
            w[5 ] <= {msg[23],msg[22],msg[21],msg[20]};
            w[6 ] <= {msg[27],msg[26],msg[25],msg[24]};
            w[7 ] <= {msg[31],msg[30],msg[29],msg[28]};
            w[8 ] <= {msg[35],msg[34],msg[33],msg[32]};
            w[9 ] <= {msg[39],msg[38],msg[37],msg[36]};
            w[10] <= {msg[43],msg[42],msg[41],msg[40]};
            w[11] <= {msg[47],msg[46],msg[45],msg[44]};
            w[12] <= {msg[51],msg[50],msg[49],msg[48]};
            w[13] <= {msg[55],msg[54],msg[53],msg[52]};
            w[14] <= {msg[59],msg[58],msg[57],msg[56]};
            w[15] <= {msg[63],msg[62],msg[61],msg[60]};
            for1_done <= 1;
        end
        else w[0] = w[0];
    end
    
    
    always @(posedge clk)begin
        if(~reset_n) for2_counter <= 0;
        else if(P == For2part4 && for2_counter < 127 && P_next == For2part1) for2_counter = for2_counter + 1;
        else if(P == Cmp) for2_counter <= 0;
        else for2_counter <= for2_counter; 
    end
    
    always @(posedge clk)begin
        if(P == For2part1 && for2_counter < 16) begin
            
           /* f1 <= b & c;
            f2 <= (~b) & d;*/
            
            //f <= f1 | f2;
            f <= (b & c) | ( (~b) & d);
            g <= for2_counter;
            
            
        end
        else if(P == For2part1 && for2_counter < 32) begin
            /*f1 <= d & b;
            f2 <= (~d) & c;
            g1 <= 5*for2_counter;*/
            
            f <= (d & b) | ((~d) & c);
            g <= (5*for2_counter+1)%16;
            
        end
        else if(P == For2part1 && for2_counter < 48) begin
            /*f1 <= b ^ c;
       
            g1 <= 3*for2_counter;*/
            
            f <= b ^ c ^ d;
            g <= (3*for2_counter+5)%16;
        end
        else if(P == For2part1 && for2_counter < 64) begin
            /*f2 <= b | (~d);
            g1 <= 7*for2_counter;*/
            
            f <= c ^ (b | (~d));
            g <= (7*for2_counter)%16;
            
        end
        else if(P == Store)begin
            f <= 0;g <= 0;
        end
        else begin
            f <= f;
        end
    
    end
    
    always @(posedge clk)begin
        if(P == For1) begin
            c <= h2;
            d <= h3;
        end
        else if(P == For2part2 && for2_counter < 16) begin
            d <= c;
            c <= b;
            rotatepart1 <= a + f + k[for2_counter] + w[g];
            temp <= d;
        end
        else if(P == For2part2 && for2_counter < 32) begin
            d <= c;
            c <= b;
            rotatepart1 <= a + f + k[for2_counter] + w[g];
            temp <= d;
        end
        else if(P == For2part2 && for2_counter < 48) begin
            d <= c;
            c <= b;
            rotatepart1 <= a + f + k[for2_counter] + w[g];
            temp <= d;
        end
        else if(P == For2part2 && for2_counter < 64) begin
            d <= c;
            c <= b;
            rotatepart1 <= a + f + k[for2_counter] + w[g];
            temp <= d;
        end
        else if(P == Store)begin
           rotatepart1 <= 0;
        end
        else rotatepart1 <= rotatepart1;
    end
    
    always @ (posedge clk) begin
        if(P == For2part3 && for2_counter < 16) begin
            rotatepart2 <= (((rotatepart1) << (r[for2_counter])) | ((rotatepart1) >> (32 - (r[for2_counter]))));
        end
        else if(P == For2part3 && for2_counter < 32) begin  
            rotatepart2 <= (((rotatepart1) << (r[for2_counter])) | ((rotatepart1) >> (32 - (r[for2_counter]))));
        end
        else if(P == For2part3 && for2_counter < 48) begin
            rotatepart2 <= (((rotatepart1) << (r[for2_counter])) | ((rotatepart1) >> (32 - (r[for2_counter]))));
        end
        else if(P == For2part3 && for2_counter < 64) begin
            rotatepart2 <= (((rotatepart1) << (r[for2_counter])) | ((rotatepart1) >> (32 - (r[for2_counter]))));
        end
        else if(P == Store)begin
           rotatepart2 <= 0;
        end
        else rotatepart2 <= rotatepart2;
    end
    
    
    
    always @(posedge clk) begin
        if(P == For1) begin
            a <= h0;
            b <= h1;
        end
        else if(P == For2part4 && for2_counter < 16) begin
            b <= b + rotatepart2;
            a <= temp;
        end
        else if(P == For2part4 && for2_counter < 32) begin
            b <= b + rotatepart2;
            a <= temp;
        end
        else if(P == For2part4 && for2_counter < 48) begin
            b <= b + rotatepart2;
            a <= temp;
        end
        else if(P == For2part4 && for2_counter < 65) begin
            b <= b + rotatepart2;
            a <= temp;
        end
        else a <= a;
    end
    
    assign for2_done = (for2_counter > 63);
    
    always @(posedge clk) begin
        if(P == Sprintf) store_done <= 0;
        else if(P == Store) begin
            hash[0 ] <= h0[7:0];
            hash[1 ] <= h0[15:8];
            hash[2 ] <= h0[23:16];
            hash[3 ] <= h0[31:24];
            hash[4 ] <= h1[7:0];
            hash[5 ] <= h1[15:8];
            hash[6 ] <= h1[23:16];
            hash[7 ] <= h1[31:24];
            hash[8 ] <= h2[7:0];
            hash[9 ] <= h2[15:8];
            hash[10] <= h2[23:16];
            hash[11] <= h2[31:24];
            hash[12] <= h3[7:0];
            hash[13] <= h3[15:8];
            hash[14] <= h3[23:16];
            hash[15] <= h3[31:24];
            store_done <= 1;
        end
        else hash[0 ] <= hash[0 ];
    end
    
    always @(posedge clk)begin
        if(hash[0 ] == password_hash[0:7] && hash[1] == password_hash[8:15] && hash[2] == password_hash[16:23] && hash[3] == password_hash[24:31]&& 
        hash[4 ] == password_hash[32:39] && hash[5] == password_hash[40:47] && hash[6] == password_hash[48:55] && hash[7] == password_hash[56:63]&&
        hash[8 ] == password_hash[64:71] && hash[9] == password_hash[72:79] && hash[10] == password_hash[80:87] && hash[11] == password_hash[88:95]&&
        hash[12] == password_hash[96:103] && hash[13] == password_hash[104:111] && hash[14] == password_hash[112:119] && hash[15] == password_hash[120:127])
        find <= 1;
        else find <= find;
    end

endmodule               

