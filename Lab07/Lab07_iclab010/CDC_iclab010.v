`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
    doraemon_id,
    size,
    iq_score,
    eq_score,
    size_weight,
    iq_weight,
    eq_weight,
    //Output Port
	ready,
    out_valid,
	out,
    
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
output reg  [7:0] out;
output reg	out_valid,ready;

input rst_n, clk1, clk2, in_valid;
input  [4:0]doraemon_id;
input  [7:0]size;
input  [7:0]iq_score;
input  [7:0]eq_score;
input [2:0]size_weight,iq_weight,eq_weight;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
wire wfull;  //, wfull_i_e;
wire rempty;  //,rempty_i_e;
reg rinc;
reg [2:0] cnt1, cnt2;
wire [15:0] preference [0:3];
reg [4:0] do_id [0:4];
reg [12:0] cnt_last;
wire [7:0] out_r;
reg out_valid_t;
reg [7:0] out_t;
integer i;
//********************************************************
//  AFIFO
//********************************************************

AFIFO u_afifo_out (
    .rst_n(rst_n),
    .rclk(clk2),
    .rinc(rinc && cnt2==5),
    .wclk(clk1),
    .winc(in_valid && cnt1==5 || cnt_last==5995),
	.wdata({preference[3][2:0],do_id[preference[3][2:0]]}),

    .rempty(rempty),
	.rdata(out_r),
    .wfull(wfull)
);

always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n) 
        cnt_last<= 0;
    else begin
        if(in_valid && cnt1==5 && cnt_last<=5994)
           cnt_last <= cnt_last + 1;
    end  
end


always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n) 
        cnt1 <= 0;
    else begin
        if(in_valid && cnt1 <=4)
            cnt1 <= cnt1 + 1;
    end  
end

always @(posedge clk2 or negedge rst_n) begin
    if(!rst_n) 
        cnt2 <= 0;
    else begin
        if(rinc && cnt2 <=4)
            cnt2 <= cnt2 + 1;
    end  
end
always@(*) begin
    if(!rempty)
        rinc = 1;
    else
        rinc = 0;
end




always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<=4; i=i+1)
            do_id[i] <= 0;
    end
    else begin
        if(in_valid)  begin
            if(cnt1 <=4) begin
                do_id[4] <= doraemon_id;
                do_id[3] <= do_id[4];
                do_id[2] <= do_id[3];
                do_id[1] <= do_id[2];
                do_id[0] <= do_id[1];
            end
            else begin
                do_id[preference[3][2:0]] <= doraemon_id;
            end
        end
    end
end
reg [7:0] do_size [0:4];
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<=4; i=i+1)
            do_size[i] <= 0;
    end
    else begin
        if(in_valid)  begin
            if(cnt1<=4) begin
                do_size[4] <= size;
                do_size[3] <= do_size[4];
                do_size[2] <= do_size[3];
                do_size[1] <= do_size[2];
                do_size[0] <= do_size[1];
            end
            else begin
                do_size[preference[3][2:0]] <= size;
            end
        end
    end
end
reg [7:0] do_iq [0:4];
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<=4; i=i+1)
            do_iq [i] <= 0;
    end
    else begin
        if(in_valid)  begin
            if(cnt1<=4) begin
                do_iq[4] <= iq_score;
                do_iq[3] <= do_iq[4];
                do_iq[2] <= do_iq[3];
                do_iq[1] <= do_iq[2];
                do_iq[0] <= do_iq[1];
            end
            else begin
                do_iq[preference[3][2:0]] <= iq_score;
            end
        end
    end
end
reg [7:0] do_eq [0:4];
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<=4; i=i+1)
            do_eq[i] <= 0;
    end
    else begin
        if(in_valid)  begin
            if(cnt1<=4) begin
                do_eq[4] <= eq_score;
                do_eq[3] <= do_eq[4];
                do_eq[2] <= do_eq[3];
                do_eq[1] <= do_eq[2];
                do_eq[0] <= do_eq[1];
            end
            else  begin
                do_eq[preference[3][2:0]] <= eq_score;
            end
        end
    end
end
//nobi_size_w
reg [2:0] nobi_size_w ;
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
            nobi_size_w <= 0;
    end
    else begin
        if(in_valid && cnt1>=4)  begin
            nobi_size_w <= size_weight;
        end
    end
end
//nobi_iq_w
reg [2:0] nobi_iq_w;
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
            nobi_iq_w <= 0;
    end
    else begin
        if(in_valid && cnt1>=4)  begin
            nobi_iq_w <= iq_weight;
        end
    end
end
//nobi_eq_w
reg [7:0] nobi_eq_w;
always@(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        nobi_eq_w <= 0;
    end
    else begin
        if(in_valid && cnt1>=4)  begin
            nobi_eq_w <= eq_weight;
        end
    end
end

wire [12:0] door [0:4];  
assign door[0] = do_size[0]*nobi_size_w + do_iq[0]*nobi_iq_w + do_eq[0]*nobi_eq_w;
assign door[1] = do_size[1]*nobi_size_w + do_iq[1]*nobi_iq_w + do_eq[1]*nobi_eq_w;
assign door[2] = do_size[2]*nobi_size_w + do_iq[2]*nobi_iq_w + do_eq[2]*nobi_eq_w;
assign door[3] = do_size[3]*nobi_size_w + do_iq[3]*nobi_iq_w + do_eq[3]*nobi_eq_w;
assign door[4] = do_size[4]*nobi_size_w + do_iq[4]*nobi_iq_w + do_eq[4]*nobi_eq_w;

wire [15:0] door_p [0:4];
assign door_p[0] = {door[0], 3'b000};
assign door_p[1] = {door[1], 3'b001};
assign door_p[2] = {door[2], 3'b010};
assign door_p[3] = {door[3], 3'b011};
assign door_p[4] = {door[4], 3'b100};

assign preference[0] = (door_p[0][15:3] >= door_p[1][15:3])? door_p[0]:door_p[1];
assign preference[1] = (preference[0][15:3] >= door_p[2][15:3])? preference[0]:door_p[2];
assign preference[2] = (preference[1][15:3] >= door_p[3][15:3])? preference[1]:door_p[3];
assign preference[3] = (preference[2][15:3] >= door_p[4][15:3])? preference[2]:door_p[4];

//********************************************************
//  Output
//********************************************************
reg [12:0] cnt_out;
always@(*) begin
    if(!rst_n) 
        ready = 0;
    else begin
        if(cnt_out == 5996 || cnt_out == 5997)
            ready = 0;
        else begin
            if(!wfull)
                ready = 1;
            else
                ready = 0;
        end       
    end
end


always@(posedge clk2 or negedge rst_n) begin
    if(!rst_n)
        cnt_out <= 0;
    else begin
        if(rinc && cnt2==5 && cnt_out <= 5996)
            cnt_out <= cnt_out + 1;
    end
end


always@(posedge clk2 or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else begin
        if(cnt_out==5996 || cnt_out==5997)
            out_valid <= 0;
        else begin
            if(rinc && cnt2==5)
                out_valid <= 1;
            else
                out_valid<= 0;
        end
        
    end
end

always@(posedge clk2 or negedge rst_n) begin
    if(!rst_n) 
        out <= 0;
    else begin
        if(cnt_out==5996 || cnt_out==5997)
            out <= 0;
        else begin
            if(rinc && cnt2==5)
                out <= out_r;
            else
                out <= 0;
        end            
    end
end
endmodule
