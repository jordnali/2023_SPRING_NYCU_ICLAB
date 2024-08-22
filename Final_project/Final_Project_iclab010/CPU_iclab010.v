//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################
reg [3:0] current_state, next_state;
reg flag_first_load;
//AXI4
reg arvalid_m_inf_i;
reg [31:0] araddr_m_inf_i;
reg rready_m_inf_i;
//SRAM_inst
wire [15:0] sram_q1;
reg sram_wen1;
//reg [6:0] cnt_sram_a1;
reg [6:0] sram_a1;
reg [15:0] sram_d1;
//
reg cache_inst_valid;
wire signed [15:0] cache_addr1_1;
wire signed [15:0] cache_addr1_2;
//AXI4
reg  signed [15:0] data_addr_offset;
reg arvalid_m_inf_d;
reg [31:0] araddr_m_inf_d;
reg rready_m_inf_d;
wire signed [15:0] data_address;
//SRAM_data
wire [15:0] sram_q2;
reg sram_wen2;
reg [6:0] sram_a2;
reg [15:0] sram_d2;
//
reg cache_data_valid;
wire signed [15:0] cache_addr2_1;
wire signed [15:0] cache_addr2_2;
//
reg awvalid;
reg [31:0] awaddr;
reg wvalid;
reg wlast;
reg [15:0] wdata;
reg bready;
//
reg signed [15:0] pc;
wire [2:0] opcode;
wire [3:0] rs, rt, rd;
wire func;
wire signed [4:0] immediate;
wire [12:0] address;
reg signed [15:0] rs_data, rt_data, rd_data;
//
reg signed [15:0] pc_offset;


// ---------------------------------------------------------------
// axi write address channel
assign awid_m_inf    = 0;
assign awsize_m_inf  = 3'b001;
assign awburst_m_inf = 2'b01;
assign awlen_m_inf   = 0;
// ---------------------------------------------------------------
// axi read address channel 
assign arid_m_inf    = 0;
assign arlen_m_inf   = {7'b1111111, 7'b1111111};
assign arsize_m_inf  = {3'b001, 3'b001};
assign arburst_m_inf = {2'b01, 2'b01};

