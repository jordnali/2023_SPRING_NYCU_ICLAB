module QUEEN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    col,
    row,

    in_valid_num,
    in_num,

    out_valid,
    out,

    );

input               clk, rst_n, in_valid,in_valid_num;
input       [3:0]   col,row;
input       [2:0]   in_num;

output reg          out_valid;
output reg  [3:0]   out;

//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter IDLE=0, IN_DATA=1, EXE=2, EXE_COLUMN=3, EXE_ROW=4, ANSWER=5, LAST_COL=6, RESULT=7, STOP=8, LAST_COL_ROW11=9;  
integer i;
genvar j;
//==============================================//
//                 reg declaration              //
//==============================================//
reg [3:0] current_state, next_state;
reg [2:0] cnt_in_data;
reg [3:0] cnt_out;
reg [2:0] in_num_reg;
reg [3:0] col_reg [0:5];
reg [3:0] row_reg [0:5];
reg [4:0] out_reg [0:11];
reg [11:0] row_label;
reg [11:0] column_label;
reg [3:0] cnt_column;
reg [3:0] index_row, index_col;
reg [4:0] left_diag [0:11];
reg signed [4:0] right_diag [0:11];
wire diag_test;
wire [11:0] diag_ans1;
wire [11:0] diag_ans2;
wire [11:0] out_index_row;
wire row_test;
//==============================================//
//            FSM State Declaration             //
//==============================================//
//current_state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= 0;
    else
        current_state <= next_state;
