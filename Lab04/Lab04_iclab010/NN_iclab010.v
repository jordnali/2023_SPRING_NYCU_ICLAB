//synopsys translate_off 
`include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_exp.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_recip.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sum3.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_dp3.v"
//synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	weight_u,
	weight_w,
	weight_v,
	data_x,
	data_h,
	// Output signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

localparam S_IDLE=0;
localparam S_IN_DATA=1;
localparam S_PRE=2;
localparam S_PIPE=3;
parameter FP_ONE = 32'b0_0111_1111_00000000000000000000000;
parameter FP_0_1 = 32'b0011_1101_1100_1100_1100_1100_1100_1101;
integer i;
genvar j;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid;
input [inst_sig_width+inst_exp_width:0] weight_u, weight_w, weight_v;
input [inst_sig_width+inst_exp_width:0] data_x,data_h;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [1:0] current_state, next_state;
reg [3:0] cnt_in_data;
reg [5:0] cnt_pipe;
reg [inst_sig_width+inst_exp_width:0] v [0:8];
reg [inst_sig_width+inst_exp_width:0] w [0:8];
reg [inst_sig_width+inst_exp_width:0] u [0:8];
reg [inst_sig_width+inst_exp_width:0] x [0:8];
reg [inst_sig_width+inst_exp_width:0] h [0:2];
reg [inst_sig_width+inst_exp_width:0] ht[0:2];

wire [inst_sig_width+inst_exp_width:0] ux_w [0:2];
reg [inst_sig_width+inst_exp_width:0] ux_r [0:2];

wire [inst_sig_width+inst_exp_width:0] wh_w [0:2];
reg [inst_sig_width+inst_exp_width:0] wh_r [0:2];

reg [inst_sig_width+inst_exp_width:0] ux_wh_r [0:2];

reg [inst_sig_width+inst_exp_width:0] v_ht_r ;
wire [inst_sig_width+inst_exp_width:0] e_vh_w;
reg [inst_sig_width+inst_exp_width:0] e_vh_r [0:2];
wire [inst_sig_width+inst_exp_width:0] e_vh_r_add1 [0:2];
wire [inst_sig_width+inst_exp_width:0] y_w;
reg [inst_sig_width+inst_exp_width:0] y_r [0:5];
reg [inst_sig_width+inst_exp_width:0] xt [0:2];
reg [inst_sig_width+inst_exp_width:0] mult1_r [0:2];
reg [inst_sig_width+inst_exp_width:0] mult2_r [0:2];
wire [inst_sig_width+inst_exp_width:0] mult_w [0:2];
wire [inst_sig_width+inst_exp_width:0] mult_add_w;
wire [inst_sig_width+inst_exp_width:0] add_r [0:5];
wire [inst_sig_width+inst_exp_width:0] add_w [0:2]; 
reg [inst_sig_width+inst_exp_width:0] e_vh_r_add1_r [0:2]; 
reg [inst_sig_width+inst_exp_width:0] e_vh_r_add1_re_r ; 
//---------------------------------------------------------------------
//   CURRENT_STATE & NEXT_STATE
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		current_state <= 0;
	else 
		current_state <= next_state;
end


always @(*) begin
	case(current_state) 
		S_IDLE   : next_state = in_valid? S_IN_DATA:S_IDLE;
		S_IN_DATA: next_state = (cnt_in_data==8)? S_PRE:S_IN_DATA;
		S_PRE    : next_state = S_PIPE;
		S_PIPE   : next_state = (cnt_pipe==47)? S_IDLE:S_PIPE;
		default  : next_state = S_IDLE;
	endcase
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_in_data <= 0;
	else begin
		if(next_state==S_IN_DATA && cnt_in_data<=7) begin
			cnt_in_data <= cnt_in_data+1;
		end
		else 
			cnt_in_data <= 0;
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_pipe <= 0;
	else begin
		if(next_state==S_PIPE && cnt_pipe<=46) begin
			cnt_pipe <= cnt_pipe +1;
		end
		else 
			cnt_pipe <= 0;
	end
end


//---------------------------------------------------------------------
//   IN_DATA
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=8;i=i+1)
			v[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA || next_state==S_PRE)
			v[cnt_in_data] <= weight_v;
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=8;i=i+1)
			w[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA || next_state==S_PRE)
			w[cnt_in_data] <= weight_w;
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=8;i=i+1)
			u[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA || next_state==S_PRE)
			u[cnt_in_data] <= weight_u;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=8;i=i+1)
			x[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA || next_state==S_PRE)
			x[cnt_in_data] <= data_x;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1)
			h[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA) begin
			case(cnt_in_data)
			'd0: h[0] <= data_h;
			'd1: h[1] <= data_h;
			'd2: h[2] <= data_h;
			endcase
		end
	end
end
//---------------------------------------------------------------------
//    pipeline0(cnt_pipe==1)
//---------------------------------------------------------------------


//***



	
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1) 
			mult1_r[i] <= 0;
	end
	else begin
		case(cnt_pipe)
		'd1, 'd11, 'd24, 'd37: begin
			mult1_r[0] <= ht[0];
			mult1_r[1] <= ht[1];
			mult1_r[2] <= ht[2];
		end
		'd4, 'd17, 'd30: begin
			mult1_r[0] <= xt[0];
			mult1_r[1] <= xt[1];
			mult1_r[2] <= xt[2];
		end 
		'd9, 'd22, 'd35: begin
			mult1_r[0] <= FP_0_1;
			mult1_r[1] <= FP_0_1;
			mult1_r[2] <= FP_0_1;
		end
		endcase		
	end
end



generate
	for(j=0;j<=2;j=j+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) 
				mult2_r[j] <= 0;
			else begin
				case(cnt_pipe)
				'd1, 'd14, 'd27: mult2_r[j] <= w[j];
				'd2, 'd15, 'd28: mult2_r[j] <= w[j+3];
				'd3, 'd16, 'd29: mult2_r[j] <= w[j+6];
				'd4, 'd17, 'd30: mult2_r[j] <= u[j];
				'd5, 'd18, 'd31: mult2_r[j] <= u[j+3];
				'd6, 'd19, 'd32: mult2_r[j] <= u[j+6];
				'd9, 'd22, 'd35: mult2_r[j] <= ux_wh_r[j];
				'd11, 'd24, 'd37:mult2_r[j] <= v[j];
				'd12, 'd25, 'd38:mult2_r[j] <= v[j+3];
				'd13, 'd26, 'd39:mult2_r[j] <= v[j+6];
				endcase
			
			end
		end
	end
endgenerate


fp_mult_inst fp_mult_0( .inst_a(mult1_r[0]), .inst_b(mult2_r[0]), .z_inst(mult_w [0]));
fp_mult_inst fp_mult_1( .inst_a(mult1_r[1]), .inst_b(mult2_r[1]), .z_inst(mult_w [1]));
fp_mult_inst fp_mult_2( .inst_a(mult1_r[2]), .inst_b(mult2_r[2]), .z_inst(mult_w [2]));


//++/++/++

fp_sum3_inst fp_sum3_ux_w0( .inst_a(mult_w[0]), .inst_b(mult_w[1]), .inst_c(mult_w[2]), .z_inst(mult_add_w));



//ht
generate
	for(j=0;j<=2;j=j+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n)	
				ht[j] <= 0;
			else begin
				if(current_state==S_PRE)
					ht[j] <= h[j];
				else if(cnt_pipe==10 || cnt_pipe==23 || cnt_pipe==36)
					ht[j] <= ux_wh_r[j][31]? mult_w[j]:ux_wh_r[j];
			end		
		end
	end
endgenerate


//add

//ux_wh
generate
	for(j=0;j<=2;j=j+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n)
					ux_wh_r[j] <= 0;
			else begin
				if(cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34) begin
					ux_wh_r[j] <= add_w[j];
				end
			end	
		end
	end
endgenerate


 

assign add_r[0] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? ux_r[0]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? e_vh_r[0]:0);
assign add_r[1] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? ux_r[1]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? e_vh_r[1]:0);
assign add_r[2] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? ux_r[2]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? e_vh_r[2]:0);
assign add_r[3] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? wh_r[0]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? FP_ONE:0);
assign add_r[4] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? wh_r[1]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? FP_ONE:0);
assign add_r[5] = (cnt_pipe==8 || cnt_pipe==21 || cnt_pipe==34)? wh_r[2]:((cnt_pipe==16 || cnt_pipe==29 || cnt_pipe==42)? FP_ONE:0);
fp_add_inst fp_add_0(.inst_a(add_r[0]), .inst_b(add_r[3]), .z_inst(add_w[0]));
fp_add_inst fp_add_1(.inst_a(add_r[1]), .inst_b(add_r[4]), .z_inst(add_w[1]));
fp_add_inst fp_add_2(.inst_a(add_r[2]), .inst_b(add_r[5]), .z_inst(add_w[2]));

//ux
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1)
			ux_r[i] <= 0;
	end
	else begin
		case (cnt_pipe)
			'd5, 'd18, 'd31: ux_r[0] <= mult_add_w;
			'd6, 'd19, 'd32: ux_r[1] <= mult_add_w;
			'd7, 'd20, 'd33: ux_r[2] <= mult_add_w;
		endcase
	
	end
end

//w*h
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1)
			wh_r[i] <= 0;
	end
	else begin
		case (cnt_pipe)
			'd2, 'd15, 'd28: wh_r[0] <= mult_add_w;
			'd3, 'd16, 'd29: wh_r[1] <= mult_add_w;
			'd4, 'd17, 'd30: wh_r[2] <= mult_add_w;
		endcase
	
	end
end

//v*h
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			v_ht_r <= 0;
	end
	else begin
		case (cnt_pipe)
			'd12, 'd25, 'd38, 'd13, 'd26, 'd39, 'd14, 'd27, 'd40: v_ht_r <= mult_add_w[31]? {1'b0, mult_add_w[30:0]}:{1'b1, mult_add_w[30:0]};
		endcase
	end
end




//e^(-vh)


fp_exp_inst fp_exp_vh (.inst_a(v_ht_r), .z_inst(e_vh_w));


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1)
			e_vh_r[i] <= 0;
	end
	else begin
		case (cnt_pipe)
		'd13, 'd26, 'd39: e_vh_r[0] <= e_vh_w;
		'd14, 'd27, 'd40: e_vh_r[1] <= e_vh_w;
		'd15, 'd28, 'd41: e_vh_r[2] <= e_vh_w;
		endcase		
	end
end

generate
	for(j=0;j<=2;j=j+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) 
				e_vh_r_add1_r[j] <= 0;
			else begin
				case (cnt_pipe)
				'd16, 'd29, 'd42: e_vh_r_add1_r[j] <= add_w[j];
				endcase		
			end
		end
	end
endgenerate

//---------------------------------------------------------------------
//   pipeline4(cnt_pipe==5)
//---------------------------------------------------------------------

//1/(1+e^vh)

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			e_vh_r_add1_re_r <= 0;
	end
	else begin
		case (cnt_pipe)
		'd17, 'd30, 'd43: e_vh_r_add1_re_r <= e_vh_r_add1_r[0];
		'd18, 'd31, 'd44: e_vh_r_add1_re_r <= e_vh_r_add1_r[1];
		'd19, 'd32, 'd45: e_vh_r_add1_re_r <= e_vh_r_add1_r[2];
		endcase
	end
end


fp_recip_inst fp_recip_e_vh_r_add1 ( .inst_a(e_vh_r_add1_re_r), .z_inst(y_w));


//y

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=5;i=i+1)
			y_r[i] <= 0;
	end
	else begin
		case(cnt_pipe)
		'd18: y_r[0] <= y_w;
		'd19: y_r[1] <= y_w;
		'd20: y_r[2] <= y_w;
		'd31: y_r[3] <= y_w;
		'd32: y_r[4] <= y_w;
		'd33: y_r[5] <= y_w;
		endcase
	end
end


//xt

generate
	for(j=0;j<=2;j=j+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n)	
				xt[j] <= 0;
			else begin
				if(current_state==S_PRE) 
					xt[j] <= x[j];
				else if(cnt_pipe==16)
					xt[j] <= x[j+3];
				else if(cnt_pipe==29)
					xt[j] <= x[j+6];
			end
				
		end
	end	
endgenerate





//out_valid
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_valid <= 0;
	else begin
		if(cnt_pipe>=38 && cnt_pipe<=46)
			out_valid <=1;
		else
			out_valid <=0;
	end
end

//out
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out <= 0;
	else begin
		case(cnt_pipe)
			'd38: out <= y_r[0];
			'd39: out <= y_r[1];
			'd40: out <= y_r[2];
			'd41: out <= y_r[3];
			'd42: out <= y_r[4];
			'd43: out <= y_r[5];
			'd44: out <= y_w;
			'd45: out <= y_w;
			'd46: out <= y_w;
			default: out <= 0;
		endcase
	end
end
	

endmodule
//---------------------------------------------------------------------
//   IP
//---------------------------------------------------------------------
//DW_fp_add
module fp_add_inst(inst_a, inst_b, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;


input [inst_sig_width+inst_exp_width:0] inst_a;
input [inst_sig_width+inst_exp_width:0] inst_b;
output [inst_sig_width+inst_exp_width:0] z_inst;

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
		U1 ( .a(inst_a), .b(inst_b), .rnd(3'b000), .z(z_inst));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

//DW_fp_mult
module fp_mult_inst( inst_a, inst_b, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;


input [inst_sig_width+inst_exp_width:0] inst_a;
input [inst_sig_width+inst_exp_width:0] inst_b;
output [inst_sig_width+inst_exp_width:0] z_inst;


DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
	U1 ( .a(inst_a), .b(inst_b), .rnd(3'b000), .z(z_inst));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

//DW_fp_exp
module fp_exp_inst(inst_a, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

input [inst_sig_width+inst_exp_width : 0] inst_a;
output [inst_sig_width+inst_exp_width : 0] z_inst;
//output [7 : 0] status_inst;

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
	U1 (
	.a(inst_a),
	.z(z_inst)
	);

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

//DW_fp_recip
module fp_recip_inst( inst_a, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_faithful_round = 0;

input [inst_sig_width+inst_exp_width : 0] inst_a;
output [inst_sig_width+inst_exp_width : 0] z_inst;


DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) 
	U1 (
	.a(inst_a),
	.rnd(3'b000),
	.z(z_inst)
	);

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_sum3_inst( inst_a, inst_b, inst_c, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;

input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [inst_sig_width+inst_exp_width : 0] inst_c;
output [inst_sig_width+inst_exp_width : 0] z_inst;


DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
	U1 (
	.a(inst_a),
	.b(inst_b),
	.c(inst_c),
	.rnd(3'b000),
	.z(z_inst)
	);

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_dp3_inst( inst_a, inst_b, inst_c, inst_d, inst_e, inst_f, z_inst);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [inst_sig_width+inst_exp_width : 0] inst_c;
input [inst_sig_width+inst_exp_width : 0] inst_d;
input [inst_sig_width+inst_exp_width : 0] inst_e;
input [inst_sig_width+inst_exp_width : 0] inst_f;
output [inst_sig_width+inst_exp_width : 0] z_inst;

// Instance of DW_fp_dp3
DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
	U1 (
	.a(inst_a),
	.b(inst_b),
	.c(inst_c),
	.d(inst_d),
	.e(inst_e),
	.f(inst_f),
	.rnd(3'b000),
	.z(z_inst)
	);

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end	
endmodule
