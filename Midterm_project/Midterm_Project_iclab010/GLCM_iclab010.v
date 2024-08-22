//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 spring
//   Midterm Proejct            : GLCM 
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : GLCM.v
//   Module Name : GLCM
//   Release version : V1.0 (Release Date: 2023-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module GLCM(
				clk,	
			  rst_n,	
	
			in_addr_M,
			in_addr_G,
			in_dir,
			in_dis,
			in_valid,
			out_valid,
	

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32;
input			  clk,rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// IO port
input [ADDR_WIDTH-1:0]      in_addr_M;
input [ADDR_WIDTH-1:0]      in_addr_G;
input [1:0]  	  		in_dir;
input [3:0]	    		in_dis;
input 			    	in_valid;
output reg 	              out_valid;
// -----------------------------


// axi write address channel 
output  wire [ID_WIDTH-1:0]        awid_m_inf;   //AWID = 0
output  wire [ADDR_WIDTH-1:0]    awaddr_m_inf;   
output  wire [2:0]            awsize_m_inf;      //AWSIZE = 3'b010
output  wire [1:0]           awburst_m_inf;      //AWBURST = 2'b01
output  wire [3:0]             awlen_m_inf;      
output  wire                 awvalid_m_inf;
input   wire                 awready_m_inf;
// axi write data channel 
output  wire [ DATA_WIDTH-1:0]     wdata_m_inf;
output  wire                   wlast_m_inf;
output  wire                  wvalid_m_inf;
input   wire                  wready_m_inf;
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;  //x
input   wire [1:0]             bresp_m_inf;
input   wire              	   bvalid_m_inf;
output  wire                  bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]       arid_m_inf;   //ARID = 0
output  wire [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [3:0]            arlen_m_inf;      
output  wire [2:0]           arsize_m_inf;      //ARAIZE = 3'b010
output  wire [1:0]          arburst_m_inf;      //AWBURST = 2'b01
output  wire                arvalid_m_inf;
input   wire               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [1:0]             rresp_m_inf;
input   wire                   rlast_m_inf;
input   wire                  rvalid_m_inf;
output  wire                  rready_m_inf;
// -----------------------------
//================================================================
//  Parameter & Integer
//================================================================
localparam S_IDLE = 0;
localparam S_IN_DATA = 1;
localparam S_READ_VALID = 2;
localparam S_IN_MATRIX = 3;
localparam S_READ_LOOP = 4;
localparam S_CAL = 5;
localparam S_CAL2 = 6;
localparam S_OUT = 7;
localparam S_WAIT = 8;
localparam S_IN_DATA2 = 9;
localparam S_READ_SRAM = 10;
integer i, j;
genvar k, m;

//================================================================
//  Wire & Reg
//================================================================
reg [5:0] current_state, next_state;
reg [6:0] cnt_read;
reg [4:0] GLCM_r;
reg [4:0] GLCM_c;
reg [9:0] cnt_sram_a;
reg [12:0]   addr_M_reg;
reg [13:0]   addr_G_reg;
reg [1:0]  	 dir_reg;
reg [3:0]	 dis_reg;
reg arvalid;
wire [31:0] araddr;
wire [1:0] addr_mod;
wire in_matrix_flag;
reg [4:0] in_matrix_map [0:258];
reg [3:0] index_col, index_row;
reg [4:0] offset_r, offset_c;
wire glcm_ele[0:255];
reg glcm_ele_reg [0:255];
wire [7:0] glcm_cal [0:255];
reg [31:0] glcm_result;
reg [2:0] cnt_glcm;
reg [8:0] cnt_w_addr;
reg awvalid;
reg wvalid;
reg [1:0] cnt_glcm_dram;
wire [31:0] sram_q;
reg sram_wen;
reg [9:0] sram_a;
reg [31:0] sram_d;
reg [4:0] in_matrix_fin [0:15][0:15];
//================================================================
//  CONSTANT axi signals
//================================================================
// ---------------------------------------------------------------
// axi write address channel 
assign    awid_m_inf = 0      ;
assign   awlen_m_inf = 0     ;
assign  awsize_m_inf = 3'b010 ;
assign awburst_m_inf = 2'b01  ;
// ---------------------------------------------------------------
// axi read address channel 
assign    arid_m_inf = 0      ;
assign  arsize_m_inf = 3'b010 ;
assign arburst_m_inf = 2'b01  ;
assign arlen_m_inf   = 15;
//================================================================
//  FSM
//================================================================



always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		current_state <= S_IDLE;
	else
		current_state <= next_state;
end
always@(*) begin
	case(current_state)
	S_IDLE:	      next_state = (in_valid)? S_IN_DATA:S_IDLE;
	S_IN_DATA:	  next_state = S_READ_VALID;
	S_READ_VALID: next_state = (arready_m_inf)? S_IN_MATRIX:S_READ_VALID;	
	S_IN_MATRIX:  next_state = (rlast_m_inf)? S_READ_LOOP:S_IN_MATRIX;
	S_READ_LOOP:  next_state = (cnt_read==64)? S_CAL:S_READ_VALID;
	S_CAL      :  next_state = (GLCM_c==31 && GLCM_r==31)? S_CAL2:S_CAL;
	S_CAL2     :  next_state = (wready_m_inf)? S_OUT:S_CAL2;
	S_OUT      :  next_state = S_WAIT;
	S_WAIT     :  next_state = (in_valid)? S_IN_DATA2:S_WAIT;
	S_IN_DATA2 :  next_state = S_READ_SRAM;
	S_READ_SRAM:  next_state = (cnt_sram_a==65)? S_CAL:S_READ_SRAM;
	default: next_state = S_IDLE;
	endcase
end

//================================================================
// IN_DATA
//================================================================


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		addr_M_reg <= 0;
	else begin
		if(in_valid)
			addr_M_reg <= in_addr_M;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		addr_G_reg <= 0;
	else begin
		if(in_valid)
			addr_G_reg<= in_addr_G;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dir_reg <= 0;
	else begin
		if(in_valid)
			dir_reg<= in_dir;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dis_reg <= 0;
	else begin
		if(in_valid)
			dis_reg<= in_dis;
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		arvalid <= 0;
	else begin
		if(next_state==S_READ_VALID || current_state==S_READ_VALID) begin
			if(arready_m_inf)
				arvalid <= 0;
			else
				arvalid <= 1;
		end
	end
end


assign arvalid_m_inf = arvalid;
assign araddr = ('h1000 +64*cnt_read);
assign araddr_m_inf = (current_state==S_READ_VALID)? ('h1000 +64*cnt_read):0;

assign rready_m_inf = (current_state==S_IN_MATRIX);

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt_read <= 0;
	else begin
		if(next_state==S_READ_LOOP) 
			cnt_read <= cnt_read + 1;
		else if(next_state==S_OUT)
			cnt_read <= 0;
	end
end
//================================================================
// READ_DRAM to SRAM
//================================================================

RA1SH u_sram (.Q(sram_q), .CLK(clk), .CEN(1'b0), .WEN(sram_wen), .A(sram_a), .D(sram_d), .OEN(1'b0));
always @(*) begin
	if(rvalid_m_inf)
		sram_wen = 0;
	else
		sram_wen = 1;
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt_sram_a <= 0;
	else begin
		if(rvalid_m_inf || (next_state==S_READ_SRAM && cnt_sram_a<=64))
			cnt_sram_a <= cnt_sram_a + 1;
		else if(next_state==S_OUT)
			cnt_sram_a <= 0;
	end
end
wire [9:0] addr_m_row;
//sram_a
always@(*) begin
	if(rvalid_m_inf)
		sram_a = cnt_sram_a;
	else if(next_state==S_READ_SRAM)
		sram_a = cnt_sram_a + addr_m_row;
	else
		sram_a = 0;
end

//sram_d
always@(*) begin
	if(rvalid_m_inf)
		sram_d = rdata_m_inf;
	else
		sram_d = 0;
end
//================================================================
// READ_DRAM
//================================================================


assign addr_m_row = {2'b00, addr_M_reg[11:2]};
assign addr_mod = addr_M_reg[11:0] - {addr_m_row, 2'b00};

assign in_matrix_flag = (cnt_sram_a >= addr_m_row && cnt_sram_a <= addr_m_row+63 && rvalid_m_inf);



always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		index_col <= 0;
	else begin
		if(in_matrix_flag)
			index_col <= index_col + 4;
		else if(next_state==S_OUT)
			index_col <= 0;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		index_row <= 0;
	else begin
		if(in_matrix_flag) begin
			if(index_col==12)
				index_row <= index_row + 1;
		end
		else if(next_state==S_OUT)
			index_row <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for(i=0; i<=258 ; i=i+1) begin
				in_matrix_map[i] <= 0;
		end
	end
	else begin
		if(in_matrix_flag) begin
			in_matrix_map[index_row*16 + index_col] <=    rdata_m_inf[7:0];
			in_matrix_map[index_row*16 + index_col+1] <= rdata_m_inf[15:8];
			in_matrix_map[index_row*16 + index_col+2] <= rdata_m_inf[23:16];
			in_matrix_map[index_row*16 + index_col+3] <= rdata_m_inf[31:24];
		end
		else if(addr_mod !=0 && rvalid_m_inf && cnt_sram_a==addr_m_row+64) begin
			in_matrix_map[256] <=  rdata_m_inf[7:0];
			in_matrix_map[257] <= rdata_m_inf[15:8];
			in_matrix_map[258] <= rdata_m_inf[23:16];
		end
		else if(current_state==S_READ_SRAM && cnt_sram_a!=65) begin
			in_matrix_map[(cnt_sram_a-1)*4] <=    sram_q[7:0];
			in_matrix_map[(cnt_sram_a-1)*4 + 1] <= sram_q[15:8];
			in_matrix_map[(cnt_sram_a-1)*4 + 2] <= sram_q[23:16];
			in_matrix_map[(cnt_sram_a-1)*4 + 3] <= sram_q[31:24];
		end
		else if(current_state==S_READ_SRAM && cnt_sram_a==65) begin
			in_matrix_map[256] <=  sram_q[7:0];
			in_matrix_map[257] <= sram_q[15:8];
			in_matrix_map[258] <= sram_q[23:16];
		end	
	end
end


generate
	for(k=0; k<16 ;k=k+1) begin
		for(m=0; m<16; m=m+1) begin
			always@(*) begin
				case(addr_mod)
				'd0: in_matrix_fin[k][m] = in_matrix_map[16*k + m];
				'd1: in_matrix_fin[k][m] = in_matrix_map[16*k + m + 1];
				'd2: in_matrix_fin[k][m] = in_matrix_map[16*k + m + 2];
				'd3: in_matrix_fin[k][m] = in_matrix_map[16*k + m + 3];
				endcase
			end
			// if(addr_mod==0)
			// 	assign in_matrix_fin[k][m] = in_matrix_map[16*k + m];
			// else if(addr_mod==1)
			// 	assign in_matrix_fin[k][m] = in_matrix_map[16*k + m + 1];
			// else if(addr_mod==2)
			// 	assign in_matrix_fin[k][m] = in_matrix_map[16*k + m + 2];
			// else
			// 	assign in_matrix_fin[k][m] = in_matrix_map[16*k + m + 3];
		end
	end
endgenerate


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		GLCM_r <= 0;
	else begin
		if(current_state==S_CAL) begin
			if(GLCM_c==31)
				GLCM_r <= GLCM_r + 1;
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		GLCM_c <= 0;
	else begin
		if(current_state==S_CAL) begin
			GLCM_c <= GLCM_c+1;
		end
	end
end


// wire [7:0] offset_rc;
// assign offset_rc = (dir_reg==2'b01)?  16*dis_reg:(dir_reg==2'b10)? dis_reg:(dir_reg==2'b11)?  16*dis_reg+dis_reg:0;

// assign offset_r = (dir_reg==2'b01 || dir_reg==2'b11)? dis_reg:0;
// assign offset_c = (dir_reg==2'b10 || dir_reg==2'b11)? dis_reg:0;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		offset_r <= 0;
	else begin
		if(dir_reg==2'b01 || dir_reg==2'b11)
			offset_r <= dis_reg;
		else
			offset_r <= 0;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		offset_c <= 0;
	else begin
		if(dir_reg==2'b10 || dir_reg==2'b11)
			offset_c <= dis_reg;
		else
			offset_c <= 0;
	end
end


generate
	for(k=0 ; k<16 ; k=k+1) begin
		for(m=0 ; m<16 ; m=m+1) begin
			wire flag;
			assign flag = ((k+offset_r)<=15 && (m+offset_c)<=15)? 1:0;
			if(k==0 && m==0) begin
				assign glcm_ele[0] = (in_matrix_fin[0][0]==GLCM_r && in_matrix_fin[offset_r][offset_c]==GLCM_c)? 1:0;
			end
			else begin
					//assign glcm_ele[16*k+m] = (in_matrix_map[k][m]==GLCM_r && in_matrix_map[k+offset_r][m+offset_c]==GLCM_c)? glcm_ele[16*k+m-1]+1:glcm_ele[16*k+m-1];
					assign glcm_ele[16*k+m] = (flag)? ((in_matrix_fin[k][m]==GLCM_r && in_matrix_fin[k+offset_r][m+offset_c]==GLCM_c)? 1:0):0;
			end
		end
	end
endgenerate

generate
	for(k=0 ;k<=255 ;k=k+1)
		always@(posedge clk or negedge rst_n) begin
			if(!rst_n) 
				glcm_ele_reg[k] <= 0;
			else
				glcm_ele_reg[k] <= glcm_ele[k];
		end
endgenerate

generate
	for(k=0 ; k<=255 ;k=k+1) begin
		if(k==0)
			assign glcm_cal[0] = glcm_ele_reg[0];
		else
			assign glcm_cal[k] = glcm_ele_reg[k]? glcm_cal[k-1]+1:glcm_cal[k-1];
	end
endgenerate

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		glcm_result <= 0;
	else begin
		if(current_state==S_CAL || current_state==S_CAL2 || current_state==S_OUT)
			glcm_result <= {glcm_cal[255], glcm_result[31:8]};
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_glcm <= 0;
	else begin
		if(current_state==S_CAL && cnt_glcm<=2)
			cnt_glcm <= cnt_glcm+1;
		else
			cnt_glcm <= 0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_w_addr <= 0;
	else begin
			if(cnt_glcm==3)
				cnt_w_addr <= cnt_w_addr+1;
		else if(current_state==S_OUT)
			cnt_w_addr <= 0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		awvalid <= 0;
	else begin
		if(current_state==S_CAL && cnt_glcm==0)
			awvalid <= 1;
		else if(awready_m_inf)
			awvalid <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		wvalid <= 0;
	else begin
		if(awvalid && awready_m_inf) 
			wvalid <= 1;
		else if(wready_m_inf)
			wvalid <= 0;
	end
end

assign awvalid_m_inf = awvalid;
assign awaddr_m_inf = (awvalid)? addr_G_reg + (cnt_w_addr*4):0;
assign wvalid_m_inf = wvalid;
assign wlast_m_inf = (cnt_glcm_dram==2);
assign wdata_m_inf = wvalid? glcm_result:0;



always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt_glcm_dram <= 0;
	else begin
		if(wvalid) 
			cnt_glcm_dram <= cnt_glcm_dram+1;
		else 
			cnt_glcm_dram <= 0;
	end
end
//================================================================
// Out_valid
//================================================================
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		out_valid <= 0;
	else begin
		if(current_state == S_OUT)
			out_valid <= 1;
		else
			out_valid <= 0;
	end
end

endmodule








