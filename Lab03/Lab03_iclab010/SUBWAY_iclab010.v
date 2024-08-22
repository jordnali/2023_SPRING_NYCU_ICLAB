module SUBWAY(
    //Input Port
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    //Output Port
    out_valid,
    out
);


input clk, rst_n;
input in_valid;
input [1:0] init;
input [1:0] in0, in1, in2, in3; 
output reg       out_valid;
output reg [1:0] out;


//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter S_IDLE=0;
parameter S_IN_DATA=1;
parameter S_EXE=2;
parameter S_OUT=3;
integer i;
//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [3:0] current_state, next_state;
reg [5:0] cnt_in_data;
reg [5:0] cnt_out;
reg [1:0] map0 [0:63];
reg [1:0] map1 [0:63];
reg [1:0] map2 [0:63];
reg [1:0] map3 [0:63];
reg [1:0] t_location [0:7];
reg [7:0] inf6 [0:7];
reg [1:0] answer4 [0:6];
reg [1:0] answer5 [0:6];
reg [1:0] answer6 [0:6];
reg [1:0] answer7 [0:6];
reg [1:0] out_answer2 [0:30];
reg [1:0] out_answer [0:31];
reg [1:0] out_reg [0:62];

//==============================================//
//                  design                      //
//==============================================//

//***************//
//   state   
//***************//
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
        S_IDLE      : next_state = (in_valid)? S_IN_DATA:S_IDLE;
        S_IN_DATA   : next_state = (cnt_in_data==63)? S_EXE:S_IN_DATA;
        S_EXE       : next_state = S_OUT;
        S_OUT       : next_state = (cnt_out==63)? S_IDLE:S_OUT;
        default     : next_state = S_IDLE;
    endcase
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_in_data <= 0;
    else begin 
        if(next_state==S_IN_DATA && cnt_in_data<=62)
            cnt_in_data <= cnt_in_data+1;
        else 
            cnt_in_data <= 0;
    end 
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_out <= 0;
    else begin 
        if(next_state==S_OUT && cnt_out<=62)
            cnt_out <= cnt_out+1;
        else 
            cnt_out <= 0;
    end 
end

//map0
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=63;i=i+1)
            map0[i] <= 0;    
    end
    else begin
        if(next_state==S_IN_DATA)
            map0[cnt_in_data] <= in0;
    end
end

//map1
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=63;i=i+1)
            map1[i] <= 0;    
    end
    else begin
        if(next_state==S_IN_DATA)
            map1[cnt_in_data] <= in1;
    end
end

//map2
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=63;i=i+1)
            map2[i] <= 0;    
    end
    else begin
        if(next_state==S_IN_DATA)
            map2[cnt_in_data] <= in2;
    end
end

//map3
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=63;i=i+1)
            map3[i] <= 0;    
    end
    else begin
        if(next_state==S_IN_DATA)
            map3[cnt_in_data] <= in3;
    end
end

//t_location
always@(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        for(i=0;i<=7;i=i+1)
            t_location[i] <= 0;
    end

    else begin
        if(in_valid) begin
            if(cnt_in_data==0)
                t_location[0] <= init;
            for(i=1;i<=7;i=i+1) begin
                if(cnt_in_data==(8*i))
                    if(in0==0)
                        t_location[i] <= 0;
                    else if(in1==0)
                        t_location[i] <= 1;
                    else if(in2==0)
                        t_location[i] <= 2;
                    else
                        t_location[i] <= 3;
            end
        end
    end
end

//inf6
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=7;i=i+1)
            inf6[i] <= 0;
    end

    else begin
        if(in_valid) begin
            for(i=0;i<=7;i=i+1) begin
                if(cnt_in_data==(6+8*i)) begin
                    inf6[i] <= {in3, in2, in1, in0};
                end
            end
        end
    end
end


//answer4
always@(*) begin
    if(cnt_in_data==57) begin
        for(i=0;i<=6;i=i+1) begin
            if(t_location[i] <= t_location[i+1]) begin
                if((t_location[i+1] - t_location[i])==3)
                    answer4[i] =  2'd1;
                else
                    answer4[i] =  2'd0;
            end

            else begin
                if((t_location[i] - t_location[i+1])==3)
                    answer4[i] =  2'd2;
                else
                    answer4[i] =  2'd0;
            end
        end
    end

    else begin
        for(i=0;i<=6;i=i+1)
            answer4[i] = 0;
    end

