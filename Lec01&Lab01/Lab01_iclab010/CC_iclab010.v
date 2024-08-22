module CC(
  in_s0,
  in_s1,
  in_s2,
  in_s3,
  in_s4,
  in_s5,
  in_s6,
  opt,
  a,
  b,
  s_id0,
  s_id1,
  s_id2,
  s_id3,
  s_id4,
  s_id5,
  s_id6,
  out

);
input [3:0]in_s0;
input [3:0]in_s1;
input [3:0]in_s2;
input [3:0]in_s3;
input [3:0]in_s4;
input [3:0]in_s5;
input [3:0]in_s6;
input [2:0]opt;
input [1:0]a;
input [2:0]b;
output [2:0] s_id0;
output [2:0] s_id1;
output [2:0] s_id2;
output [2:0] s_id3;
output [2:0] s_id4;
output [2:0] s_id5;
output [2:0] s_id6;
output [2:0] out;

//===========================================
//             reg & wire
//===========================================

//===========================================
//          sort
//===========================================
wire [6:0] in_id0;
wire [6:0] in_id1;
wire [6:0] in_id2;
wire [6:0] in_id3;
wire [6:0] in_id4;
wire [6:0] in_id5;
wire [6:0] in_id6;

assign in_id0 = opt[0]? {~in_s0[3], in_s0[2:0], 3'd0}:{in_s0, 3'd0};
assign in_id1 = opt[0]? {~in_s1[3], in_s1[2:0], 3'd1}:{in_s1, 3'd1};
assign in_id2 = opt[0]? {~in_s2[3], in_s2[2:0], 3'd2}:{in_s2, 3'd2};
assign in_id3 = opt[0]? {~in_s3[3], in_s3[2:0], 3'd3}:{in_s3, 3'd3};
assign in_id4 = opt[0]? {~in_s4[3], in_s4[2:0], 3'd4}:{in_s4, 3'd4};
assign in_id5 = opt[0]? {~in_s5[3], in_s5[2:0], 3'd5}:{in_s5, 3'd5};
assign in_id6 = opt[0]? {~in_s6[3], in_s6[2:0], 3'd6}:{in_s6, 3'd6};

wire [6:0] t0_0;
wire [6:0] t0_1;
wire [6:0] t0_2;
wire [6:0] t0_3;
wire [6:0] t0_4;
wire [6:0] t0_5;
wire [6:0] t0_6;

wire [6:0] t1_0;
wire [6:0] t1_1;
wire [6:0] t1_2;
wire [6:0] t1_3;
wire [6:0] t1_4;
wire [6:0] t1_5;
wire [6:0] t1_6;

wire [6:0] t2_0;
wire [6:0] t2_1;
wire [6:0] t2_2;
wire [6:0] t2_3;
wire [6:0] t2_4;
wire [6:0] t2_5;
wire [6:0] t2_6;

wire [6:0] t3_0;
wire [6:0] t3_1;
wire [6:0] t3_2;
wire [6:0] t3_3;
wire [6:0] t3_4;
wire [6:0] t3_5;
wire [6:0] t3_6;

wire [6:0] t4_0;
wire [6:0] t4_1;
wire [6:0] t4_2;
wire [6:0] t4_3;
wire [6:0] t4_4;
wire [6:0] t4_5;
wire [6:0] t4_6;

wire [6:0] t5_0;
wire [6:0] t5_1;
wire [6:0] t5_2;
wire [6:0] t5_3;
wire [6:0] t5_4;
wire [6:0] t5_5;
wire [6:0] t5_6;

wire [6:0] t6_0;
wire [6:0] t6_1;
wire [6:0] t6_2;
wire [6:0] t6_3;
wire [6:0] t6_4;
wire [6:0] t6_5;
wire [6:0] t6_6;

