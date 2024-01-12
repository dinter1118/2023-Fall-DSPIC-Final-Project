`timescale 1ns / 1ps
module FIR #
(
    parameter inbit = 11,		//1 bit sign +2 bit integer + 8 bit wordlength 
    parameter outbit = 23,		
    parameter n=32
)
(
    input rst,
    input clk,
    input wire signed [inbit-1:0] infix,
    output reg signed [outbit-1:0] outfix
);

//wire signed [inbit-1 :0] tap [0:n-1] ;	// 1 2 -1 -3 0 4 3 -5 -6 5 12 -2 -22 -9 47 103 103 47 -9 -22 -2 12 5 -6 -5 3 4 0 -3 -1 2 1
reg signed [outbit-1:0] mul [0:31];
reg signed [outbit-1:0] add [0:30];

/*assign tap[0] = 11'd1;
assign tap[1] = 11'd2;
assign tap[2] = -11'd1;
assign tap[3] = -11'd3;
assign tap[4] = 11'd0;
assign tap[5] = 11'd4;
assign tap[6] = 11'd3;
assign tap[7] = -11'd5;
assign tap[8] = -11'd6;
assign tap[9] = 11'd5;
assign tap[10] = 11'd12;
assign tap[11] = -11'd2;
assign tap[12] = -11'd22;
assign tap[13] = -11'd9;
assign tap[14] = 11'd47;
assign tap[15] = 11'd103;
assign tap[16] = 11'd103;
assign tap[17] = 11'd47;
assign tap[18] = -11'd9;
assign tap[19] = -11'd22;
assign tap[20] = -11'd2;
assign tap[21]= 11'd12;
assign tap[22] = 11'd5;
assign tap[23] = -11'd6;
assign tap[24] = -11'd5;
assign tap[25] = 11'd3;
assign tap[26] = 11'd4;
assign tap[27] = 11'd0;
assign tap[28] = -11'd3;
assign tap[29] = -11'd1;
assign tap[30] = 11'd2;
assign tap[31] = 11'd1;*/
integer  i;

wire signed [outbit-1:0] sh1,sh2,sh3,sh5;
wire signed [outbit-1:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14;  

assign sh1 = infix<<1;
assign sh2 = infix<<2;
assign sh3 = infix<<3;
assign sh5 = infix<<5;
		/*mul[0] <= infix;										//1
        mul[1] <= sh1;											//2
		mul[2] <= -infix;										//-1
		mul[3] <= -(sh1+infix);									//-3
		mul[4] <= (sh1);										//4
		mul[5] <= sh1+infix; 									//3
		mul[6] <= -(sh2 +infix) ; 								//-5
		mul[7] <= -(sh2 +sh1); 									//-6
		mul[8] <= sh2+infix; 									//5
		mul[9] <= sh3 +sh2;										//12
		mul[10] <= -(sh1);										//-2
		mul[11] <= (infix<<4)+(sh2+sh1);						//-22
		mul[12] <= -(sh3+infix);								//-9
		mul[13] <= (sh5+sh3)+(sh2+sh1 +infix); 					//47
		mul[14] <= (infix<<6)+(sh5)+(sh2+sh1 +infix); 			//103*/
assign w0 = infix;//1
assign w1 = sh1;//2
assign w2 = -infix;//-1
assign w3 = -sh1-infix;	//-3
//0
assign w4 = sh2; //4
assign w5 = sh1+infix; //3
assign w6 = -sh2-infix;	//-5
assign w7 = -sh2-sh1;	//-6
assign w8 =sh2+infix;	//5
assign w9 = sh3+sh2;	//12
assign w10 = -sh1;		//-2
assign w11 = -(infix<<4) - (sh2 + sh1);	//-22
assign w12 = -sh3-infix;			//-9
assign w13 = (sh5)+(sh3+sh2)+(sh1+infix);		//47
assign w14 = (infix<<6)+(sh5+sh2)+(sh1+infix);		//103
always @(posedge clk) begin
    if (rst) begin
		outfix <= 0;
    end else begin 
		outfix <= mul[0] +add[0];
	end
end
always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<32;i=i+1)
			mul[i] <= 0;
    end else begin 
        mul[0] <= w0;
        mul[1] <= w1;
		mul[2] <= w2;
		mul[3] <= w3;
		mul[4] <=0;
		mul[5] <= w4;
		mul[6] <= w5;
		mul[7] <= w6;
		mul[8] <= w7;
		mul[9] <= w8;
		mul[10] <= w9;
		mul[11] <= w10;
		mul[12] <= w11;
		mul[13] <= w12;
		mul[14] <= w13;
		mul[15] <= w14;
		mul[16] <= w14;
		mul[17] <= w13;
		mul[18] <= w12;
		mul[19] <= w11;
		mul[20] <= w10;
		mul[21] <= w9;
		mul[22] <= w8;
		mul[23] <= w7;
		mul[24] <= w6;
		mul[25] <= w5;
		mul[26] <= w4;
		mul[27] <= 0;
		mul[28] <= w3;
		mul[29] <= w2;
		mul[30] <= w1;
		mul[31] <= w0;
    end
end
always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<31;i=i+1)
			add[i] <= 0;
    end else begin 
        add[0] <= mul[1]+add[1];
        add[1] <= mul[2]+add[2];
		add[2] <= mul[3]+add[3];
		add[3] <= add[4];
		add[4] <= mul[5]+add[5];
		add[5] <= mul[6]+add[6];
		add[6] <= mul[7]+add[7];
		add[7] <= mul[8]+add[8];
		add[8] <= mul[9]+add[9];
		add[9] <= mul[10]+add[10];
		add[10] <= mul[11]+add[11];
		add[11] <= mul[12]+add[12];
		add[12] <= mul[13]+add[13];
		add[13] <= mul[14]+add[14];
		add[14] <= mul[15]+add[15];
		add[15] <= mul[16]+add[16];
		add[16] <= mul[17]+add[17];
		add[17] <= mul[18]+add[18];
		add[18] <= mul[19]+add[19];
		add[19] <= mul[20]+add[20];
		add[20] <= mul[21]+add[21];
		add[21] <= mul[22]+add[22];
		add[22] <= mul[23]+add[23];
		add[23] <= mul[24]+add[24];
		add[24] <= mul[25]+add[25];
		add[25] <= mul[26]+add[26];
		add[26] <= add[27];
		add[27] <= mul[28]+add[28];
		add[28] <= mul[29]+add[29];
		add[29] <= mul[30]+add[30];
		add[30] <= mul[31];
    end
end

    
endmodule