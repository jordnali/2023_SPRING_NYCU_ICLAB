module MMT(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid2,
    matrix,
	matrix_size,
    matrix_idx,
    mode,
	
// output signals
    out_valid,
    out_value
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid, in_valid2;
input [7:0] matrix;
input [1:0]  matrix_size,mode;
input [4:0]  matrix_idx;

output reg       	     out_valid;
output reg signed [49:0] out_value;
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
localparam S_IDLE = 0;
localparam S_IN_DATA = 1;
localparam S_WAIT = 2;
localparam S_IN_DATA2 = 3;
localparam S_TRANS = 4;
localparam S_READ_MAT0 = 5 ;
localparam S_READ_MAT1 = 6 ;
localparam S_MULT_ADD = 7;
localparam S_WAIT2 = 8;
localparam S_READ_MAT3 = 9;
localparam S_READ_MAT2 =10;
localparam S_MULT_ADD2 = 11;
localparam S_TRANS_MODE = 12;
localparam S_TRACE = 13;
localparam S_OUT =14;
integer i;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [3:0] next_state, current_state;
reg [12:0] cnt;
reg [5:0] m_size;
reg [12:0] data_size;
reg [4:0] m_idx [0:2];
reg [8:0] cnt_ma;
reg [8:0] cnt_mb;
reg [9:0] m_size_squ;
reg [1:0]tra_mode;
reg [3:0] index_row;
reg [3:0] out_times;
wire [7:0] q_mem;
reg [7:0] d_mem;
reg [12:0] a_mem;
reg wen_mem;
reg [3:0] index_col;
reg signed [21:0] matrix_ab [0:255];
reg signed [7:0] ma_element;
reg signed [20:0] ma_element2;
reg signed [20:0] ma_element2_w;
reg signed [20:0] matrix_ab0 [0:15];
reg signed [20:0] matrix_ab1 [0:15];
reg signed [20:0] matrix_ab2 [0:15];
reg signed [20:0] matrix_ab3 [0:15];
reg signed [20:0] matrix_ab4 [0:15];
reg signed [20:0] matrix_ab5 [0:15];
reg signed [20:0] matrix_ab6 [0:15];
reg signed [20:0] matrix_ab7 [0:15];
reg signed [20:0] matrix_ab8 [0:15];
reg signed [20:0] matrix_ab9 [0:15];
reg signed [20:0] matrix_ab10 [0:15];
reg signed [20:0] matrix_ab11 [0:15];
reg signed [20:0] matrix_ab12 [0:15];
reg signed [20:0] matrix_ab13 [0:15];
reg signed [20:0] matrix_ab14 [0:15];
reg signed [20:0] matrix_ab15 [0:15];
reg signed [7:0] mb_element [0:15]; 
wire signed [28:0] mabc_element;
reg signed [31:0] matrix_abc [0:15];
reg signed [35:0] trace_out;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= S_IDLE;
    else 
        current_state <= next_state;
end

always @(*) begin
    case(current_state)
        S_IDLE:     next_state = in_valid? S_IN_DATA:S_IDLE;
        S_IN_DATA:  next_state = (cnt==data_size)? S_WAIT:S_IN_DATA;
        S_WAIT:     next_state = in_valid2? S_IN_DATA2:S_WAIT;
        S_IN_DATA2: next_state = (cnt==3)? S_TRANS:S_IN_DATA2;
        S_TRANS:    next_state = S_READ_MAT0;
        S_READ_MAT0:next_state = S_READ_MAT1;
        S_READ_MAT1:next_state = (cnt==m_size)? S_MULT_ADD:S_READ_MAT1;
        S_MULT_ADD: next_state = (cnt_ma==m_size_squ)? S_WAIT2:S_READ_MAT0;
        S_WAIT2:    next_state = S_READ_MAT3;
        S_READ_MAT3:next_state = S_READ_MAT2;
        S_READ_MAT2:next_state = (cnt==m_size)? S_MULT_ADD2:S_READ_MAT2;
        S_MULT_ADD2:next_state = (cnt_ma==m_size_squ)? S_TRACE:S_READ_MAT3;
        S_TRACE    :next_state = (cnt==m_size)? S_OUT:S_TRACE;
        S_OUT      :next_state = (out_times==9)? S_IDLE:S_WAIT;
        default:next_state = S_IDLE;
    endcase
end

always @(*) begin
    case(m_size)
    'd2:m_size_squ = 4;
    'd4:m_size_squ = 16;
    'd8:m_size_squ = 64;
    'd16:m_size_squ = 256;
    default: m_size_squ = 0;
    endcase
end

always @(*) begin
    case(m_size)
    'd2:data_size= 128;
    'd4:data_size= 512;
    'd8:data_size= 2048;
    'd16:data_size = 8192;
    default: data_size = 0;
    endcase
end
// assign m_size_squ = m_size*m_size;
// assign data_size = m_size*m_size*32;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cnt <= 0;
    else begin
        case(next_state)
            S_IN_DATA: begin
                if(cnt==0) cnt <= cnt+1;
                else if (cnt <= data_size-1) cnt <= cnt+1;
                else cnt <= 0;
            end
            S_WAIT:  cnt <= 0;
            S_IN_DATA2: begin
                if(cnt <= 2) cnt <= cnt+1;
                else cnt <= 0;
            end
            S_READ_MAT1, S_READ_MAT2:begin
                if(cnt <= m_size-1) cnt <= cnt+1;
                else cnt <= 0;
            end
            S_TRACE:
                if(cnt <= m_size-1) cnt <= cnt+1;
                else cnt <= 0;
            default: cnt <= 0;
        endcase
    end
end

//m_size

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  
        m_size <= 0;
    else begin
        if(next_state==S_IN_DATA && cnt==0)
            case(matrix_size)
            2'b00: m_size <= 2;
            2'b01: m_size <= 4;
            2'b10: m_size <= 8;
            2'b11: m_size <= 16;
            endcase
    end
end

//---------------------------------------------------------------------
//   IN_DATA
//---------------------------------------------------------------------

RA1SH mem_matrix (.Q(q_mem), .CLK(clk), .CEN(1'b0), .WEN(wen_mem), .A(a_mem), .D(d_mem), .OEN(1'b0));

//wen_mem
always @(*) begin
    case(next_state)
        S_IN_DATA: wen_mem = 0;

        default: wen_mem = 1;   
    endcase
end

//a_mem
always @(*) begin
    case(next_state)
        S_IN_DATA: a_mem = cnt;
        S_READ_MAT0: a_mem = m_idx[0]*m_size_squ + cnt_ma;  //initial location+cnt
        S_READ_MAT1: a_mem = m_idx[1]*m_size_squ + cnt_mb;
        S_READ_MAT2: begin
            if(tra_mode==2'b00) a_mem = m_idx[2]*m_size_squ + cnt_mb;
            else begin
                a_mem = m_idx[2]*m_size_squ + cnt*m_size+index_col;
            end
        end
        default: a_mem = 0;
    endcase
end


always @(posedge clk or negedge rst_n) begin //s_out index_col =0
    if(!rst_n)
        index_col <= 0;
    else
        if(next_state==S_MULT_ADD2) begin
            if(index_col <= m_size-2)
                index_col <= index_col+1;
            else
                index_col <= 0;
        end
end

//d_mem
always @(*) begin
    case (next_state)
        S_IN_DATA: d_mem = matrix;
        default: d_mem = 0;
    endcase
end


//---------------------------------------------------------------------
//   IN_DATA2
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tra_mode <= 0;
    else
        if(next_state==S_IN_DATA2 && cnt==0)
            tra_mode <= mode;
end




always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=2;i=i+1)
            m_idx[i] <= 0;
    end
    else begin
        if(next_state==S_IN_DATA2) begin
            case(cnt)
                2'd0: m_idx[0] <= matrix_idx;
                2'd1: m_idx[1] <= matrix_idx;
                2'd2: m_idx[2] <= matrix_idx;
            endcase
        end
        else if(next_state==S_TRANS) begin
            case(tra_mode)
                2'b01: begin
                    m_idx[0] <= m_idx[1];
                    m_idx[1] <= m_idx[2];
                    m_idx[2] <= m_idx[0];
                end 
                2'b10: begin
                    m_idx[0] <= m_idx[2];
                    m_idx[1] <= m_idx[0];
                    m_idx[2] <= m_idx[1];
                end 
            endcase 
        end
        else if(next_state==S_OUT) begin
            for(i=0;i<=2;i=i+1)
                m_idx[i] <= 0;
        end
    end
end

//---------------------------------------------------------------------
//   MATRIXA*MATRIXB
//---------------------------------------------------------------------


always @(posedge clk or negedge rst_n) begin   //S_OUT cnt_ma <= 0
    if(!rst_n)
        cnt_ma <= 0;
    else
        case (next_state)
            S_READ_MAT0, S_READ_MAT3: begin
                if(cnt_ma <= m_size_squ-1) cnt_ma <= cnt_ma+1;
                else cnt_ma <= 0;
            end
            S_WAIT2: cnt_ma <= 0;
            S_OUT:cnt_ma <= 0;
            //S_READ3: 
        endcase 
end


always @(posedge clk or negedge rst_n) begin  //S_OUT cnt_mb <= 0
    if(!rst_n)
        cnt_mb <= 0;
    else
        case (next_state)
            S_READ_MAT0, S_READ_MAT3:if(cnt_mb==m_size_squ) cnt_mb <= 0;
            S_READ_MAT1, S_READ_MAT2: begin
                if(cnt_mb <= m_size_squ-1) cnt_mb <= cnt_mb+1;
                else cnt_mb <= 0;
            end
            S_WAIT2: cnt_mb <= 0;
            S_OUT: cnt_mb <= 0;
        endcase
    
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ma_element <= 0;
    else begin
        case(current_state)
            S_READ_MAT0: ma_element <= q_mem;
            
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ma_element2 <= 0;
    else begin
        case(current_state)
            S_READ_MAT3: ma_element2 <= ma_element2_w;
           
        endcase
    end
end

always @(*) begin
    case(index_row)
    'd0: ma_element2_w = matrix_ab0[index_col];
    'd1: ma_element2_w = matrix_ab1[index_col];
    'd2: ma_element2_w = matrix_ab2[index_col];
    'd3: ma_element2_w = matrix_ab3[index_col];
    'd4: ma_element2_w = matrix_ab4[index_col];
    'd5: ma_element2_w = matrix_ab5[index_col];
    'd6: ma_element2_w = matrix_ab6[index_col];
    'd7: ma_element2_w = matrix_ab7[index_col];
    'd8: ma_element2_w = matrix_ab8[index_col];
    'd9: ma_element2_w = matrix_ab9[index_col];
    'd10:ma_element2_w = matrix_ab10[index_col];
    'd11:ma_element2_w = matrix_ab11[index_col];
    'd12:ma_element2_w = matrix_ab12[index_col];
    'd13:ma_element2_w = matrix_ab13[index_col];
    'd14:ma_element2_w = matrix_ab14[index_col];
    'd15:ma_element2_w = matrix_ab15[index_col];
    default: ma_element2_w = 0;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            mb_element[i] <= 0;
    end
    else begin
        case(current_state)
            S_READ_MAT1, S_READ_MAT2: mb_element[cnt-1] <= q_mem;
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin  //S_OUT index <= 0;
    if(!rst_n)
        index_row <= 0;
    else begin
        case(current_state)
            S_MULT_ADD, S_MULT_ADD2: begin
                if(cnt_mb==m_size_squ) index_row <= index_row+1;
            end
            S_WAIT2:index_row <= 0;
            S_OUT: index_row <= 0;
        endcase
    end
end


assign mabc_element = ma_element2*mb_element[index_row];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_abc[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD2:begin
                    matrix_abc[index_row] <= matrix_abc[index_row] + mabc_element;
            end
            S_OUT:begin
                for(i=0;i<=15;i=i+1)
                    matrix_abc[i] <= 0;
            end
        endcase

    end       
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        trace_out <= 0;
    else begin
        if(current_state==S_TRACE) begin
            trace_out <= trace_out + matrix_abc[cnt-1];
        end
        else if(current_state==S_OUT) begin
            trace_out <= 0;
        end
    end
    
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else begin
        if(current_state==S_OUT)
            out_valid <= 1;
        else
            out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_value <= 0;
    else begin
        if(current_state==S_OUT)
            out_value <= trace_out;
        else
            out_value <= 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_times <= 0;
    else 
        if(current_state==S_OUT)
            out_times <= out_times+1;
        else if(current_state==S_IDLE)
            out_times <= 0;
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab0[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==0)
                        matrix_ab0[i] <= matrix_ab0[i] + (ma_element*mb_element[i]);
                end
            end
        S_OUT:begin
                for(i=0;i<=15;i=i+1)
                    matrix_ab0[i] <= 0;
            end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab1[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==1)
                        matrix_ab1[i] <= matrix_ab1[i] + (ma_element*mb_element[i]);
                end
            end
        S_OUT:begin
                for(i=0;i<=15;i=i+1)
                    matrix_ab1[i] <= 0;
            end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab2[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==2)
                        matrix_ab2[i] <= matrix_ab2[i] + (ma_element*mb_element[i]);
                end
            end
        S_OUT:begin
                for(i=0;i<=15;i=i+1)
                    matrix_ab2[i] <= 0;
            end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab3[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==3)
                        matrix_ab3[i] <= matrix_ab3[i] + (ma_element*mb_element[i]);
                end
            end
        S_OUT:begin
                for(i=0;i<=15;i=i+1)
                    matrix_ab3[i] <= 0;
            end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab4[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==4)
                        matrix_ab4[i] <= matrix_ab4[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab4[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab5[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==5)
                        matrix_ab5[i] <= matrix_ab5[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab5[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab6[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==6)
                        matrix_ab6[i] <= matrix_ab6[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab6[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab7[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==7)
                        matrix_ab7[i] <= matrix_ab7[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab7[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab8[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==8)
                        matrix_ab8[i] <= matrix_ab8[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab8[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab9[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==9)
                        matrix_ab9[i] <= matrix_ab9[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab9[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab10[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==10)
                        matrix_ab10[i] <= matrix_ab10[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab10[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab11[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==11)
                        matrix_ab11[i] <= matrix_ab11[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab11[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab12[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==12)
                        matrix_ab12[i] <= matrix_ab12[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab12[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab13[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==13)
                        matrix_ab13[i] <= matrix_ab13[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab13[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab14[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==14)
                        matrix_ab14[i] <= matrix_ab14[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab14[i] <= 0;
                end
        endcase
    end       
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=15;i=i+1)
            matrix_ab15[i] <= 0;
    end
    else begin
        case(current_state) 
            S_MULT_ADD:begin
                for(i=0;i<m_size;i=i+1) begin
                    if(index_row==15)
                        matrix_ab15[i] <= matrix_ab15[i] + (ma_element*mb_element[i]);
                end
            end
            S_OUT:begin
                    for(i=0;i<=15;i=i+1)
                        matrix_ab15[i] <= 0;
                end
        endcase
    end       
end
endmodule