//sort0
assign t0_0 = opt[1]?  (in_id0[6:3] >= in_id1[6:3]? in_id0:in_id1):(in_id0 < in_id1? in_id0:in_id1);
assign t0_1 = opt[1]?  (in_id0[6:3] >= in_id1[6:3]? in_id1:in_id0):(in_id0 < in_id1? in_id1:in_id0);
assign t0_2 = opt[1]?  (in_id2[6:3] >= in_id3[6:3]? in_id2:in_id3):(in_id2 < in_id3? in_id2:in_id3);
assign t0_3 = opt[1]?  (in_id2[6:3] >= in_id3[6:3]? in_id3:in_id2):(in_id2 < in_id3? in_id3:in_id2);
assign t0_4 = opt[1]?  (in_id4[6:3] >= in_id5[6:3]? in_id4:in_id5):(in_id4 < in_id5? in_id4:in_id5);
assign t0_5 = opt[1]?  (in_id4[6:3] >= in_id5[6:3]? in_id5:in_id4):(in_id4 < in_id5? in_id5:in_id4);
assign t0_6 = in_id6;

//sort1
assign t1_0 = t0_0;
assign t1_1 = opt[1]? (t0_1[6:3] >= t0_2[6:3]? t0_1:t0_2):(t0_1 < t0_2? t0_1:t0_2);
assign t1_2 = opt[1]? (t0_1[6:3] >= t0_2[6:3]? t0_2:t0_1):(t0_1 < t0_2? t0_2:t0_1);
assign t1_3 = opt[1]? (t0_3[6:3] >= t0_4[6:3]? t0_3:t0_4):(t0_3 < t0_4? t0_3:t0_4);
assign t1_4 = opt[1]? (t0_3[6:3] >= t0_4[6:3]? t0_4:t0_3):(t0_3 < t0_4? t0_4:t0_3);
assign t1_5 = opt[1]? (t0_5[6:3] >= t0_6[6:3]? t0_5:t0_6):(t0_5 < t0_6? t0_5:t0_6);
assign t1_6 = opt[1]? (t0_5[6:3] >= t0_6[6:3]? t0_6:t0_5):(t0_5 < t0_6? t0_6:t0_5);

//sort2
assign t2_0 = opt[1]? (t1_0[6:3] >= t1_1[6:3]? t1_0:t1_1):(t1_0 < t1_1? t1_0:t1_1);
assign t2_1 = opt[1]? (t1_0[6:3] >= t1_1[6:3]? t1_1:t1_0):(t1_0 < t1_1? t1_1:t1_0);
assign t2_2 = opt[1]? (t1_2[6:3] >= t1_3[6:3]? t1_2:t1_3):(t1_2 < t1_3? t1_2:t1_3);
assign t2_3 = opt[1]? (t1_2[6:3] >= t1_3[6:3]? t1_3:t1_2):(t1_2 < t1_3? t1_3:t1_2);
assign t2_4 = opt[1]? (t1_4[6:3] >= t1_5[6:3]? t1_4:t1_5):(t1_4 < t1_5? t1_4:t1_5);
assign t2_5 = opt[1]? (t1_4[6:3] >= t1_5[6:3]? t1_5:t1_4):(t1_4 < t1_5? t1_5:t1_4);
assign t2_6 = t1_6;

//sort3
assign t3_0 = t2_0;
assign t3_1 = opt[1]? (t2_1[6:3] >= t2_2[6:3]? t2_1:t2_2):(t2_1 < t2_2? t2_1:t2_2);
assign t3_2 = opt[1]? (t2_1[6:3] >= t2_2[6:3]? t2_2:t2_1):(t2_1 < t2_2? t2_2:t2_1);
assign t3_3 = opt[1]? (t2_3[6:3] >= t2_4[6:3]? t2_3:t2_4):(t2_3 < t2_4? t2_3:t2_4);
assign t3_4 = opt[1]? (t2_3[6:3] >= t2_4[6:3]? t2_4:t2_3):(t2_3 < t2_4? t2_4:t2_3);
assign t3_5 = opt[1]? (t2_5[6:3] >= t2_6[6:3]? t2_5:t2_6):(t2_5 < t2_6? t2_5:t2_6);
assign t3_6 = opt[1]? (t2_5[6:3] >= t2_6[6:3]? t2_6:t2_5):(t2_5 < t2_6? t2_6:t2_5);

