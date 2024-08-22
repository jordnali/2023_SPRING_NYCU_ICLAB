//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : EC_TOP.v
//   	Module Name : EC_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "INV_IP.v"
//synopsys translate_on

module EC_TOP(
    // Input signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Output signals
    out_valid, out_Rx, out_Ry
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
output reg out_valid;
output reg [6-1:0] out_Rx, out_Ry;

// ===============================================================
// parameter & integer
// ===============================================================
localparam S_IDLE = 0;
localparam S_IN_DATA = 1;
localparam S_P_ADD = 2;
localparam S_P_DOU = 3;
localparam S_XR_YR = 4;
localparam S_OUT = 5;
parameter IP_WIDTH = 6;
// ===============================================================
// wire & register
// ===============================================================
reg [2:0] current_state, next_state;
reg [3:0] cnt_s_p;
reg [2:0] cnt_xr_yr;

reg [5:0] px_reg;
reg [5:0] py_reg;
reg [5:0] qx_reg;
reg [5:0] qy_reg;
reg [5:0] a_reg;
reg [5:0] prime_reg;
wire [5:0] p_sub_xp;
wire [5:0] p_sub_yp;
wire [5:0] p_sub_xq;
wire [5:0] p_sub_xr;
wire [6:0] xq_xp1;
wire [6:0] yq_yp1;
wire [7:0] xr_w;
wire [6:0] xp2_3_a;
reg [5:0] xr_reg ;
reg [5:0] s_reg;
reg [11:0] mod_in;
wire [5:0] mod_out;
reg [IP_WIDTH-1:0]  IN_2;
wire [IP_WIDTH-1:0] OUT_INV;
reg [5:0] yp2_ip;
wire [6:0] xp_xr1;
wire [11:0]mul_out;
reg [5:0] mul_in1, mul_in2;
wire [6:0] s_xp_xr1_yp1;

//****************************************
// state
//****************************************


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= S_IDLE;
    else
        current_state <= next_state;
end

always@(*) begin
    case (current_state)
        S_IDLE:    next_state = in_valid? S_IN_DATA:S_IDLE;
        S_IN_DATA: next_state = (px_reg==qx_reg && py_reg==qy_reg)? S_P_DOU:S_P_ADD;
        S_P_ADD:   next_state = (cnt_s_p==4)? S_XR_YR:S_P_ADD;
        S_P_DOU:   next_state = (cnt_s_p==8)? S_XR_YR:S_P_DOU;
        S_XR_YR:   next_state = (cnt_xr_yr==6)? S_OUT:S_XR_YR;
        S_OUT:     next_state = S_IDLE;
        default: next_state = S_IDLE;
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        cnt_s_p <= 0;    
    else begin
        if(current_state==S_P_ADD && cnt_s_p<=3)
            cnt_s_p <= cnt_s_p + 1;
        else if(current_state==S_P_DOU && cnt_s_p<=7)
            cnt_s_p <= cnt_s_p + 1;
        else
            cnt_s_p <= 0;
    end  
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        cnt_xr_yr <= 0;    
    else begin
        if(current_state==S_XR_YR && cnt_xr_yr<=5)
            cnt_xr_yr <= cnt_xr_yr + 1;
        else
            cnt_xr_yr <= 0;
    end  
end

//*****************************************
// IN_DATA
//*****************************************


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        px_reg <= 0;
    else begin
        if(in_valid)
            px_reg <= in_Px;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        py_reg <= 0;
    else begin
        if(in_valid)
            py_reg <= in_Py;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        qx_reg <= 0;
    else begin
        if(in_valid)
            qx_reg <= in_Qx;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        qy_reg <= 0;
    else begin
        if(in_valid)
            qy_reg <= in_Qy;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        a_reg <= 0;
    else begin
        if(in_valid)
            a_reg <= in_a;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        prime_reg <= 2;
    else begin
        if(in_valid)
            prime_reg <= in_prime;
    end
end

//******************************************
// point_addition & point_doubling & XR_YR
//******************************************
//xp'=p-xp yp'=p-yp xq=p-xq xr=p-xr

assign p_sub_xp = prime_reg - px_reg;
assign p_sub_yp = prime_reg - py_reg;
assign p_sub_xq = prime_reg - qx_reg;
assign p_sub_xr = prime_reg - mod_out;

assign xq_xp1 = qx_reg + p_sub_xp;   //xq+xp'
assign yq_yp1 = qy_reg + p_sub_yp;   //yq+yp'
assign xr_w = mod_out + p_sub_xp + p_sub_xq; //s^2+xp1+xq1\
assign xp_xr1 = px_reg + p_sub_xr;
assign s_xp_xr1_yp1 = mod_out + p_sub_yp;
assign xp2_3_a = mod_out + a_reg;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_reg <= 0;
    else begin
        if(current_state==S_P_ADD && cnt_s_p==4 || current_state==S_P_DOU && cnt_s_p==8)
            s_reg <= mod_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       xr_reg <= 0;
    end
    else begin
        if(cnt_xr_yr==2) 
            xr_reg <= mod_out;
    end
end
//mod

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mod_in <= 0;
    else begin
        if(current_state==S_P_ADD) begin
            case(cnt_s_p)
                'd0: mod_in <= xq_xp1;
                'd1: mod_in <= yq_yp1;
                'd3: mod_in <= mul_out;
            endcase
        end
        else if(current_state==S_P_DOU) begin
            case(cnt_s_p)
                'd0: mod_in <= {py_reg, 1'b0};
                'd2: mod_in <= mul_out;
                'd4: mod_in <= mul_out;
                'd5: mod_in <= xp2_3_a;
                'd7: mod_in <= mul_out;
            endcase
        end
        else if(current_state==S_XR_YR) begin
             case(cnt_xr_yr)
                'd0: mod_in <= mul_out;
                'd1: mod_in <= xr_w;
                'd2: mod_in <= xp_xr1;
                'd4: mod_in <= mul_out;
                'd5: mod_in <= s_xp_xr1_yp1;
            endcase

        end
    end