end
//next_state
always@(*) begin
    case(current_state)
        IDLE          : next_state = in_valid_num? IN_DATA:IDLE;
   
        IN_DATA       : next_state = (cnt_in_data=='d6)? EXE:IN_DATA;
   
        EXE           : next_state = EXE_COLUMN;
   
        EXE_COLUMN    : next_state = (index_row==11 && (row_test || diag_test))?  LAST_COL : (column_label[index_col]? (index_col==11? STOP:EXE_COLUMN):EXE_ROW);
   
        EXE_ROW       : next_state = (row_test || diag_test)? (index_row==11? LAST_COL:EXE_ROW):ANSWER;
   
        ANSWER        : next_state = (index_col==11 && (column_label[11]))? RESULT:((index_col==12)? RESULT:EXE_COLUMN);
   
        LAST_COL      : next_state = column_label[index_col]? LAST_COL:LAST_COL_ROW11;
   
        RESULT        : next_state = (cnt_out==12)? IDLE:RESULT;
   
        STOP          : next_state = RESULT;

        LAST_COL_ROW11: next_state = (index_row==11)? LAST_COL:EXE_COLUMN; 

        default       : next_state = IDLE;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        in_num_reg <= 0;
    
    else if(in_valid_num)
        in_num_reg <= in_num;

    else if(next_state==IDLE)
        in_num_reg <= 0;

end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_in_data <= 0;

    else if(next_state==IN_DATA && cnt_in_data<=5)
        cnt_in_data <= cnt_in_data + 1;

    else
        cnt_in_data  <= 0; 
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_out <= 0;

    else if((next_state==RESULT) && cnt_out <= 11)
        cnt_out <= cnt_out + 1;

    else
        cnt_out  <= 0; 
end



//==============================================//
//                  Input Block                 //
//==============================================//

//input to col_reg & row_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        col_reg[0] <= 0;
        col_reg[1] <= 0; 
        col_reg[2] <= 0; 
        col_reg[3] <= 0; 
        col_reg[4] <= 0; 
        col_reg[5] <= 0; 
    end

    else if(in_valid) begin
        if(cnt_in_data==0)
            col_reg[0] <= col;
        else if(cnt_in_data==1)
            col_reg[1] <= col;
        else if(cnt_in_data==2)
            col_reg[2] <= col;
        else if(cnt_in_data==3)
            col_reg[3] <= col;
        else if(cnt_in_data==4)
            col_reg[4] <= col;
        else if(cnt_in_data==5) 
            col_reg[5] <= col;
    end

    else if(next_state==IDLE) begin
        col_reg[0] <= 0;
        col_reg[1] <= 0; 
        col_reg[2] <= 0; 
        col_reg[3] <= 0; 
        col_reg[4] <= 0; 
        col_reg[5] <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        row_reg[0] <= 0;
        row_reg[1] <= 0; 
        row_reg[2] <= 0; 
        row_reg[3] <= 0; 
        row_reg[4] <= 0; 
        row_reg[5] <= 0; 
    end

    else if(in_valid) begin
        if(cnt_in_data==0)
            row_reg[0] <= row;
        else if(cnt_in_data==1)
            row_reg[1] <= row;
        else if(cnt_in_data==2)
            row_reg[2] <= row;
        else if(cnt_in_data==3)
            row_reg[3] <= row;
        else if(cnt_in_data==4)
            row_reg[4] <= row;
        else if(cnt_in_data==5) 
            row_reg[5] <= row;
    end

    else if(next_state==IDLE) begin
        row_reg[0] <= 0;
        row_reg[1] <= 0; 
        row_reg[2] <= 0; 
        row_reg[3] <= 0; 
        row_reg[4] <= 0; 
        row_reg[5] <= 0; 
    end
end

//column_label
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        column_label <= 0;

    else if(next_state==EXE) begin
        for(i=0;i<in_num_reg;i=i+1)
            column_label[col_reg[i]] <= 1'b1;
    end

    else if(next_state==IDLE) begin
        column_label <= 0;
    end
end

//row_label
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        row_label <= 0;

    else if(next_state==EXE) begin
        for(i=0;i<in_num_reg;i=i+1)
            row_label[row_reg[i]] <= 1'b1;
    end

    else if(next_state==IDLE) begin
        row_label <= 0;
    end
end

//left_diag
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        left_diag[0] <= 31;
        left_diag[1] <= 31;
        left_diag[2] <= 31;
        left_diag[3] <= 31;
        left_diag[4] <= 31;
        left_diag[5] <= 31;
        left_diag[6] <= 31;
        left_diag[7] <= 31;
        left_diag[8] <= 31;
        left_diag[9] <= 31;
        left_diag[10] <= 31;
        left_diag[11] <= 31;
    end

    else if(next_state==EXE) begin
        for(i=0;i<in_num_reg;i=i+1)
            left_diag[col_reg[i]] <= col_reg[i] + row_reg[i];
    end

    else if(next_state==ANSWER) begin
        left_diag[index_col] <= index_col + index_row;
    end

    else if(next_state==LAST_COL_ROW11)
        left_diag[index_col] <= 31;

    else if(next_state==IDLE) begin
        left_diag[0] <= 31;
        left_diag[1] <= 31;
        left_diag[2] <= 31;
        left_diag[3] <= 31;
        left_diag[4] <= 31;
        left_diag[5] <= 31;
        left_diag[6] <= 31;
        left_diag[7] <= 31;
        left_diag[8] <= 31;
        left_diag[9] <= 31;
        left_diag[10] <= 31;
        left_diag[11] <= 31;
    end
end

//right_diag
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        right_diag[0] <= 'b10000;
        right_diag[1] <= 'b10000;
        right_diag[2] <= 'b10000;
        right_diag[3] <= 'b10000;
        right_diag[4] <= 'b10000;
        right_diag[5] <= 'b10000;
        right_diag[6] <= 'b10000;
        right_diag[7] <= 'b10000;
        right_diag[8] <= 'b10000;
        right_diag[9] <= 'b10000;
        right_diag[10] <= 'b10000;
        right_diag[11] <= 'b10000;
    end

    else if(next_state==EXE) begin
        for(i=0;i<in_num_reg;i=i+1) begin
                right_diag[col_reg[i]] <= $signed({1'b0, col_reg[i]}) - $signed({1'b0, row_reg[i]});
        end
    end

    else if(next_state==ANSWER) begin
            right_diag[index_col] <= $signed({1'b0, index_col}) - $signed({1'b0, index_row});

    end

    else if(next_state==LAST_COL_ROW11) begin
            right_diag[index_col] <= 'b10000;
    end

    else if(next_state==IDLE) begin
        right_diag[0] <= 'b10000;
        right_diag[1] <= 'b10000;
        right_diag[2] <= 'b10000;
        right_diag[3] <= 'b10000;
        right_diag[4] <= 'b10000;
        right_diag[5] <= 'b10000;
        right_diag[6] <= 'b10000;
        right_diag[7] <= 'b10000;
        right_diag[8] <= 'b10000;
        right_diag[9] <= 'b10000;
        right_diag[10] <= 'b10000;
        right_diag[11] <= 'b10000;
    end
end

//out_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  begin
        out_reg[0] <= 31;
        out_reg[1] <= 31;
        out_reg[2] <= 31;
        out_reg[3] <= 31;
        out_reg[4] <= 31;
        out_reg[5] <= 31;
        out_reg[6] <= 31;
        out_reg[7] <= 31;
        out_reg[8] <= 31;
        out_reg[9] <= 31;
        out_reg[10] <= 31;
        out_reg[11] <= 31;
    end

    else if(next_state==EXE) begin
        for(i=0;i<in_num_reg;i=i+1)
            out_reg[col_reg[i]] <= row_reg[i];
    end

    else if(next_state==ANSWER) begin
        out_reg[index_col] <= index_row;
    end

    else if(next_state==LAST_COL_ROW11) begin
        out_reg[index_col] <= 31;
    end

    else if(next_state==IDLE)  begin
        out_reg[0] <= 31;
        out_reg[1] <= 31;
        out_reg[2] <= 31;
        out_reg[3] <= 31;
        out_reg[4] <= 31;
        out_reg[5] <= 31;
        out_reg[6] <= 31;
        out_reg[7] <= 31;
        out_reg[8] <= 31;
        out_reg[9] <= 31;
        out_reg[10] <= 31;
        out_reg[11] <= 31;
    end

end


//index_col
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        index_col <= 0;

    else if(next_state==EXE_COLUMN) begin
        if(column_label[index_col]==1)
            index_col <= index_col+1;
    end

    else if(next_state==LAST_COL) begin
        index_col <= index_col-1;
    end

    else if(next_state==ANSWER) begin
        index_col <= index_col + 1;
    end

    else if(next_state==IDLE)
        index_col <= 0;
end




//index_row
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        index_row <= 0;

    else if(next_state==EXE_ROW) begin
        if(row_test ||diag_test)
            index_row <= index_row+1;
    end

    else if(next_state==ANSWER) begin
        index_row <= 0;
    end

    else if(next_state==LAST_COL) begin
        index_row <= out_reg[index_col-1];
    end

    else if(current_state==LAST_COL_ROW11)
        index_row <= index_row + 1;

    else if(next_state==IDLE)
        index_row <= 0;
        
end

generate
for(j=0;j<12;j=j+1) begin:gen_row_test
    assign out_index_row[j] = (out_reg[j]==index_row);
end   
endgenerate

generate
for(j=0;j<12;j=j+1) begin:gen_diag_ans1
    assign diag_ans1[j] = (left_diag[j]==(index_col+index_row));
end
endgenerate

generate
for(j=0;j<12;j=j+1) begin:gen_diag_ans2
    assign diag_ans2[j] =  (right_diag[j]==($signed({1'b0, index_col}) - $signed({1'b0, index_row}))); 
end
endgenerate

assign row_test = (|out_index_row);
assign diag_test = (|diag_ans1) || (|diag_ans2)  ;


//out
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else if(next_state==RESULT)
        out_valid <= 1;
    else
        out_valid <= 0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out <= 0;

    else if(next_state==RESULT) begin
        out <= out_reg[cnt_out];
    end

    else 
        out <= 0;
end
//GOOD LUCKY

endmodule 