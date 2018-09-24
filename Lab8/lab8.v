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


module lab8(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);


localparam [3:0] INIT = 0, Pre = 1, For1 = 2, For2part1 = 3, Store = 4, Cmp = 5, Show = 6,Wait = 7,Sprintf = 8,For2part2 = 9, For2part3 = 10,For2part4 = 11,Sprintf2 = 12;


reg [3:0] P,P_next;
wire btn_level, btn_pressed;
reg prev_btn_level;
reg [127:0] row_A = "WAIT FOR CRACKLE"; // Initialize the text of the first row. 
reg [127:0] row_B = "show a message.."; // Initialize the text of the second row.
reg [23:0] init_counter = 0;
reg pre_done = 0,for1_done = 0,store_done = 0;
reg find = 0;
wire find0;
wire find1;
wire find2;
wire find3;
wire find4;
wire find5;
wire find6;
wire find7;
wire find8;
wire find9;
wire find10;
wire find11;
wire find12;
wire find13;
wire find14;
wire find15;
wire find16;
wire find17;
wire find18;
wire find19;
wire for2_done;

wire [7:0] pattern[0:159];

reg [7:0]out0,out1,out2,out3,out4,out5,out6,out7,out8;
reg outputrdy = 0;
//CHUNK1

reg [7:0] msg[0:119];

reg [7:0] hash[0:15];
reg [7:0] hash2[0:15];
reg [7:0] hash3[0:15];
reg [7:0] hash4[0:15];

reg [0:127] password_hash = 128'hE9982EC5CA981BD365603623CF4B2277;

reg [31:0] record_divider = 32'd0;
reg [3:0] record[0:5];
reg btn_flag = 1'd0;
wire btn_flagwire;
wire [4:0] num0 = 5'd0 ;
wire [4:0] num1 = 5'd1 ;
wire [4:0] num2 = 5'd2 ;
wire [4:0] num3 = 5'd3 ;
wire [4:0] num4 = 5'd4 ;
wire [4:0] num5 = 5'd5 ;
wire [4:0] num6 = 5'd6 ;
wire [4:0] num7 = 5'd7 ;
wire [4:0] num8 = 5'd8 ;
wire [4:0] num9 = 5'd9 ;
wire [4:0] num10= 5'd10;
wire [4:0] num11= 5'd11;
wire [4:0] num12= 5'd12;
wire [4:0] num13= 5'd13;
wire [4:0] num14= 5'd14;
wire [4:0] num15= 5'd15;
wire [4:0] num16= 5'd16;
wire [4:0] num17= 5'd17;
wire [4:0] num18= 5'd18;
wire [4:0] num19= 5'd19;


/*assign num0  = 5'd0 ;
assign num1  = 5'd1 ;
assign num2  = 5'd2 ;
assign num3  = 5'd3 ;
assign num4  = 5'd4 ;
assign num5  = 5'd5 ;
assign num6  = 5'd6 ;
assign num7  = 5'd7 ;
assign num8  = 5'd8 ;
assign num9  = 5'd9 ;
assign num10 = 5'd10;
assign num11 = 5'd11;
assign num12 = 5'd12;
assign num13 = 5'd13;
assign num14 = 5'd14;
assign num15 = 5'd15;
assign num16 = 5'd16;
assign num17 = 5'd17;
assign num18 = 5'd18;
assign num19 = 5'd19;*/


//assign btn_flagwire = (btn_flag == 1);

always @(*)begin
    find = (find0 || find1 || find2 || find3 || find4 || find5 || find6 ||
              find7 || find8 || find9 || find10 || find11 || find12 || find13 ||
              find14 || find15 || find16 || find17 || find18 || find19);
    if(find) find = find;
end
// turn off all the LEDs
assign usr_led = find6;

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

pawd_crack blk0(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num0),
    .btn_pressed(btn_pressed),
    .find(find0),
    .out0(pattern[0]),
    .out1(pattern[1]),
    .out2(pattern[2]),
    .out3(pattern[3]),
    .out4(pattern[4]),
    .out5(pattern[5]),
    .out6(pattern[6]),
    .out7(pattern[7])
);