//sort4
assign t4_0 = opt[1]? (t3_0[6:3] >= t3_1[6:3]? t3_0:t3_1):(t3_0 < t3_1? t3_0:t3_1);
assign t4_1 = opt[1]? (t3_0[6:3] >= t3_1[6:3]? t3_1:t3_0):(t3_0 < t3_1? t3_1:t3_0);
assign t4_2 = opt[1]? (t3_2[6:3] >= t3_3[6:3]? t3_2:t3_3):(t3_2 < t3_3? t3_2:t3_3);
assign t4_3 = opt[1]? (t3_2[6:3] >= t3_3[6:3]? t3_3:t3_2):(t3_2 < t3_3? t3_3:t3_2);
assign t4_4 = opt[1]? (t3_4[6:3] >= t3_5[6:3]? t3_4:t3_5):(t3_4 < t3_5? t3_4:t3_5);
assign t4_5 = opt[1]? (t3_4[6:3] >= t3_5[6:3]? t3_5:t3_4):(t3_4 < t3_5? t3_5:t3_4);
assign t4_6 = t3_6;

//sort5
assign t5_0 = t4_0;
assign t5_1 = opt[1]? (t4_1[6:3] >= t4_2[6:3]? t4_1:t4_2):(t4_1 < t4_2? t4_1:t4_2);
assign t5_2 = opt[1]? (t4_1[6:3] >= t4_2[6:3]? t4_2:t4_1):(t4_1 < t4_2? t4_2:t4_1);
assign t5_3 = opt[1]? (t4_3[6:3] >= t4_4[6:3]? t4_3:t4_4):(t4_3 < t4_4? t4_3:t4_4);
assign t5_4 = opt[1]? (t4_3[6:3] >= t4_4[6:3]? t4_4:t4_3):(t4_3 < t4_4? t4_4:t4_3);
assign t5_5 = opt[1]? (t4_5[6:3] >= t4_6[6:3]? t4_5:t4_6):(t4_5 < t4_6? t4_5:t4_6);
assign t5_6 = opt[1]? (t4_5[6:3] >= t4_6[6:3]? t4_6:t4_5):(t4_5 < t4_6? t4_6:t4_5);

//sort6
assign t6_0 = opt[1]? (t5_0[6:3] >= t5_1[6:3]? t5_0:t5_1):(t5_0 < t5_1? t5_0:t5_1);
assign t6_1 = opt[1]? (t5_0[6:3] >= t5_1[6:3]? t5_1:t5_0):(t5_0 < t5_1? t5_1:t5_0);
assign t6_2 = opt[1]? (t5_2[6:3] >= t5_3[6:3]? t5_2:t5_3):(t5_2 < t5_3? t5_2:t5_3);
assign t6_3 = opt[1]? (t5_2[6:3] >= t5_3[6:3]? t5_3:t5_2):(t5_2 < t5_3? t5_3:t5_2);
assign t6_4 = opt[1]? (t5_4[6:3] >= t5_5[6:3]? t5_4:t5_5):(t5_4 < t5_5? t5_4:t5_5);
assign t6_5 = opt[1]? (t5_4[6:3] >= t5_5[6:3]? t5_5:t5_4):(t5_4 < t5_5? t5_5:t5_4);
assign t6_6 = t5_6;


assign s_id0 =  t6_0[2:0];  
assign s_id1 =  t6_1[2:0];  
assign s_id2 =  t6_2[2:0];  
assign s_id3 =  t6_3[2:0];  
assign s_id4 =  t6_4[2:0];  
assign s_id5 =  t6_5[2:0];  
assign s_id6 =  t6_6[2:0];  
//===========================================
//                calculate
//===========================================
wire signed [4:0] s0;
wire signed [4:0] s1;
wire signed [4:0] s2;
wire signed [4:0] s3;
wire signed [4:0] s4;
wire signed [4:0] s5;
wire signed [4:0] s6;

