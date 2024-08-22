//synopsys translate_off
`include "DW_div.v"
`include "DW_div_seq.v"
`include "DW_div_pipe.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    in_length,
    out_cos,
    out_valid,
    out_tri
);
input wire clk, rst_n, in_valid;
input wire [7:0] in_length;

output reg out_valid;
output reg [15:0] out_cos;
output reg [1:0] out_tri;
//================================================================
//  Parameter & Integer
//================================================================
parameter S_IDLE = 0;
parameter S_IN_DATA = 1;
parameter S_TRI = 2;
parameter S_CAL = 3;
parameter S_OUT = 4;
parameter inst_a_width = 31;
parameter inst_b_width = 18;
parameter inst_tc_mode = 1;
parameter inst_num_cyc = 15;
parameter inst_rst_mode = 0;
parameter inst_input_mode = 1;
parameter inst_output_mode = 1;
parameter inst_early_start = 0;
integer i;

//================================================================
//  Wire & Reg
//================================================================
reg [1:0] cnt_out;
reg [5:0] cnt;
reg [1:0] cnt_in;
reg [2:0] current_state, next_state;
reg [7:0] in_reg [0:2]; 
wire [7:0] a1, a2, b1, b2, c1, c2;	
wire [7:0] side[0:2];
wire [16:0] aa_bb;
wire [15:0] aa, bb, cc;
wire [1:0] out_tri_result;
wire signed [16:0] a_squ, b_squ, c_squ;
wire signed [17:0] cos_div_a, cos_div_b, cos_div_c;
wire signed [17:0] cos_dor_a, cos_dor_b, cos_dor_c;
wire [15:0] cos_out [0:2];



always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		current_state <= S_IDLE;
	else
		current_state <= next_state;
end
always@(*) begin
	case(current_state)
		S_IDLE: next_state = in_valid? S_IN_DATA:S_IDLE;
		S_IN_DATA: next_state = (in_valid==0)? S_TRI:S_IN_DATA;
		S_TRI:next_state = S_CAL;
		S_CAL:next_state = (cnt==17)? S_OUT:S_CAL;
		S_OUT:next_state = (cnt_out==3)? S_IDLE:S_OUT;
		default: next_state = S_IDLE;
	endcase
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt_in <= 0;
	else
		if(next_state==S_IN_DATA && cnt_in<=1)
			cnt_in <= cnt_in+1;
		else 
			cnt_in <= 0;
end

  
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0;i<=2;i=i+1)
			in_reg[i] <= 0;
	end
	else begin
		if(next_state==S_IN_DATA && current_state==S_IN_DATA || next_state==S_IN_DATA && current_state==S_IDLE) begin
				in_reg[cnt_in] <= in_length;
		end
	end
end

assign a1 = (in_reg[0] > in_reg[1])? in_reg[0]:in_reg[1];
assign a2 = (in_reg[0] < in_reg[1])? in_reg[0]:in_reg[1];
assign b1 = (a1 > in_reg[2])? a1:in_reg[2]; //c
assign b2 = (a1 < in_reg[2])? a1:in_reg[2];  
assign c1 = (a2 > b2)? a2:b2;   //b
assign c2 = (a2 < b2)? a2:b2;  //a

assign side[0] = c2;  //a
assign side[1] = c1;  //b
assign side[2] = b1;  //c

assign aa    = side[0]*side[0];
assign bb    = side[1]*side[1];
assign cc    = side[2]*side[2];
assign aa_bb = aa + bb;

assign out_tri_result = (aa_bb==cc)? 2'b11:((aa_bb<cc)? 2'b01:2'b00);




assign a_squ = in_reg[0] * in_reg[0];
assign b_squ = in_reg[1] * in_reg[1];
assign c_squ = in_reg[2] * in_reg[2];

assign cos_div_a = b_squ + c_squ - a_squ;
assign cos_div_b = a_squ + c_squ - b_squ;
assign cos_div_c = a_squ + b_squ - c_squ; 

assign cos_dor_a = 2*in_reg[1]*in_reg[2];
assign cos_dor_b = 2*in_reg[0]*in_reg[2];
assign cos_dor_c = 2*in_reg[0]*in_reg[1];

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;
	else begin
		if(current_state==S_CAL)
			cnt <= cnt+1;
		else 
			cnt <= 0;
	end
end
wire [30:0] q1, q2, q3;


// Instance of DW_div_seq
DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc,inst_rst_mode, inst_input_mode, inst_output_mode,inst_early_start)
	U1 (.clk(clk),
	.rst_n(rst_n),
	.hold(1'b0),
	.start(cnt==1),
	.a({cos_div_a, 13'd0}),
	.b(cos_dor_a),
	//.complete(complete_inst),
	//.divide_by_0(divide),
	.quotient(q1)
 );


// Instance of DW_div_seq
DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc,inst_rst_mode, inst_input_mode, inst_output_mode,inst_early_start)
	U2 (.clk(clk),
	.rst_n(rst_n),
	.hold(1'b0),
	.start(cnt==1),
	.a({cos_div_b, 13'd0}),
	.b(cos_dor_b),
	//.complete(complete_inst),
	//.divide_by_0(divide),
	.quotient(q2)
);

// Instance of DW_div_seq
DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc,inst_rst_mode, inst_input_mode, inst_output_mode,inst_early_start)
	U3 (.clk(clk),
	.rst_n(rst_n),
	.hold(1'b0),
	.start(cnt==1),
	.a({cos_div_c, 13'd0}),
	.b(cos_dor_c),
	//.complete(complete_inst),
	//.divide_by_0(divide),
	.quotient(q3)
);



always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt_out <= 0;
	else begin
		if(next_state==S_OUT) begin
			cnt_out <= cnt_out + 1;
		end
		else
			cnt_out <= 0;
	end
end

assign cos_out[0] = q1[30]? {q1[30], 2'b11, q1[12:0]}:{q1[30], 2'b00, q1[12:0]};
assign cos_out[1] = q2[30]? {q2[30], 2'b11, q2[12:0]}:{q2[30], 2'b00, q2[12:0]};
assign cos_out[2] = q3[30]? {q3[30], 2'b11, q3[12:0]}:{q3[30], 2'b00, q3[12:0]};

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_cos <= 0;
	else begin
		if(next_state==S_OUT) begin
			case(cnt_out)
				'd0: out_cos <= cos_out[0];
				'd1: out_cos <= cos_out[1];
				'd2: out_cos <= cos_out[2];
			endcase
		end
		else
			out_cos <= 0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_tri <= 0;
	else begin
		if(current_state==S_CAL && next_state==S_OUT)
			out_tri <= out_tri_result;
		else
			out_tri <= 0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_valid <= 0;
	else begin
		if(next_state==S_OUT)
			out_valid <= 1;
		else
			out_valid <= 0;
	end
end
//synopsys dc_script_begin
//set_implementation cpa U1 
//set_implementation cpa U2
//set_implementation cpa U3
//synopsys dc_script_end  

endmodule