pawd_crack blk1(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num1),
    .btn_pressed(btn_pressed),
    .find(find1),
    .out0(pattern[8]),
    .out1(pattern[9]),
    .out2(pattern[10]),
    .out3(pattern[11]),
    .out4(pattern[12]),
    .out5(pattern[13]),
    .out6(pattern[14]),
    .out7(pattern[15])
);
pawd_crack blk2(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num2),
    .btn_pressed(btn_pressed),
    .find(find2),
    .out0(pattern[16]),
    .out1(pattern[17]),
    .out2(pattern[18]),
    .out3(pattern[19]),
    .out4(pattern[20]),
    .out5(pattern[21]),
    .out6(pattern[22]),
    .out7(pattern[23])
);

pawd_crack blk3(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num3),
    .btn_pressed(btn_pressed),
    .find(find3),
    .out0(pattern[24]),
    .out1(pattern[25]),
    .out2(pattern[26]),
    .out3(pattern[27]),
    .out4(pattern[28]),
    .out5(pattern[29]),
    .out6(pattern[30]),
    .out7(pattern[31])
);
pawd_crack blk4(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num4),
    .btn_pressed(btn_pressed),
    .find(find4),
    .out0(pattern[32]),
    .out1(pattern[33]),
    .out2(pattern[34]),
    .out3(pattern[35]),
    .out4(pattern[36]),
    .out5(pattern[37]),
    .out6(pattern[38]),
    .out7(pattern[39])
);
pawd_crack blk5(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num5),
    .btn_pressed(btn_pressed),
    .find(find5),
    .out0(pattern[40 ]),
    .out1(pattern[41 ]),
    .out2(pattern[42 ]),
    .out3(pattern[43 ]),
    .out4(pattern[44 ]),
    .out5(pattern[45 ]),
    .out6(pattern[46 ]),
    .out7(pattern[47 ])
);
pawd_crack blk6(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num6),
    .btn_pressed(btn_pressed),
    .find(find6),
    .out0(pattern[48 ]),
    .out1(pattern[49 ]),
    .out2(pattern[50 ]),
    .out3(pattern[51 ]),
    .out4(pattern[52 ]),
    .out5(pattern[53 ]),
    .out6(pattern[54 ]),
    .out7(pattern[55 ])
);
pawd_crack blk7(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num7),
    .btn_pressed(btn_pressed),
    .find(find7),
    .out0(pattern[56 ]),
    .out1(pattern[57 ]),
    .out2(pattern[58 ]),
    .out3(pattern[59 ]),
    .out4(pattern[60 ]),
    .out5(pattern[61 ]),
    .out6(pattern[62 ]),
    .out7(pattern[63 ])
);
pawd_crack blk8(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num8),
    .btn_pressed(btn_pressed),
    .find(find8),
    .out0(pattern[64 ]),
    .out1(pattern[65 ]),
    .out2(pattern[66 ]),
    .out3(pattern[67 ]),
    .out4(pattern[68 ]),
    .out5(pattern[69 ]),
    .out6(pattern[70 ]),
    .out7(pattern[71 ])
);
pawd_crack blk9(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num9),
    .btn_pressed(btn_pressed),
    .find(find9),
    .out0(pattern[72 ]),
    .out1(pattern[73 ]),
    .out2(pattern[74 ]),
    .out3(pattern[75 ]),
    .out4(pattern[76 ]),
    .out5(pattern[77 ]),
    .out6(pattern[78 ]),
    .out7(pattern[79 ])
);
pawd_crack blk10(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num10),
    .btn_pressed(btn_pressed),
    .find(find10),
    .out0(pattern[80 ]),
    .out1(pattern[81 ]),
    .out2(pattern[82 ]),
    .out3(pattern[83 ]),
    .out4(pattern[84 ]),
    .out5(pattern[85 ]),
    .out6(pattern[86 ]),
    .out7(pattern[87 ])
);
pawd_crack blk11(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num11),
    .btn_pressed(btn_pressed),
    .find(find11),
   .out0(pattern[88 ]),
    .out1(pattern[89 ]),
    .out2(pattern[90 ]),
    .out3(pattern[91 ]),
    .out4(pattern[92 ]),
    .out5(pattern[93 ]),
    .out6(pattern[94 ]),
    .out7(pattern[95 ])
);
pawd_crack blk12(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num12),
    .btn_pressed(btn_pressed),
    .find(find12),
    .out0(pattern[96 ]),
    .out1(pattern[97 ]),
    .out2(pattern[98 ]),
    .out3(pattern[99 ]),
    .out4(pattern[100]),
    .out5(pattern[101]),
    .out6(pattern[102]),
    .out7(pattern[103])
);
pawd_crack blk13(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num13),
    .btn_pressed(btn_pressed),
    .find(find13),
    .out0(pattern[104]),
    .out1(pattern[105]),
    .out2(pattern[106]),
    .out3(pattern[107]),
    .out4(pattern[108]),
    .out5(pattern[109]),
    .out6(pattern[110]),
    .out7(pattern[111])
);
pawd_crack blk14(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num14),
    .btn_pressed(btn_pressed),
    .find(find14),
    .out0(pattern[112]),
    .out1(pattern[113]),
    .out2(pattern[114]),
    .out3(pattern[115]),
    .out4(pattern[116]),
    .out5(pattern[117]),
    .out6(pattern[118]),
    .out7(pattern[119])
);
pawd_crack blk15(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num15),
    .btn_pressed(btn_pressed),
    .find(find15),
    .out0(pattern[120]),
    .out1(pattern[121]),
    .out2(pattern[122]),
    .out3(pattern[123]),
    .out4(pattern[124]),
    .out5(pattern[125]),
    .out6(pattern[126]),
    .out7(pattern[127])
);
pawd_crack blk16(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num16),
    .btn_pressed(btn_pressed),
    .find(find16),
    .out0(pattern[128]),
    .out1(pattern[129]),
    .out2(pattern[130]),
    .out3(pattern[131]),
    .out4(pattern[132]),
    .out5(pattern[133]),
    .out6(pattern[134]),
    .out7(pattern[135])
);
pawd_crack blk17(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num17),
    .btn_pressed(btn_pressed),
    .find(find17),
    .out0(pattern[136]),
    .out1(pattern[137]),
    .out2(pattern[138]),
    .out3(pattern[139]),
    .out4(pattern[140]),
    .out5(pattern[141]),
    .out6(pattern[142]),
    .out7(pattern[143])
);
pawd_crack blk18(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num18),
    .btn_pressed(btn_pressed),
    .find(find18),
    .out0(pattern[144]),
    .out1(pattern[145]),
    .out2(pattern[146]),
    .out3(pattern[147]),
    .out4(pattern[148]),
    .out5(pattern[149]),
    .out6(pattern[150]),
    .out7(pattern[151])
);
pawd_crack blk19(
    .clk(clk),
    .reset_n(reset_n),
    .password_hash(password_hash),
    .blocknum(num19),
    .btn_pressed(btn_pressed),
    .find(find19),
    .out0(pattern[152]),
    .out1(pattern[153]),
    .out2(pattern[154]),
    .out3(pattern[155]),
    .out4(pattern[156]),
    .out5(pattern[157]),
    .out6(pattern[158]),
    .out7(pattern[159])
);