wire signed [9:0] s0_tr;
wire signed [9:0] s1_tr;
wire signed [9:0] s2_tr;
wire signed [9:0] s3_tr;
wire signed [9:0] s4_tr;
wire signed [9:0] s5_tr;
wire signed [9:0] s6_tr;



wire signed[10:0] sum;
wire signed [11:0] sum_temp;
wire signed [4:0] avg;
wire signed [3:0] a_temp;
wire signed [4:0] b_temp;
wire signed [12:0] neg_p_score;
wire signed [2:0] pos_p_score;
wire signed [5:0] p_score;

assign s0 = opt[0]? {in_s0[3], in_s0}:{1'b0, in_s0};
assign s1 = opt[0]? {in_s1[3], in_s1}:{1'b0, in_s1};
assign s2 = opt[0]? {in_s2[3], in_s2}:{1'b0, in_s2};
assign s3 = opt[0]? {in_s3[3], in_s3}:{1'b0, in_s3};
assign s4 = opt[0]? {in_s4[3], in_s4}:{1'b0, in_s4};
assign s5 = opt[0]? {in_s5[3], in_s5}:{1'b0, in_s5};
assign s6 = opt[0]? {in_s6[3], in_s6}:{1'b0, in_s6};

assign s0_tr = s0[4]?  s0/(a_temp+1) + b_temp:s0*(a_temp+1) + b_temp;
assign s1_tr = s1[4]?  s1/(a_temp+1) + b_temp:s1*(a_temp+1) + b_temp;
assign s2_tr = s2[4]?  s2/(a_temp+1) + b_temp:s2*(a_temp+1) + b_temp;
assign s3_tr = s3[4]?  s3/(a_temp+1) + b_temp:s3*(a_temp+1) + b_temp;
assign s4_tr = s4[4]?  s4/(a_temp+1) + b_temp:s4*(a_temp+1) + b_temp;
assign s5_tr = s5[4]?  s5/(a_temp+1) + b_temp:s5*(a_temp+1) + b_temp;
assign s6_tr = s6[4]?  s6/(a_temp+1) + b_temp:s6*(a_temp+1) + b_temp;

// //average
assign sum = s0 + s1 + s2 + s3 + s4 + s5 + s6;
assign sum_temp = opt[0]? {sum[10], sum}:{1'b0, sum};
assign avg = sum_temp / 7;

assign a_temp = {1'b0, a};
assign b_temp = {1'b0, b};

// //passing score 
assign p_score = avg - a_temp;
// assign neg_p_score = (avg - a_temp - b_temp ) * (a_temp+1);
// assign pos_p_score = (avg - a_temp - b_temp) / (a_temp+1);
//===========================================
//      count
//===========================================
wire c0;
wire c1;
wire c2;
wire c3;
wire c4;
wire c5;
wire c6;

// assign c0 = (opt[0] && s0[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c1 = (opt[0] && s1[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c2 = (opt[0] && s2[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c3 = (opt[0] && s3[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c4 = (opt[0] && s4[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c5 = (opt[0] && s5[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 
// assign c6 = (opt[0] && s6[4])? (s0>=neg_p_score? 1:0):(s0>=pos_p_score? 1:0); 

assign c0 = (s0_tr>=p_score)? 1:0;
assign c1 = (s1_tr>=p_score)? 1:0;
assign c2 = (s2_tr>=p_score)? 1:0;
assign c3 = (s3_tr>=p_score)? 1:0;
assign c4 = (s4_tr>=p_score)? 1:0;
assign c5 = (s5_tr>=p_score)? 1:0;
assign c6 = (s6_tr>=p_score)? 1:0;

assign out = opt[2]? (7-(c0+c1+c2+c3+c4+c5+c6)):(c0+c1+c2+c3+c4+c5+c6);



endmodule

