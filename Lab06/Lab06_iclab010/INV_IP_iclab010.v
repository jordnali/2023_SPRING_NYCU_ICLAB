//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : INV_IP.v
//   	Module Name : INV_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module INV_IP #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_1, IN_2,
    // Output signals
    OUT_INV
);

// ===============================================================
// Declaration
// ===============================================================
input  [IP_WIDTH-1:0] IN_1, IN_2;
output [IP_WIDTH-1:0] OUT_INV;


// ===============================================================
// parameter & integer 
// ===============================================================
parameter LOOP_IDX = 10;
genvar i;

// ===============================================================
// wire & register  
// ===============================================================
reg [IP_WIDTH-1:0] old_r [0:LOOP_IDX-1];
reg [IP_WIDTH-1:0] r [0:LOOP_IDX-1];
reg [IP_WIDTH-1:0] q [0:LOOP_IDX-1];
reg signed [IP_WIDTH-1:0] old_t [0:LOOP_IDX-1];
reg [3:0] index [1:LOOP_IDX-1];
reg signed [IP_WIDTH-1:0] t [0:LOOP_IDX-1];
//reg en;
//old_r
generate
for(i=0;i<LOOP_IDX;i=i+1) begin: loop_old_r
    always@(*) begin
        if(i==0) begin
            old_r[0] = (IN_1 > IN_2)? IN_1:IN_2;
        end
        else begin
            old_r[i] = r[i-1];        
        end
    end
end
endgenerate

//r
generate
for(i=0;i<LOOP_IDX;i=i+1) begin: loop_r
    always@(*) begin
        if(i==0) begin
            r[0] = (IN_1 > IN_2)? IN_2:IN_1;
        end
        else begin
            if(r[i-1]!=0)
                r[i] = old_r[i-1] - q[i-1] * r[i-1];
            else
                r[i] = 0;
        end
    end
end
endgenerate

// assign r[0] = (IN_1 > IN_2)? IN_2:IN_1; 
// assign r[1] = old_r
// assign r[2] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[3] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[4] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[5] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[6] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[7] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[8] = (IN_1 > IN_2)? IN_2:IN_1;
// assign r[9] = (IN_1 > IN_2)? IN_2:IN_1;

// generate
// for(i=0;i<=LOOP_IDX;i=i+1) begin: loop_en
//     always@(*) begin
//         if(i>0)
//             en = ((old_r[i-1] - q[i-1] * r[i-1])!=0);
//         else
//             en = 0;
//     end
// end
// endgenerate
//q


generate
for(i=0;i<LOOP_IDX;i=i+1) begin: loop_q
    always@(*) begin
        if(r[i]!=0)
            q[i] = old_r[i] / r[i];
        else
            q[i] = 0;
    end
end
endgenerate

//old_t

generate
for(i=0;i<LOOP_IDX;i=i+1) begin: loop_old_t
    always@(*) begin
        if(i==0) begin
            old_t[0] = 0;    
        end
        else begin
            if(r[i-1]!=0) begin
                old_t[i] = t[i-1];
            end
            else
                old_t[i] = 0;
        end
    end
end
endgenerate

//index
generate
for(i=1;i<LOOP_IDX;i=i+1) begin: loop_index
    always@(*) begin
            if(r[i-1]!=0) begin
                index[i] = i;
            end
            else
                index[i] = index[i-1];
    end
end
endgenerate


//t

generate
for(i=0;i<LOOP_IDX;i=i+1) begin: loop_t
    always@(*) begin
        if(i==0) begin
            t[0] = 1;    
        end
        else begin
            if(r[i-1]!=0)
                t[i] = old_t[i-1] - q[i-1] * t[i-1];
            else
                t[i] = 0;
        end
    end
end
endgenerate


assign OUT_INV = (old_t[index[LOOP_IDX-1]][IP_WIDTH-1]==1)? old_t[index[LOOP_IDX-1]]+old_r[0]:old_t[index[LOOP_IDX-1]];
endmodule