// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	img,
	ker,
	weight,

	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input cg_en;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i;


//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [5:0] cnt_in2;
reg [5:0] cnt_in1;
reg [7:0] img_in1 [0:35];
reg [7:0] ker_in [0:8];
reg [7:0] weight_in [0:3];
reg [1:0] index_col;
reg [1:0] index_row;
reg [7:0] mul [0:8];
wire [19:0] f_map1 ;
reg [19:0] f_map1_r [0:3];
// wire [19:0] max1 [0:2];
// wire [19:0] max2 [0:2];
// wire [19:0] max3 [0:2];
// wire [19:0] max4 [0:2];
wire [7:0] max_p [0:3];
reg [7:0] max_p_r [0:3];
wire [16:0] f_co [0:3];
wire [7:0] f_co_q [0:3]; 
reg [7:0] f_co_q_r [0:3];


//==============================================//
//                 GATED_OR                     //
//==============================================//



//==============================================//
//                  design                      //
//==============================================//
wire sleep_cnt_in1;
wire clk_cnt_in1;
assign sleep_cnt_in1 = !((cnt_in1<=38) || cnt_in2==39);
GATED_OR GATED_cnt_in1 (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_cnt_in1), .RST_N(rst_n), .CLOCK_GATED(clk_cnt_in1));

always @(posedge clk_cnt_in1 or negedge rst_n) begin
	if(!rst_n)
		cnt_in1 <= 0;
	else begin
		if(in_valid && cnt_in1<=38)
			cnt_in1 <= cnt_in1 + 1;
		else if(cnt_in2==39)
			cnt_in1 <= 0;
	end
end

wire sleep_cnt_in2;
wire clk_cnt_in2;
assign sleep_cnt_in2 = !((cnt_in1>=36 && cnt_in2<=39) || cnt_in2==40);
GATED_OR GATED_cnt_in2 (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_cnt_in2), .RST_N(rst_n), .CLOCK_GATED(clk_cnt_in2));
always @(posedge clk_cnt_in2 or negedge rst_n) begin
	if(!rst_n)
		cnt_in2 <= 0;
	else begin
		if(cnt_in1>=36 && cnt_in2<=39)
			cnt_in2 <= cnt_in2 + 1;
		else if(cnt_in2==40)
			cnt_in2 <= 0;
	end
end

//img_in1
wire sleep_img_in1;
wire clk_img_in1;
assign sleep_img_in1 = !((cnt_in1<=35) || (cnt_in1>=36 && cnt_in2<=35));
GATED_OR GATED_img_in1 (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_img_in1), .RST_N(rst_n), .CLOCK_GATED(clk_img_in1));

always@(posedge clk_img_in1 or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=35; i=i+1)
			img_in1[i] <= 0;
	end
	else begin
		if(in_valid && cnt_in1<=35) 
			img_in1[cnt_in1] <= img;
		else if(cnt_in1>=36 && cnt_in2<=35)
			img_in1[cnt_in2] <= img;
	end
end
//ker_in
wire sleep_ker_in;
wire clk_ker_in;
assign sleep_ker_in = !(cnt_in1<=8);
GATED_OR GATED_ker_in (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_ker_in), .RST_N(rst_n), .CLOCK_GATED(clk_ker_in));

always @(posedge clk_ker_in or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=8; i=i+1) 
			ker_in[i] <= 0;
	end
	else begin
		if(in_valid && cnt_in1<=8)
			ker_in[cnt_in1] <= ker;
	end
end
//weight_in
wire sleep_weight_in;
wire clk_weight_in;
assign sleep_weight_in = !(cnt_in1<=3);
GATED_OR GATED_weight_in (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_weight_in), .RST_N(rst_n), .CLOCK_GATED(clk_weight_in));

always @(posedge clk_weight_in or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=3; i=i+1)
			weight_in[i] <= 0;
	end
	else begin
		if(in_valid && cnt_in1<=3) 
			weight_in[cnt_in1] <= weight;
	end
