`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif


module PATTERN(
    // Output Signals
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    // Input Signals
    out_valid,
    out
);


/* Input for design */
output reg       clk, rst_n;
output reg       in_valid;
output reg [1:0] init;
output reg [1:0] in0, in1, in2, in3; 


/* Output for pattern */
input            out_valid;
input      [1:0] out; 

//================================================================
// parameters & integer
//================================================================
integer i;
integer j;
integer t;
integer cycles;
integer in_read;
integer out_read;
integer total_cycles;
integer PATNUM=200;
integer seed = 32;
integer patcount;
integer total_pat;
integer index_row;
integer index_col;
integer max_cycles;
//================================================================
// wire & registers 
//================================================================
reg [1:0] map0 [0:63];
reg [1:0] map1 [0:63];
reg [1:0] map2 [0:63];
reg [1:0] map3 [0:63];
reg [1:0] train_num [0:7];
reg [1:0] array [0:3][0:63];
//================================================================
// clock
//================================================================
real CYCLE = `CYCLE_TIME;

initial clk=0;
always #(CYCLE/2.0) clk = ~clk;
//================================================================
// initial
//================================================================
initial begin
    rst_n = 1'b1;
	in_valid = 1'b0;
	init = 'dx;
    in0 = 'dx;
    in1 = 'dx;
    in2 = 'dx;
    in3 = 'dx;
	force clk = 0;

 	total_cycles = 0;
    total_pat = 0;
    max_cycles = 0;
 	
	reset_signal_task;
    repeat(2) @(negedge clk);

	for(patcount=0; patcount<PATNUM; patcount=patcount+1) 
	begin
		input_task;
		wait_out_valid;
		check_ans;

        total_pat = total_pat+1;
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %5d\033[m", patcount ,cycles);
	end	
  	YOU_PASS_task;
end
//================================================================
// task
//================================================================
//reset_signal_task
task reset_signal_task; 
begin 
  #(0.5);  rst_n=0;
  #(2.0);
  if((out_valid !== 0)||(out !== 0)) 
  begin
    $display("**************************************************************");
    $display("*                     SPEC 3 IS FAIL!                        *");
    $display("**************************************************************");
    repeat(2) #CYCLE;
    $finish;
  end
  #(10);  rst_n=1;
  #(3);  release clk;
end 
endtask

//input_task
task input_task; begin
    t = $urandom_range(2, 4);
    for(i = 0; i < t; i = i + 1)begin
    	if(out !=='d0) begin 
    	    $display("**************************************************************");
            $display("*                     SPEC 4 IS FAIL!                        *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
    	    $finish;
    	end    	
		@(negedge clk);
	end
    in_valid = 1;
    gen_input;
    for(i=0;i<=63;i=i+1) begin
        if (out!==0) begin 
            $display("**************************************************************");
            $display("*                     SPEC 4 IS FAIL!                        *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
            $finish;
        end
        if(out_valid===1) begin
            $display("**************************************************************");
            $display("*                     SPEC 5 IS FAIL!                       *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
            $finish;
        end

        if(i==0) begin
            if(map0[0]!=2'b11) begin
                init = 0;
                index_row = 0;
            end
            else if(map1[0]!=2'b11) begin
                init = 1;
                index_row = 1;
            end
            else if(map2[0]!=2'b11) begin
                init = 2;
                index_row = 2;
            end
            else if(map3[0]!=2'b11) begin
                init = 3;
                index_row = 3;
            end
        end
        else 
            init = 'dx;
        
        in0 = map0[i];
        in1 = map1[i];
        in2 = map2[i];
        in3 = map3[i];

        @(negedge clk);
    end
    in_valid = 0;
    in0 = 'dx;
    in1 = 'dx;
    in2 = 'dx;
    in3 = 'dx;

end endtask

//gen_input
task gen_input; begin
    for(i=0;i<=7;i=i+1) begin
        train_num[i] = 0;
    end

    for(i=0;i<=63;i=i+1) begin
        map0[i] = 0;
        map1[i] = 0;
        map2[i] = 0;
        map3[i] = 0;
    end

    for(i=0;i<=7;i=i+1) begin
        t = $random(seed)%'d2;
        if(t==1) begin
            train_num[i] = train_num[i]+1;
            for(j=0;j<=3;j=j+1)
                map0[8*i+j] = 2'b11;
        end
        else begin
            t = $random(seed)%'d3;
            map0[2+8*i] = t;
 
        end
        t = $random(seed)%'d3;
        map0[4+8*i] = t;
        t = $random(seed)%'d3;
        map0[6+8*i] = t;
    end

    for(i=0;i<=7;i=i+1) begin
        t = $random(seed)%'d2;
        if(t==1) begin
            train_num[i] = train_num[i]+1;
            for(j=0;j<=3;j=j+1)
                map1[8*i+j] = 2'b11;
        end
        else begin
            t = $random(seed)%'d3;
            map1[2+8*i] = t;
 
        end
        t = $random(seed)%'d3;
        map1[4+8*i] = t;
        t = $random(seed)%'d3;
        map1[6+8*i] = t;
    end

    for(i=0;i<=7;i=i+1) begin
        t = $random()%'d2;
        if(t==1) begin
            train_num[i] = train_num[i]+1;
            for(j=0;j<=3;j=j+1)
                map2[8*i+j] = 2'b11;
        end
        else begin
            t = $random(seed)%'d3;
            map2[2+8*i] = t;
 
        end
        t = $random(seed)%'d3;
        map2[4+8*i] = t;
        t = $random(seed)%'d3;
        map2[6+8*i] = t;
    end

    for(i=0;i<=7;i=i+1) begin
        if(train_num[i]==0) begin
            for(j=0;j<=3;j=j+1)
                map3[8*i+j] = 2'b11;
        end
        else if(train_num[i]==3) begin
            t = $random()%'d3;
            map3[2+8*i] = t;
        end
        else begin
            t = $random(seed)%'d2;
            if(t==1) begin
                train_num[i] = train_num[i]+1;
                for(j=0;j<=3;j=j+1)
                    map3[8*i+j] = 2'b11;
            end
            else begin
                t = $random(seed)%'d3;
                map3[2+8*i] = t;
            end
        end
        
        t = $random(seed)%'d3;
        map3[4+8*i] = t;
        t = $random(seed)%'d3;
        map3[6+8*i] = t;
    end

    for(i=0;i<=63;i=i+1) begin
        array[0][i] = map0[i];
        array[1][i] = map1[i];
        array[2][i] = map2[i];
        array[3][i] = map3[i];
    end
end endtask

//wait_out_valid
task wait_out_valid; begin
    cycles = 0;
    while(out_valid!==1) begin
        cycles = cycles + 1;
        if (out!==0) begin 
            $display("**************************************************************");
            $display("*                     SPEC 4 IS FAIL!                        *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
            $finish;
        end
        if(cycles==3000) begin
            $display("**************************************************************");
            $display("*                     SPEC 6 IS FAIL!                        *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_cycles = total_cycles+cycles;
end endtask

integer cycles_ans;
//check_ans
task check_ans; begin
    cycles_ans = 0;
    index_col = 0;
    while(out_valid===1) begin
        cycles_ans = cycles_ans+1;
        if(cycles_ans>63 || out==='dx || out==='dz) begin
            $display("**************************************************************");
            $display("*                     SPEC 7 IS FAIL!                        *");
            $display("**************************************************************");
            repeat(2)  @(negedge clk);
            $finish;
        end
        spec_8;
        index_col = index_col+1;
        if(out===2'd2)
            index_row = index_row-1;
        else if(out===2'd1)
            index_row = index_row+1;

       @(negedge clk); 
    end
    
end endtask

task spec_8; begin
    if(index_row==0) begin
            if(out===2'd2)begin
                fail_8_1;
            end
        end
        if(index_row==3) begin
            if(out===2'd1) begin
                fail_8_1;
            end
        end

        if(out===2'd2) begin
            if(array[index_row-1][index_col+1]==2'b01) begin
                fail_8_2;
            end
            else if(array[index_row-1][index_col+1]==2'b10) begin
                fail_8_3;
            end
            else if(array[index_row-1][index_col+1]==2'b11) begin
                fail_8_4;
            end
        end
        else if(out===2'd1) begin
            if(array[index_row+1][index_col+1]==2'b01) begin
                fail_8_2;
            end
            else if(array[index_row+1][index_col+1]==2'b10) begin
                fail_8_3;
            end
            else if(array[index_row+1][index_col+1]==2'b11) begin
                fail_8_4;
            end
        end
        else if(out===2'd0) begin
            if(array[index_row][index_col+1]==2'b01) begin
                fail_8_2;
            end
            else if(array[index_row][index_col+1]==2'b11) begin
                fail_8_4;
            end
        end
        else if(out===2'd3) begin
            if(array[index_row][index_col+1]==2'b10) begin
                fail_8_3;
            end
            else if(array[index_row][index_col+1]==2'b11) begin
                fail_8_4;
            end
        end

        if(array[index_row][index_col]==2'd01) begin
            if(out===2'd3) begin
                $display("**************************************************************");
                $display("*                     SPEC 8-5 IS FAIL!                      *");
                $display("**************************************************************");
                repeat(2)  @(negedge clk);
                $finish;
            end
        end
end endtask

task fail_8_1; begin
    $display("**************************************************************");
    $display("*                     SPEC 8-1 IS FAIL!                      *");
    $display("**************************************************************");
    repeat(2)  @(negedge clk);
    $finish;
end endtask

task fail_8_2; begin
    $display("**************************************************************");
    $display("*                     SPEC 8-2 IS FAIL!                      *");
    $display("**************************************************************");
    repeat(2)  @(negedge clk);
    $finish;
end endtask

task fail_8_3; begin
    $display("**************************************************************");
    $display("*                     SPEC 8-3 IS FAIL!                      *");
    $display("**************************************************************");
    repeat(2)  @(negedge clk);
    $finish;
end endtask

task fail_8_4; begin
    $display("**************************************************************");
    $display("*                     SPEC 8-4 IS FAIL!                      *");
    $display("**************************************************************");
    repeat(2)  @(negedge clk);
    $finish;
end endtask

task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------------------------------");
    $display ("                                   Congratulations!                                         ");
    $display ("                             You have passed all patterns!                                  ");
    $display ("                                                                                            ");
    $display ("                             Your total_cycles   = %5d cycles                               ", total_cycles);
    $display ("                             Your clock period   = %.1f ns                                  ", `CYCLE_TIME);
    $display ("                             Yout Total latency  = %.1f ns                                  ", total_cycles *`CYCLE_TIME);
    $display ("                             Your maximum cycles = %5d cycles         					   ", max_cycles);
    $display ("--------------------------------------------------------------------------------------------");
        
    repeat(2)@(negedge clk);
    $finish;
end endtask

//================================================================
// always
//================================================================
always @(*) begin
	if(cycles > max_cycles) begin
		max_cycles = cycles;
	end 
end

endmodule