end

//answer6
always@(*) begin
    if(cnt_in_data==57) begin
        for(i=0;i<=6;i=i+1) begin
            if(t_location[i] <= t_location[i+1]) begin
                if((t_location[i+1] - t_location[i])==3 || (t_location[i+1] - t_location[i])==2)
                    answer6[i] = 2'd1;
                else
                    answer6[i] = 2'd0;
            end

            else begin
                if((t_location[i] - t_location[i+1])==3 || (t_location[i] - t_location[i+1])==2)
                    answer6[i] = 2'd2;
                else 
                    answer6[i] = 2'd0;
            end
        end
    end

    else begin
        for(i=0;i<=6;i=i+1)
            answer6[i] = 0;
    end
end

//answer7
always@(*) begin
    if(cnt_in_data==57) begin
        for(i=0;i<=6;i=i+1) begin
            if(t_location[i] <= t_location[i+1]) begin
                if(t_location[i] == t_location[i+1])
                    answer7[i] = 2'd0;
                else
                    answer7[i] = 2'd1;
            end

            else begin
                answer7[i] = 2'd2;
            end
        end
    end

    else begin
        for(i=0;i<=6;i=i+1)
            answer7[i] = 0;
    end
end

//answer5
always@(*) begin
    if(cnt_in_data==57) begin
        for(i=0;i<=6;i=i+1) begin
            if((t_location[i+1] - t_location[i])==3) begin
                if(inf6[i][3:2]==2'b01)
                    answer5[i] = 2'd3;
                else
                    answer5[i] = 2'd0;
            end

            else if((t_location[i] - t_location[i+1])==3) begin
                if(inf6[i][5:4]==2'b01)
                    answer5[i] = 2'd3;
                else
                    answer5[i] = 2'd0;
            end
            else begin
                case(t_location[i])
                    2'd0:begin
                        if(inf6[i][1:0]==2'b01)
                            answer5[i] = 2'd3;
                        else 
                            answer5[i] = 2'd0;
                    end
                    2'd1:begin
                        if(inf6[i][3:2]==2'b01)
                            answer5[i] = 2'd3;
                        else 
                            answer5[i] = 2'd0;
                    end
                    2'd2:begin
                        if(inf6[i][5:4]==2'b01)
                            answer5[i] = 2'd3;
                        else 
                            answer5[i] = 2'd0;
                    end
                    default:begin
                        if(inf6[i][7:6]==2'b01)
                            answer5[i] = 2'd3;
                        else 
                            answer5[i] = 2'd0;
                    end
                endcase
            end
        end
    end

    else begin
        for(i=0;i<=6;i=i+1)
            answer5[i] = 0;
    end
end

//out_answer2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=30;i=i+1)
            out_answer2[i] <= 0;
    end

    else  begin
        if(cnt_in_data==57) begin
            for(i=0;i<=6;i=i+1) begin
                out_answer2[4*i] <= answer4[i];
                out_answer2[4*i+1] <= answer5[i];
                out_answer2[4*i+2] <= answer6[i];
                out_answer2[4*i+3] <= answer7[i];
            end
                out_answer2[28] <= 0;
                out_answer2[29] <= 0;
                out_answer2[30] <= 0;
        end

        else if(cnt_in_data==63) begin
            case(t_location[7])
                2'd0:begin
                    if(inf6[7][1:0]==2'b01)
                            out_answer2[29] <= 2'd3;
                        else 
                            out_answer2[29] <= 2'd0;
                end
                2'd1:begin
                    if(inf6[7][3:2]==2'b01)
                            out_answer2[29] <= 2'd3;
                        else 
                            out_answer2[29] <= 2'd0;
                end
                2'd2:begin
                    if(inf6[7][5:4]==2'b01)
                            out_answer2[29] <= 2'd3;
                        else 
                            out_answer2[29] <= 2'd0;
                end
                2'd3:begin
                    if(inf6[7][7:6]==2'b01)
                            out_answer2[29] <= 2'd3;
                        else 
                            out_answer2[29] <= 2'd0;
                end

            endcase
        end
        else if(next_state==S_IDLE) begin
            for(i=0;i<=30;i=i+1)
                out_answer2[i] <= 0;
        end
    end
end

//0~3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=31;i=i+1)
            out_answer[i] <= 0;
    end

    else begin
        if(next_state==S_IN_DATA) begin
            if(cnt_in_data==5) begin
                if(t_location[0]==0) begin
                    if(map0[2]==2'b01)
                            out_answer[1] <= 2'd3;
                    if(map0[4]==2'b01)
                            out_answer[3] <= 2'd3;
                end
                else if(t_location[0]==1) begin
                    if(map1[2]==2'b01)
                            out_answer[1] <= 2'd3;
                    if(map1[4]==2'b01)
                            out_answer[3] <= 2'd3;
                end
                else if(t_location[0]==2) begin
                    if(map2[2]==2'b01)
                            out_answer[1] <= 2'd3;
                    if(map2[4]==2'b01)
                            out_answer[3] <= 2'd3;
                end
                else begin
                    if(map3[2]==2'b01)
                            out_answer[1] <= 2'd3;
                    if(map3[4]==2'b01)
                            out_answer[3] <= 2'd3; 
                end
                out_answer[0] <= 2'd0;
                out_answer[2] <=2'd0;
            end  
            for(i=1;i<=7;i=i+1) begin
                if(cnt_in_data==(5+8*i)) begin
                    if(map0[8*i]==0) begin
                        if(map0[2+8*i]==2'b01)
                            out_answer[1+4*i] <= 2'd3;
                        if(map0[4+8*i]==2'b01)
                            out_answer[3+4*i] <= 2'd3;
                    end

                    else if(map1[8*i]==0) begin
                        if(map1[2+8*i]==2'b01)
                            out_answer[1+4*i] <= 2'd3;
                        if(map1[4+8*i]==2'b01)
                            out_answer[3+4*i] <= 2'd3;
                    end

                    else if(map2[8*i]==0) begin
                        if(map2[2+8*i]==2'b01)
                            out_answer[1+4*i] <= 2'd3;
                        if(map2[4+8*i]==2'b01)
                            out_answer[3+4*i] <= 2'd3;
                    end

                    else begin
                        if(map3[2+8*i]==2'b01)
                            out_answer[1+4*i] <= 2'd3;
                        if(map3[4+8*i]==2'b01)
                            out_answer[3+4*i] <= 2'd3; 
                    end       
                    out_answer[4*i] <= 2'd0;
                    out_answer[4*i+2] <= 2'd0;
                end
            end
        end
        else if(next_state==S_IDLE) begin
            for(i=0;i<=31;i=i+1)
                out_answer[i] <= 0;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<=62;i=i+1)
            out_reg[i] <= 0;
    end
    else begin
        if(next_state==S_EXE) begin
            for(i=0;i<=7;i=i+1) begin
                out_reg[8*i] <= out_answer[4*i];
                out_reg[8*i+1] <= out_answer[4*i+1];
                out_reg[8*i+2] <= out_answer[4*i+2];
                out_reg[8*i+3] <= out_answer[4*i+3];
            end
            for(i=0;i<=6;i=i+1) begin
                out_reg[8*i+4] <= out_answer2[4*i];
                out_reg[8*i+5] <= out_answer2[4*i+1];
                out_reg[8*i+6] <= out_answer2[4*i+2];
                out_reg[8*i+7] <= out_answer2[4*i+3];
            end
        end
        else if(next_state==S_OUT) begin
            out_reg[60] <= out_answer2[28];
            out_reg[61] <= out_answer2[29];
            out_reg[62] <= out_answer2[30];
        end
        else if(next_state==S_IDLE) begin
            for(i=0;i<=62;i=i+1)
                out_reg[i] <= 0;
    end
    
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else begin
        if(next_state==S_OUT)
            out_valid <= 1;
        else 
            out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out <= 0;
    end
    else begin
        if(next_state==S_OUT) begin
            out <= out_reg[cnt_out];
        end
        else
            out <= 0;
    end

end
endmodule