end 

wire sleep_index_col;
wire clk_index_col;
assign sleep_index_col = !((cnt_in1>=21 && cnt_in1<=36) || (cnt_in2>=21 && cnt_in2<=36));
GATED_OR GATED_index_col (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_index_col), .RST_N(rst_n), .CLOCK_GATED(clk_index_col));

always @(posedge clk_index_col or negedge rst_n) begin
	if(!rst_n)
		index_col <= 0;
	else begin
		if((cnt_in1>=21 && cnt_in1<=36) || (cnt_in2>=21 && cnt_in2<=36))
			index_col <= index_col + 1;
	end
end

wire sleep_index_row;
wire clk_index_row;
assign sleep_index_row = !((cnt_in1>=21 && cnt_in1<=36 && index_col==3) || (cnt_in2>=21 && cnt_in2<=36 && index_col==3));
GATED_OR GATED_index_row (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_index_row), .RST_N(rst_n), .CLOCK_GATED(clk_index_row));

always @(posedge clk_index_row or negedge rst_n) begin
	if(!rst_n)
		index_row <= 0;
	else begin
		if((cnt_in1>=21 && cnt_in1<=36 && index_col==3) || (cnt_in2>=21 && cnt_in2<=36 && index_col==3))
			index_row <= index_row + 1;
	end
end
//convolution
wire sleep_mul;
wire clk_mul;
assign sleep_mul = !((cnt_in1>=21 && cnt_in1<=36) || (cnt_in2>=21 && cnt_in2<=36));
GATED_OR GATED_mul (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_mul), .RST_N(rst_n), .CLOCK_GATED(clk_mul));

always @(posedge clk_mul or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=8; i=i+1) begin
			mul[i] <= 0;
		end
	end
	else begin
		if((cnt_in1>=21 && cnt_in1<=36) || (cnt_in2>=21 && cnt_in2<=36)) begin
			mul[0] <= img_in1[6*index_row + index_col];
			mul[1] <= img_in1[6*index_row + index_col + 1];
			mul[2] <= img_in1[6*index_row + index_col + 2];
			mul[3] <= img_in1[6*(index_row+1) + index_col];
			mul[4] <= img_in1[6*(index_row+1) + index_col + 1];
			mul[5] <= img_in1[6*(index_row+1) + index_col + 2];
			mul[6] <= img_in1[6*(index_row+2) + index_col];
			mul[7] <= img_in1[6*(index_row+2) + index_col +1];
			mul[8] <= img_in1[6*(index_row+2) + index_col +2];
		end
	end
end


assign f_map1 = mul[0]*ker_in[0] +
				mul[1]*ker_in[1] + 
				mul[2]*ker_in[2] +
				mul[3]*ker_in[3] +
				mul[4]*ker_in[4] +
				mul[5]*ker_in[5] +
				mul[6]*ker_in[6] +
				mul[7]*ker_in[7] +
				mul[8]*ker_in[8];

wire sleep_f_map1_r;
wire clk_f_map1_r;
assign sleep_f_map1_r = !((cnt_in1>=22 && cnt_in1<=38) || (cnt_in2>=22 && cnt_in2<=38));
GATED_OR GATED_f_map1_r (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_f_map1_r), .RST_N(rst_n), .CLOCK_GATED(clk_f_map1_r));