end

assign mod_out = mod_in % prime_reg;


//INV_IP

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        IN_2 <= 0;
    else begin
        if((current_state==S_P_ADD || current_state==S_P_DOU) && cnt_s_p==1) begin
            IN_2 <= mod_out;
        end
    end
end
INV_IP #(.IP_WIDTH(IP_WIDTH)) I_INV_IP ( .IN_1(prime_reg), .IN_2(IN_2), . OUT_INV(OUT_INV));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        yp2_ip <= 0;
    else begin
        if(current_state==S_P_DOU && cnt_s_p==2)
            yp2_ip <= OUT_INV;
    end
end
//multiplier



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mul_in1 <= 0;
    else begin
         if(current_state==S_P_ADD) begin
            case(cnt_s_p)
                'd2: mul_in1 <= mod_out;
                'd4: mul_in1 <= mod_out;
            endcase
        end
        else if(current_state==S_P_DOU) begin
            case(cnt_s_p)
                'd1: mul_in1 <= px_reg;
                'd3: mul_in1 <= 3;
                'd6: mul_in1 <= mod_out;
                'd8: mul_in1 <= mod_out;
            endcase
        end
        else if(current_state==S_XR_YR) begin
            case(cnt_xr_yr)
                'd3: mul_in1 <= s_reg;
            endcase

        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mul_in2 <= 0;
    else begin
         if(current_state==S_P_ADD) begin
            case(cnt_s_p)
                'd2: mul_in2 <= OUT_INV;
                'd4: mul_in2 <= mod_out;
            endcase
        end
        else if(current_state==S_P_DOU) begin
            case(cnt_s_p)
                'd1: mul_in2 <= px_reg;
                'd3: mul_in2 <= mod_out;
                'd6: mul_in2 <= yp2_ip;
                'd8: mul_in2 <= mod_out;
            endcase
        end
        else if(current_state==S_XR_YR) begin
            case(cnt_xr_yr)
                'd3: mul_in2 <= mod_out;
            endcase
        end
    end
end
assign mul_out = mul_in1 * mul_in2;


//******************************************
// OUTPUT
//******************************************
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else begin
        if(cnt_xr_yr==6)
            out_valid <= 1;
        else
            out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_Rx <= 0;
    else begin
        if(cnt_xr_yr==6)
            out_Rx <= xr_reg;
        else
            out_Rx <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_Ry <= 0;
    else begin
        if(cnt_xr_yr==6)
            out_Ry <= mod_out;
        else
            out_Ry <= 0;
    end
end

endmodule