parameter signed OFFSET = 16'h1000;
parameter S_IDLE      = 0;
parameter S_READ_DRAM = 1;
parameter S_READ_SRAM = 2;
parameter S_READ_INST = 3;
parameter S_INST_CAL  = 4;
parameter S_DRAM_DATA = 5;
parameter S_LOAD      = 6;
parameter S_STORE     = 7;
parameter S_WRITE_OUT = 8;
parameter S_IO_STALL  = 9;
//==============================================================
//   FSM 
//==============================================================


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_state <= S_IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always@(*) begin
    case(current_state)
        S_IDLE:      next_state = S_READ_DRAM;
        S_READ_DRAM: next_state = rlast_m_inf[1]? S_READ_SRAM:S_READ_DRAM;
        S_READ_SRAM: next_state = S_READ_INST;
        S_READ_INST: next_state = S_INST_CAL;
        S_INST_CAL: begin
                if(opcode==3'b011) next_state = S_LOAD;
                else if(opcode==3'b010) next_state = S_STORE;
                else next_state = S_IO_STALL;
        end
        S_DRAM_DATA: next_state = rlast_m_inf[0]? S_LOAD:S_DRAM_DATA;
        S_LOAD: begin
            if(flag_first_load) next_state = S_DRAM_DATA;
            else next_state = (cache_addr2_2>=0 && cache_addr2_2<=127)? (cache_data_valid? S_WRITE_OUT:S_LOAD):S_DRAM_DATA;
        end
        S_STORE:    next_state = bvalid_m_inf? S_IO_STALL:S_STORE;
        S_WRITE_OUT:next_state = S_IO_STALL;
        S_IO_STALL: next_state = (cache_addr1_2>=0 && cache_addr1_2<=127)? S_READ_SRAM:S_IDLE;  
        default:    next_state = S_IDLE;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        flag_first_load <= 1;
    else begin
        if(current_state==S_LOAD)
            flag_first_load <= 0;
    end
end
//==============================================================
//   DRAM_INST to SRAM_INST 
//==============================================================
//SRAM_inst
RA1SH cache_inst (.Q(sram_q1), .CLK(clk), .CEN(1'b0), .WEN(sram_wen1), .A(sram_a1), .D(sram_d1), .OEN(1'b0));

always@(*) begin
    if(rvalid_m_inf[1])
        sram_wen1 = 0;
    else
        sram_wen1 = 1;
end

assign cache_addr1_1 = pc - pc_offset;
assign cache_addr1_2 = {cache_addr1_1[15], cache_addr1_1[15:1]};

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        sram_a1 <= 0;
    else begin
        if(rvalid_m_inf[1]) begin
            if(pc>='d7936 && rlast_m_inf[1])
                sram_a1 <= cache_addr1_2;
            else
                sram_a1 <= sram_a1 + 1;
        end
        else if(current_state==S_IO_STALL && cache_addr1_2>=0 && cache_addr1_2<=127)
            sram_a1 <= cache_addr1_2;
        else if(current_state==S_IDLE)
            sram_a1 <= 0;
    end
end

always@(*) begin
    if(rvalid_m_inf[1])
        sram_d1 = rdata_m_inf[31:16];
    else 
        sram_d1 = 0;
end

//==============================================================
//   DRAM_DATA to SRAM_DATA 
//==============================================================
//SRAM_inst
RA1SH cache_data (.Q(sram_q2), .CLK(clk), .CEN(1'b0), .WEN(sram_wen2), .A(sram_a2), .D(sram_d2), .OEN(1'b0));

always@(*) begin
    if(rvalid_m_inf[0] || (current_state==S_STORE && cache_data_valid))
        sram_wen2 = 0;
    else
        sram_wen2 = 1;
end


assign cache_addr2_1 = data_address-data_addr_offset;
assign cache_addr2_2 = {cache_addr2_1[15], cache_addr2_1[15:1]};
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cache_data_valid <= 0;
    else begin
        if(current_state==S_LOAD || (current_state==S_INST_CAL && next_state==S_STORE)) begin
            if(cache_addr2_2>=0 && cache_addr2_2<=127)
                cache_data_valid <= 1;
            else 
                cache_data_valid <= 0;
        end
        else begin
            cache_data_valid <= 0;
        end
    end
end
  
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        sram_a2 <= 0;
    else begin
        if(rvalid_m_inf[0])
            sram_a2 <= sram_a2 + 1;
        else if((current_state==S_LOAD || (current_state==S_INST_CAL && next_state==S_STORE)) && cache_addr2_2>=0 && cache_addr2_2<=127 && !flag_first_load)
            sram_a2 <= cache_addr2_2;
        else if(current_state==S_LOAD && next_state==S_DRAM_DATA)
            sram_a2 <= 0;
    end
end

always@(*) begin
    if(rvalid_m_inf[0])
        sram_d2 = rdata_m_inf[15:0];
    else if(current_state==S_STORE && cache_data_valid)
        sram_d2 = rt_data;
    else 
        sram_d2 = 0;
end
//==============================================================
//   AXI4 (READ_INST & READ_DATA)
//==============================================================
assign arvalid_m_inf = {arvalid_m_inf_i, arvalid_m_inf_d};
assign araddr_m_inf = {araddr_m_inf_i, araddr_m_inf_d};
assign rready_m_inf = {rready_m_inf_i, rready_m_inf_d};

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        arvalid_m_inf_i <= 0;
    else begin
        if(current_state==S_IDLE) 
            arvalid_m_inf_i <= 1;
        else if(arready_m_inf[1])
            arvalid_m_inf_i <= 0;   
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        araddr_m_inf_i <= 0;
    else begin
        if(current_state==S_IDLE) begin
            if(pc>='d7936)
                araddr_m_inf_i <= 32'h1F00;
            else
                araddr_m_inf_i <= {16'd0, pc};
        end 
        else if(arready_m_inf[1])
            araddr_m_inf_i <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rready_m_inf_i <= 0;
    else begin
        if(arready_m_inf[1])
            rready_m_inf_i <= 1;
        else if(rlast_m_inf[1])
            rready_m_inf_i <= 0;
    end
end



always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        arvalid_m_inf_d <= 0;
    else begin
        if(current_state==S_LOAD && next_state==S_DRAM_DATA) 
            arvalid_m_inf_d <= 1;
        else if(arready_m_inf[0])
            arvalid_m_inf_d <= 0;   
    end
end

assign data_address = (rs_data + immediate)*2 + OFFSET;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_addr_offset <= 0;
    else begin
        if(current_state==S_LOAD && next_state==S_DRAM_DATA) begin
            if(data_address>'d7936)
                data_addr_offset <= 16'h1F00;
            else
                data_addr_offset <= data_address;
        end
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        araddr_m_inf_d <= 0;
    else begin
        if(current_state==S_LOAD && next_state==S_DRAM_DATA) begin
            if(data_address>='d7936)
                araddr_m_inf_d <= 32'h1F00;
            else
                araddr_m_inf_d <= data_address; 
        end
        else if(arready_m_inf[0])
            araddr_m_inf_d <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rready_m_inf_d <= 0;
    else begin
        if(arready_m_inf[0])
            rready_m_inf_d <= 1;
        else if(rlast_m_inf[0])
            rready_m_inf_d <= 0;
    end
end
//==============================================================
//   AXI4 (WRITE_DATA)
//==============================================================

assign awaddr_m_inf  = awaddr;
assign awvalid_m_inf = awvalid;
assign wdata_m_inf   = wdata;
assign wlast_m_inf   = wlast;
assign wvalid_m_inf  = wvalid;
assign bready_m_inf  = bready;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        awvalid <= 0;
    else begin
        if(current_state==S_INST_CAL && next_state==S_STORE)
            awvalid <= 1;
        else if(awready_m_inf)
            awvalid <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        awaddr <= 0;
    else begin
        if(current_state==S_INST_CAL && next_state==S_STORE)
            awaddr <= {16'd0, data_address};
        else if(awready_m_inf)
            awaddr <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wvalid <= 0;
    else begin
        if(awready_m_inf)
            wvalid <= 1;
        else if(wready_m_inf)
            wvalid <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wlast <= 0;
    else begin
        if(awready_m_inf)
            wlast <= 1;
        else if(wready_m_inf)
            wlast <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wdata <= 0;
    else begin
        if(awready_m_inf)
            wdata <= rt_data;
        else if(wready_m_inf)
            wdata <= 0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bready <= 0;
    else begin
        if(awready_m_inf)
            bready <= 1;
        else if(bvalid_m_inf)
            bready <= 0;
    end
end
//==============================================================
//   INSTRUCTION
//==============================================================
//core_instruction
reg [15:0] instruction;
assign opcode = instruction[15:13];
assign rs = instruction[12:9];
assign rt = instruction[8:5];
assign rd = instruction[4:1];
assign func = instruction[0];
assign immediate = instruction[4:0];
assign address = instruction[12:0];

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
       instruction <= 0;
    else begin
        if(current_state==S_READ_INST)
            instruction <= sram_q1;
    end
end

//program counter
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pc <= OFFSET;
    else begin
        if(current_state==S_INST_CAL) begin
            if(opcode==3'b101 && (rs_data==rt_data))  //Branch on equal
                pc <= pc + 2 + 2*immediate;
            else if(opcode==3'b100)
                pc <= {3'b000, address};
            else 
                pc <= pc + 2;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pc_offset <= OFFSET;
    else begin
        if(current_state==S_IO_STALL && next_state==S_IDLE) begin
            if(pc>='d7936)
                pc_offset <= 16'h1F00;
            else
                pc_offset <= pc;
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rs_data <= 0;
    else begin
        if(current_state==S_READ_INST) begin
            case(sram_q1[12:9])
                4'd0: rs_data <= core_r0;
                4'd1: rs_data <= core_r1;
                4'd2: rs_data <= core_r2;
                4'd3: rs_data <= core_r3;
                4'd4: rs_data <= core_r4;
                4'd5: rs_data <= core_r5;
                4'd6: rs_data <= core_r6;
                4'd7: rs_data <= core_r7;
                4'd8: rs_data <= core_r8;
                4'd9: rs_data <= core_r9;
                4'd10:rs_data <= core_r10;
                4'd11:rs_data <= core_r11;
                4'd12:rs_data <= core_r12;
                4'd13:rs_data <= core_r13;
                4'd14:rs_data <= core_r14;
                4'd15:rs_data <= core_r15;
            endcase
        end
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rt_data <= 0;
    else begin
        if(current_state==S_READ_INST) begin
            case(sram_q1[8:5])
                4'd0: rt_data <= core_r0;
                4'd1: rt_data <= core_r1;
                4'd2: rt_data <= core_r2;
                4'd3: rt_data <= core_r3;
                4'd4: rt_data <= core_r4;
                4'd5: rt_data <= core_r5;
                4'd6: rt_data <= core_r6;
                4'd7: rt_data <= core_r7;
                4'd8: rt_data <= core_r8;
                4'd9: rt_data <= core_r9;
                4'd10:rt_data <= core_r10;
                4'd11:rt_data <= core_r11;
                4'd12:rt_data <= core_r12;
                4'd13:rt_data <= core_r13;
                4'd14:rt_data <= core_r14;
                4'd15:rt_data <= core_r15;
            endcase
        end
    end
end
always@(*) begin
    if(opcode==3'b000) begin
        if(func)
            rd_data = rs_data + rt_data;
        else
            rd_data = rs_data - rt_data;
    end
    else if(opcode==3'b001) begin
        if(func)
            rd_data = (rs_data < rt_data)? 16'd1:16'd0;
        else
            rd_data = rs_data * rt_data;
    end
    else begin
        rd_data = 0;
    end
end
//==============================================================
//   IO_STALL 
//==============================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        IO_stall <= 1;
    else begin
        if(next_state==S_IO_STALL)
            IO_stall <= 0;
        else
            IO_stall <= 1;
    end
end
//==============================================================
//   CORE_REG 
//==============================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r0 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==0 && (opcode==3'b000 || opcode==3'b001))
            core_r0 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==0)
            core_r0 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r1 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==1 && (opcode==3'b000 || opcode==3'b001))
            core_r1 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==1)
            core_r1 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r2 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==2 && (opcode==3'b000 || opcode==3'b001))
            core_r2 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==2)
            core_r2 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r3 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==3 && (opcode==3'b000 || opcode==3'b001))
            core_r3 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==3)
            core_r3 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r4 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==4 && (opcode==3'b000 || opcode==3'b001))
            core_r4 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==4)
            core_r4 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r5 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==5 && (opcode==3'b000 || opcode==3'b001))
            core_r5 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==5)
            core_r5 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r6 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==6 && (opcode==3'b000 || opcode==3'b001))
            core_r6 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==6)
            core_r6 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r7 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==7 && (opcode==3'b000 || opcode==3'b001))
            core_r7 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==7)
            core_r7 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r8 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==8 && (opcode==3'b000 || opcode==3'b001))
            core_r8 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==8)
            core_r8 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r9 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==9 && (opcode==3'b000 || opcode==3'b001))
            core_r9 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==9)
            core_r9 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r10 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==10 && (opcode==3'b000 || opcode==3'b001))
            core_r10 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==10)
            core_r10 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r11 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==11 && (opcode==3'b000 || opcode==3'b001))
            core_r11 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==11)
            core_r11 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r12 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==12 && (opcode==3'b000 || opcode==3'b001))
            core_r12 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==12)
            core_r12 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r13 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==13 && (opcode==3'b000 || opcode==3'b001))
            core_r13 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==13)
            core_r13 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r14 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==14 && (opcode==3'b000 || opcode==3'b001))
            core_r14 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==14)
            core_r14 <= sram_q2;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r15 <= 0;
    else begin
        if(current_state==S_INST_CAL && rd==15 && (opcode==3'b000 || opcode==3'b001))
            core_r15 <= rd_data;
        else if(current_state==S_WRITE_OUT && rt==15)
            core_r15 <= sram_q2;
    end
end


endmodule



