always @(posedge clk_f_map1_r or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=3; i=i+1) 
			f_map1_r[i] <= 0;
	end
	else begin
		if(cnt_in1>=22 && cnt_in1<=37) begin
			case(cnt_in1)
				'd22, 'd23, 'd26, 'd27: f_map1_r[0] <= (f_map1 > f_map1_r[0])? f_map1:f_map1_r[0];
				'd24, 'd25, 'd28, 'd29: f_map1_r[1] <= (f_map1 > f_map1_r[1])? f_map1:f_map1_r[1];
				'd30, 'd31, 'd34, 'd35: f_map1_r[2] <= (f_map1 > f_map1_r[2])? f_map1:f_map1_r[2];
				'd32, 'd33, 'd36, 'd37: f_map1_r[3] <= (f_map1 > f_map1_r[3])? f_map1:f_map1_r[3];
			endcase
		end
		else if(cnt_in2>=22 && cnt_in2<=37) begin
			case(cnt_in2)
				'd22, 'd23, 'd26, 'd27: f_map1_r[0] <= (f_map1 > f_map1_r[0])? f_map1:f_map1_r[0];
				'd24, 'd25, 'd28, 'd29: f_map1_r[1] <= (f_map1 > f_map1_r[1])? f_map1:f_map1_r[1];
				'd30, 'd31, 'd34, 'd35: f_map1_r[2] <= (f_map1 > f_map1_r[2])? f_map1:f_map1_r[2];
				'd32, 'd33, 'd36, 'd37: f_map1_r[3] <= (f_map1 > f_map1_r[3])? f_map1:f_map1_r[3];
			endcase
		end
		else if(cnt_in1==38 || cnt_in2==38) begin
			for(i=0; i<=3; i=i+1)
				f_map1_r[i] <= 0;
		end
	end
end

//38

// assign max1[0] = (cnt_in1==38 || cnt_in2==38)?  ((f_map1_r[0]>f_map1_r[1])? f_map1_r[0]:f_map1_r[1]):0;
// assign max1[1] = (cnt_in1==38 || cnt_in2==38)?  ((max1[0]>f_map1_r[4])    ? max1[0]:f_map1_r[4]):0;
// assign max1[2] = (cnt_in1==38 || cnt_in2==38)?  ((max1[1]>f_map1_r[5])    ? max1[1]:f_map1_r[5]):0;

// assign max2[0] = (cnt_in1==38 || cnt_in2==38)?  ((f_map1_r[2]>f_map1_r[3])? f_map1_r[2]:f_map1_r[3]):0;
// assign max2[1] = (cnt_in1==38 || cnt_in2==38)?  ((max2[0]>f_map1_r[6])    ? max2[0]:f_map1_r[6]):0;
// assign max2[2] = (cnt_in1==38 || cnt_in2==38)?  ((max2[1]>f_map1_r[7])    ? max2[1]:f_map1_r[7]):0;

// assign max3[0] = (cnt_in1==38 || cnt_in2==38)?  ((f_map1_r[8]>f_map1_r[9])? f_map1_r[8]:f_map1_r[9]):0;
// assign max3[1] = (cnt_in1==38 || cnt_in2==38)?  ((max3[0]>f_map1_r[12])   ? max3[0]:f_map1_r[12]):0;
// assign max3[2] = (cnt_in1==38 || cnt_in2==38)?  ((max3[1]>f_map1_r[13])   ? max3[1]:f_map1_r[13]):0;

// assign max4[0] = (cnt_in1==38 || cnt_in2==38)?  ((f_map1_r[10]>f_map1_r[11])? f_map1_r[10]:f_map1_r[11]):0;
// assign max4[1] = (cnt_in1==38 || cnt_in2==38)?  ((max4[0]>f_map1_r[14])     ? max4[0]:f_map1_r[14]):0;
// assign max4[2] = (cnt_in1==38 || cnt_in2==38)?  ((max4[1]>f_map1_r[15])     ? max4[1]:f_map1_r[15]):0;
//max_pooling quantization

assign max_p[0] = (cnt_in1==38 || cnt_in2==38)? f_map1_r[0] / 2295:0;
assign max_p[1] = (cnt_in1==38 || cnt_in2==38)? f_map1_r[1] / 2295:0;
assign max_p[2] = (cnt_in1==38 || cnt_in2==38)? f_map1_r[2] / 2295:0;
assign max_p[3] = (cnt_in1==38 || cnt_in2==38)? f_map1_r[3] / 2295:0;