always @(*)begin
    if(btn_pressed) btn_flag = 1;
    else btn_flag = btn_flag;
end

always @(posedge clk) begin
    if(~reset_n) record_divider <= 32'd0;
    else if(P_next == Show) record_divider <= record_divider;
    else if(record_divider == 100001) record_divider <= 0;
    else if(btn_flag) record_divider <= record_divider + 1;
    else record_divider <= record_divider;
end

/*always @(posedge clk) begin
    if(~reset_n) record <= 32'd0;
    else if(P_next == Show) record <= record;
    else if(record_divider == 100000) record <= record + 1;
    else record <= record;
end*/

always @(posedge clk)begin
    if((record_divider == 100000) && record[5] < 9) 
    begin
        record[5] <= record[5] + 1;
    end
    else if((record_divider == 100000) && record[5] == 9 && record[4] < 9) begin
        record[4] <= record[4] + 1;
        record[5] <= 0;
    end
    else if((record_divider == 100000) && record[5] == 9 && record[4] == 9 && record[3] < 9)begin
        record[3] <= record[3] + 1;
        record[4] <= 0;
        record[5] <= 0;
    end
    else if((record_divider == 100000) && record[5] == 9 && record[4] == 9 && record[3] == 9 && record[2] < 9)begin
        record[2] <= record[2] + 1;
        record[3] <= 0;
        record[4] <= 0;
        record[5] <= 0;
    end
    else if((record_divider == 100000) && record[5] == 9 && record[4] == 9 && record[3] == 9 && record[2] == 9 && record[1] < 9)begin
        record[1] <= record[1] + 1;
        record[2] <= 0;
        record[3] <= 0;
        record[4] <= 0;
        record[5] <= 0;
    end
    else if((record_divider == 100000) && record[5] == 9 && record[4] == 9 && record[3] == 9 && record[2] == 9 && record[1] == 9 && record[0] < 9)begin
       record[0] <= record[0] + 1;
       record[1] <= 0;
       record[2] <= 0;
       record[3] <= 0;
       record[4] <= 0;
       record[5] <= 0;
    end
    else record[0] <= record[0];