//38
wire sleep_max_p_r;
wire clk_max_p_r;
assign sleep_max_p_r = !(cnt_in1==38 || cnt_in2==38);
GATED_OR GATED_max_p_r (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_max_p_r), .RST_N(rst_n), .CLOCK_GATED(clk_max_p_r));

always @(posedge clk_max_p_r or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=3; i=i+1) 
			max_p_r[i] <= 0;
	end
	else begin
		if(cnt_in1==38 || cnt_in2==38) begin
			max_p_r[0] <= max_p[0];
			max_p_r[1] <= max_p[1];
			max_p_r[2] <= max_p[2];
			max_p_r[3] <= max_p[3];
		end
	end
end
//39
//fully connected

assign f_co[0] = max_p_r[0]*weight_in[0] + max_p_r[1]*weight_in[2];
assign f_co[1] = max_p_r[0]*weight_in[1] + max_p_r[1]*weight_in[3];
assign f_co[2] = max_p_r[2]*weight_in[0] + max_p_r[3]*weight_in[2];
assign f_co[3] = max_p_r[2]*weight_in[1] + max_p_r[3]*weight_in[3];
//quatization

assign f_co_q[0] = f_co[0] / 510;
assign f_co_q[1] = f_co[1] / 510;
assign f_co_q[2] = f_co[2] / 510;
assign f_co_q[3] = f_co[3] / 510;


wire sleep_f_co_q_r;
wire clk_f_co_q_r;
assign sleep_f_co_q_r = !(cnt_in1==39);
GATED_OR GATED_f_co_q_r (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_f_co_q_r), .RST_N(rst_n), .CLOCK_GATED(clk_f_co_q_r));

always @(posedge clk_f_co_q_r or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<=3; i=i+1) 
			f_co_q_r[i] <= 0;
	end
	else begin
		if(cnt_in1==39) begin
			f_co_q_r[0] <= f_co_q[0];
			f_co_q_r[1] <= f_co_q[1];
			f_co_q_r[2] <= f_co_q[2];
			f_co_q_r[3] <= f_co_q[3];
		end
	end
end


wire [7:0] l1_element [0:3];
assign l1_element[0] = (cnt_in2==39)? ((f_co_q_r[0]>f_co_q[0])? f_co_q_r[0]-f_co_q[0]:f_co_q[0]-f_co_q_r[0]):0;
assign l1_element[1] = (cnt_in2==39)? ((f_co_q_r[1]>f_co_q[1])? f_co_q_r[1]-f_co_q[1]:f_co_q[1]-f_co_q_r[1]):0;
assign l1_element[2] = (cnt_in2==39)? ((f_co_q_r[2]>f_co_q[2])? f_co_q_r[2]-f_co_q[2]:f_co_q[2]-f_co_q_r[2]):0;
assign l1_element[3] = (cnt_in2==39)? ((f_co_q_r[3]>f_co_q[3])? f_co_q_r[3]-f_co_q[3]:f_co_q[3]-f_co_q_r[3]):0;

wire [9:0] l1_dis;
assign l1_dis = l1_element[0] + l1_element[1] + l1_element[2] + l1_element[3];

wire [9:0] a_f;
assign a_f = (l1_dis>=16)? l1_dis:0;
//***************************************
//   Output
//***************************************
wire sleep_out;
wire clk_out;
assign sleep_out = !(cnt_in2==39 || cnt_in2==40);
GATED_OR GATED_out (.CLOCK(clk), .SLEEP_CTRL(cg_en && sleep_out), .RST_N(rst_n), .CLOCK_GATED(clk_out));

always @(posedge clk_out or negedge rst_n) begin
	if(!rst_n)
		out_valid <= 0;
	else begin
		if(cnt_in2==39)
			out_valid <= 1;
		else if (cnt_in2==40)
			out_valid <= 0;
	end
end
always @(posedge clk_out or negedge rst_n) begin
	if(!rst_n)
		out_data <= 0;
	else begin
		if(cnt_in2==39)
			out_data <= a_f;
		else if (cnt_in2==40)
			out_data <= 0;
	end
end


endmodule