end





always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1:0;
//assign btn_pressed = (P_next == Wait || P == Wait);


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
            if(btn_pressed)  P_next = Cmp;
            else P_next = Wait;
        Cmp:
            if(find) P_next = Show;
            else P_next = Cmp;
        Show:
            P_next = Show;
    endcase
end

always @(posedge clk)begin
    if(P == Show && find0 == 1) begin
        out0 <= pattern[0];
        out1 <= pattern[1];
        out2 <= pattern[2];
        out3 <= pattern[3];
        out4 <= pattern[4];
        out5 <= pattern[5];
        out6 <= pattern[6];
        out7 <= pattern[7];
    outputrdy <= 1; end
    else if(P == Show && find1 == 1) begin
        out0 <= pattern[8  ];
        out1 <= pattern[9  ];
        out2 <= pattern[10 ];
        out3 <= pattern[11 ];
        out4 <= pattern[12 ];
        out5 <= pattern[13 ];
        out6 <= pattern[14 ];
        out7 <= pattern[15 ];
    outputrdy <= 1; end
        else if(P == Show && find2 == 1) begin
        out0 <= pattern[16 ];
        out1 <= pattern[17 ];
        out2 <= pattern[18 ];
        out3 <= pattern[19 ];
        out4 <= pattern[20 ];
        out5 <= pattern[21 ];
        out6 <= pattern[22 ];
        out7 <= pattern[23 ];
        outputrdy <= 1; end
        else if(P == Show && find3 == 1) begin
        out0 <= pattern[24 ];
        out1 <= pattern[25 ];
        out2 <= pattern[26 ];
        out3 <= pattern[27 ];
        out4 <= pattern[28 ];
        out5 <= pattern[29 ];
        out6 <= pattern[30 ];
        out7 <= pattern[31 ];
        outputrdy <= 1; end
        else if(P == Show && find4 == 1) begin
        out0 <= pattern[32 ];
        out1 <= pattern[33 ];
        out2 <= pattern[34 ];
        out3 <= pattern[35 ];
        out4 <= pattern[36 ];
        out5 <= pattern[37 ];
        out6 <= pattern[38 ];
        out7 <= pattern[39 ];
        outputrdy <= 1; end
        else if(P == Show && find5 == 1) begin
        out0 <= pattern[40 ];
        out1 <= pattern[41 ];
        out2 <= pattern[42 ];
        out3 <= pattern[43 ];
        out4 <= pattern[44 ];
        out5 <= pattern[45 ];
        out6 <= pattern[46 ];
        out7 <= pattern[47 ];
        outputrdy <= 1; end
        else if(P == Show && find6 == 1) begin
       out0 <= pattern[48 ];
        out1 <= pattern[49 ];
        out2 <= pattern[50 ];
        out3 <= pattern[51 ];
        out4 <= pattern[52 ];
        out5 <= pattern[53 ];
        out6 <= pattern[54 ];
        out7 <= pattern[55 ];
        outputrdy <= 1; end
        else if(P == Show && find7 == 1) begin
        out0 <= pattern[56 ];
        out1 <= pattern[57 ];
        out2 <= pattern[58 ];
        out3 <= pattern[59 ];
        out4 <= pattern[60 ];
        out5 <= pattern[61 ];
        out6 <= pattern[62 ];
        out7 <= pattern[63 ];
        outputrdy <= 1; end
        else if(P == Show && find8 == 1) begin
        out0 <= pattern[64 ];
        out1 <= pattern[65 ];
        out2 <= pattern[66 ];
        out3 <= pattern[67 ];
        out4 <= pattern[68 ];
        out5 <= pattern[69 ];
        out6 <= pattern[70 ];
        out7 <= pattern[71 ];
        outputrdy <= 1; end
        else if(P == Show && find9 == 1) begin
        out0 <= pattern[72 ];
        out1 <= pattern[73 ];
        out2 <= pattern[74 ];
        out3 <= pattern[75 ];
        out4 <= pattern[76 ];
        out5 <= pattern[77 ];
        out6 <= pattern[78 ];
        out7 <= pattern[79 ];
        outputrdy <= 1; end
        else if(P == Show && find10 == 1) begin
        out0 <= pattern[80 ];
        out1 <= pattern[81 ];
        out2 <= pattern[82 ];
        out3 <= pattern[83 ];
        out4 <= pattern[84 ];
        out5 <= pattern[85 ];
        out6 <= pattern[86 ];
        out7 <= pattern[87 ];
        outputrdy <= 1; end
        else if(P == Show && find11 == 1) begin
        out0 <= pattern[88 ];
        out1 <= pattern[89 ];
        out2 <= pattern[90 ];
        out3 <= pattern[91 ];
        out4 <= pattern[92 ];
        out5 <= pattern[93 ];
        out6 <= pattern[94 ];
        out7 <= pattern[95 ];
        outputrdy <= 1; end
        else if(P == Show && find12 == 1) begin
        out0 <= pattern[96 ];
        out1 <= pattern[97 ];
        out2 <= pattern[98 ];
        out3 <= pattern[99 ];
        out4 <= pattern[100];
        out5 <= pattern[101];
        out6 <= pattern[102];
        out7 <= pattern[103];
        outputrdy <= 1; end
        else if(P == Show && find13 == 1) begin
        out0 <= pattern[104];
        out1 <= pattern[105];
        out2 <= pattern[106];
        out3 <= pattern[107];
        out4 <= pattern[108];
        out5 <= pattern[109];
        out6 <= pattern[110];
        out7 <= pattern[111];
        outputrdy <= 1; end
        else if(P == Show && find14 == 1) begin
        out0 <= pattern[112];
        out1 <= pattern[113];
        out2 <= pattern[114];
        out3 <= pattern[115];
        out4 <= pattern[116];
        out5 <= pattern[117];
        out6 <= pattern[118];
        out7 <= pattern[119];
        outputrdy <= 1; end
        else if(P == Show && find15 == 1) begin
        out0 <= pattern[120];
        out1 <= pattern[121];
        out2 <= pattern[122];
        out3 <= pattern[123];
        out4 <= pattern[124];
        out5 <= pattern[125];
        out6 <= pattern[126];
        out7 <= pattern[127];
        outputrdy <= 1; end
        else if(P == Show && find16 == 1) begin
        out0 <= pattern[128];
        out1 <= pattern[129];
        out2 <= pattern[130];
        out3 <= pattern[131];
        out4 <= pattern[132];
        out5 <= pattern[133];
        out6 <= pattern[134];
        out7 <= pattern[135];
        outputrdy <= 1; end
        else if(P == Show && find17 == 1) begin
        out0 <= pattern[136];
        out1 <= pattern[137];
        out2 <= pattern[138];
        out3 <= pattern[139];
        out4 <= pattern[140];
        out5 <= pattern[141];
        out6 <= pattern[142];
        out7 <= pattern[143];
        outputrdy <= 1; end
        else if(P == Show && find18 == 1) begin
        out0 <= pattern[144];
        out1 <= pattern[145];
        out2 <= pattern[146];
        out3 <= pattern[147];
        out4 <= pattern[148];
        out5 <= pattern[149];
        out6 <= pattern[150];
        out7 <= pattern[151];
        outputrdy <= 1; end
        else if(P == Show && find19 == 1) begin
        out0 <= pattern[152];
        out1 <= pattern[153];
        out2 <= pattern[154];
        out3 <= pattern[155];
        out4 <= pattern[156];
        out5 <= pattern[157];
        out6 <= pattern[158];
        out7 <= pattern[159];
        outputrdy <= 1; end
        else outputrdy <= outputrdy;            
end


always @(posedge clk) begin
  if (~reset_n) begin
    // Initialize the text when the user hit the reset button
    row_A = "Press BTN3 to   ";
    row_B = {"                "};
  end else if (P == Show && outputrdy == 1) begin
    row_A <= {"Passwd: ",out0,out1,out2,out3,out4,out5,out6,out7};
    //row_A <= {"Passwd: ",pattern[0],pattern[1],pattern[2],pattern[3],pattern[4],pattern[5],pattern[6],pattern[7]};
    row_B = {"Time:  ","0"+record[0],"0"+record[1],"0"+record[2],"0"+record[3],"0"+record[4],"0"+record[5]," ms"};
  end 
end


endmodule
