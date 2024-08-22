//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//covergroup Spec1 @();
//	
//       finish your covergroup here
//	
//	
//endgroup

//declare other cover group

//declare the cover group 
//Spec1 cov_inst_1 = new();
covergroup Spec1 @(posedge clk && inf.amnt_valid);
    option.at_least = 10;
    option.per_instance = 1;
    coverpoint inf.D.d_money  {
        bins money1 = {[    0:12000]};
        bins money2 = {[12001:24000]};
        bins money3 = {[24001:36000]};
        bins money4 = {[36001:48000]};
        bins money5 = {[48001:60000]};
    }
endgroup

covergroup Spec2 @(posedge clk && inf.id_valid);
    option.at_least = 2;
    option.per_instance = 1;
    coverpoint inf.D.d_id[0] {
        option.auto_bin_max = 256;
    } 
endgroup

covergroup Spec3 @(posedge clk && inf.act_valid);
    option.at_least = 10;
    option.per_instance = 1;
    coverpoint inf.D.d_act[0] {
        bins act1[] = (Buy, Check, Deposit, Return => Buy, Check, Deposit, Return);
    }
endgroup

covergroup Spec4 @(posedge clk && inf.item_valid);
    option.at_least = 20;
    option.per_instance = 1;
    coverpoint inf.D.d_item[0] {
        bins item1 = {Large};
        bins item2 = {Medium};
        bins item3 = {Small};
    }
endgroup


covergroup Spec5 @(negedge clk && inf.out_valid);
    option.at_least = 20;
    option.per_instance = 1;
    coverpoint inf.err_msg {
        bins msg1 = {INV_Not_Enough};
        bins msg2 = {Out_of_money};
        bins msg3 = {INV_Full};
        bins msg4 = {Wallet_is_Full};
        bins msg5 = {Wrong_ID};
        bins msg6 = {Wrong_Num};
        bins msg7 = {Wrong_Item};
        bins msg8 = {Wrong_act};
    } 
endgroup

covergroup Spec6 @(negedge clk && inf.out_valid);
    option.at_least = 200;
    option.per_instance = 1;
    coverpoint inf.complete {
        bins comp[] = {0, 1};
    }
endgroup

Spec1 cov_inst_1 = new(); 
Spec2 cov_inst_2 = new(); 
Spec3 cov_inst_3 = new(); 
Spec4 cov_inst_4 = new(); 
Spec5 cov_inst_5 = new(); 
Spec6 cov_inst_6 = new(); 

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions

//1. All outputs signals (including OS.sv and bridge.sv) should be zero after reset.
wire #(0.1) rst_reg = inf.rst_n;
always @(negedge rst_reg) begin
    assert_1: assert ( (inf.out_valid===0) && (inf.err_msg===No_Err) && (inf.complete===0) && (inf.out_info===0) &&
                       (inf.C_addr===0) && (inf.C_data_w===0) && (inf.C_in_valid===0) && (inf.C_r_wb===0) &&
                       (inf.C_out_valid===0) && (inf.C_data_r===0) && 
                       (inf.AR_VALID===0) && (inf.AR_ADDR===0) && (inf.R_READY===0) && (inf.AW_VALID===0) && (inf.AW_ADDR===0) && (inf.W_VALID===0) && (inf.W_DATA===0) && (inf.B_READY===0) 
                       )
    else begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end


//2. If action is completed, err_msg must be 4’b0.
assert_2: assert property (@(negedge clk) (inf.complete===1 && inf.out_valid===1) |-> (inf.err_msg===No_Err))
else begin
    $display("Assertion 2 is violated");
    $fatal;
end


//3. If action is not completed, out_info should be 32’b0.
assert_3: assert property (@(negedge clk) (inf.complete===0 && inf.out_valid===1) |-> (inf.out_info===0))
else begin
    $display("Assertion 3 is violated");
    $fatal;
end


//4. All input valid can only be high for exactly one cycle.
assert_4_1: assert property (@(posedge clk) (inf.id_valid===1) |=> (inf.id_valid===0))
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_2: assert property (@(posedge clk) (inf.act_valid===1) |=> (inf.act_valid===0))
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_3: assert property (@(posedge clk) (inf.item_valid===1) |=> (inf.item_valid===0))
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_4: assert property (@(posedge clk) (inf.amnt_valid===1) |=> (inf.amnt_valid===0))
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_5: assert property (@(posedge clk) (inf.num_valid===1) |=> (inf.num_valid===0))
else begin
    $display("Assertion 4 is violated");
    $fatal;
end



//5. The five valid signals won’t overlap with each other.( id_valid, act_valid, amnt_valid, item_valid , num_valid )
assert_5_1: assert property(@(posedge clk) (inf.id_valid===1) |->  (inf.act_valid===0 && inf.amnt_valid===0 && inf.item_valid===0 && inf.num_valid===0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_2: assert property(@(posedge clk) (inf.act_valid===1) |->  (inf.id_valid===0 && inf.amnt_valid===0 && inf.item_valid===0 && inf.num_valid===0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_3: assert property(@(posedge clk) (inf.amnt_valid===1) |->  (inf.id_valid===0 && inf.act_valid===0 && inf.item_valid===0 && inf.num_valid===0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_4: assert property(@(posedge clk) (inf.item_valid===1) |->  (inf.id_valid===0 && inf.act_valid===0 && inf.amnt_valid===0 && inf.num_valid===0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_5: assert property(@(posedge clk) (inf.num_valid===1) |->  (inf.id_valid===0 && inf.act_valid===0 && inf.amnt_valid===0 && inf.item_valid===0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end



//6. The gap between each input valid is at least 1 cycle and at most 5 cycles(including the correct input sequence).
logic flag_act;
Action act;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) 
        flag_act <= 0;
    else begin
        if(inf.out_valid) flag_act <= 0;
        else if (inf.act_valid) flag_act <= 1;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) 
        act <= No_action;
    else begin
        if(inf.out_valid) act <= No_action;
        else if (inf.act_valid) act <= inf.D.d_act[0];
    end
end
//buyer
assert_6_1: assert property (@(posedge clk) (inf.id_valid===1 && !flag_act) |=> ##[1:5] (inf.act_valid===1))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_1_2: assert property (@(posedge clk) (inf.id_valid===1 && !flag_act) |=>  (inf.act_valid===0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
//Buy & Return
assert_6_2: assert property (@(posedge clk) (inf.act_valid===1 && (inf.D.d_act[0]===Buy || inf.D.d_act[0]===Return)) |=> ##[1:5] (inf.item_valid===1))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_2_2: assert property (@(posedge clk) (inf.act_valid===1 && (inf.D.d_act[0]===Buy || inf.D.d_act[0]===Return)) |=>  (inf.item_valid===0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_3: assert property (@(posedge clk) (inf.item_valid===1 && (act==Buy || act==Return)) |=> ##[1:5] (inf.num_valid===1))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_3_2: assert property (@(posedge clk) (inf.item_valid===1 && (act==Buy || act==Return)) |=>  (inf.num_valid===0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_4: assert property (@(posedge clk) (inf.num_valid===1 && (act==Buy || act==Return)) |=> ##[1:5] (inf.id_valid===1))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_4_2: assert property (@(posedge clk) (inf.num_valid===1 && (act==Buy || act==Return)) |=>  (inf.id_valid===0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
//Deposit
assert_6_5: assert property (@(posedge clk) (inf.act_valid===1 && inf.D.d_act[0]===Deposit) |=> ##[1:5] (inf.amnt_valid===1))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_5_2: assert property (@(posedge clk) (inf.act_valid===1 && inf.D.d_act[0]===Deposit) |=>  (inf.amnt_valid===0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
//Check
logic [2:0] cnt_check;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) 
        cnt_check <= 0;
    else begin
        if(inf.out_valid) cnt_check <= 0;
        else if(act===Check && cnt_check<=6)
           cnt_check <= cnt_check + 1;
    end
end
assert_6_6: assert property (@(posedge clk) (act==Check && cnt_check>=6) |-> (inf.id_valid===0) )
else begin
    $display("Assertion 6 is violated");
    $fatal;
end
assert_6_6_2: assert property (@(posedge clk) (inf.act_valid===1 && inf.D.d_act[0]===Check) |=> (inf.id_valid===0) )
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

logic flag_id_act;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_id_act <= 0;
    else begin
        if(inf.id_valid && !flag_act) flag_id_act <= 1;
        else if(inf.act_valid) flag_id_act <= 0;
    end
end

always@(posedge clk) begin
    if(flag_id_act) begin
        assert_6_7: assert (inf.amnt_valid===0 && inf.item_valid===0 && inf.num_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end
logic flag_buy_return;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_buy_return <= 0;
    else begin
        if(inf.act_valid && (inf.D.d_act[0]===Buy || inf.D.d_act[0]===Return)) flag_buy_return <= 1;
        else if(inf.item_valid) flag_buy_return <= 0;
    end
end
logic flag_deposit;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_deposit <= 0;
    else begin
        if(inf.act_valid && inf.D.d_act[0]===Deposit) flag_deposit <= 1;
        else if(inf.amnt_valid) flag_deposit <= 0;
    end
end
logic flag_check;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_check <= 0;
    else begin
        if(inf.act_valid && inf.D.d_act[0]===Check) flag_check <= 1;
        else if(inf.out_valid || inf.id_valid) flag_check <= 0;
    end
end
always@(posedge clk) begin
    if(flag_buy_return) begin
        assert_6_8: assert (inf.id_valid===0 && inf.num_valid===0 && inf.amnt_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
    else if(flag_deposit) begin
        assert_6_9: assert (inf.id_valid===0 && inf.item_valid===0 && inf.num_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
    else if(flag_check) begin
        assert_6_10: assert (inf.item_valid===0 && inf.num_valid===0 && inf.amnt_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end

logic flag_item_id;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_item_id <= 0;
    else begin
        if(inf.item_valid) flag_item_id <= 1;
        else if(inf.num_valid) flag_item_id <= 0;
    end
end
always@(posedge clk) begin
    if(flag_item_id) begin
        assert_6_11: assert (inf.id_valid===0 && inf.act_valid===0 && inf.amnt_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end
logic flag_num;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_num <= 0;
    else begin
        if(inf.num_valid) flag_num <= 1;
        else if(inf.id_valid) flag_num <= 0;
    end
end
always@(posedge clk) begin
    if(flag_num) begin
        assert_6_12: assert (inf.act_valid===0 && inf.item_valid===0 && inf.amnt_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end
logic flag_id_seller;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_id_seller <= 0;
    else begin
        if(inf.id_valid && flag_act) flag_id_seller <= 1;
        else if(inf.out_valid) flag_id_seller <= 0;
    end
end
always@(posedge clk) begin
    if(flag_id_seller) begin
        assert_6_13: assert (inf.act_valid===0 && inf.item_valid===0 && inf.num_valid===0 && inf.amnt_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end
logic flag_amnt;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_amnt <= 0;
    else begin
        if(inf.amnt_valid) flag_amnt <= 1;
        else if(inf.out_valid) flag_amnt <= 0;
    end
end
always@(posedge clk) begin
    if(flag_amnt) begin
        assert_6_14: assert (inf.id_valid===0 && inf.act_valid===0 && inf.item_valid===0 && inf.num_valid===0)
        else begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end


//7. Out_valid will be high for one cycle.
assert_7: assert property(@(negedge clk) (inf.out_valid===1) |=>  inf.out_valid===0)
else begin
    $display("Assertion 7 is violated");
    $fatal;
end

//8. Next operation will be valid 2-10 cycles after out_valid fall.
assert_8: assert property(@(posedge clk) (inf.out_valid===1) |-> ##[2:10] (inf.id_valid===1 || inf.act_valid===1))
else begin
    $display("Assertion 8 is violated");
    $fatal;
end
assert_8_2: assert property(@(posedge clk) (inf.out_valid===1) |->  (inf.id_valid===0 && inf.act_valid===0))
else begin
    $display("Assertion 8 is violated");
    $fatal;
end
assert_8_3: assert property(@(posedge clk) (inf.out_valid===1) |-> ##1 (inf.id_valid===0 && inf.act_valid===0))
else begin
    $display("Assertion 8 is violated");
    $fatal;
end
//9. Latency should be less than 10000 cycle for each operation.
assert_9_1: assert property(@(posedge clk) ((inf.id_valid===1 && (act==Buy || act==Return || act==Check)) ||
                                          (inf.amnt_valid==1 && act==Deposit)
                                          |-> ##[1:10000] (inf.out_valid)===1))
else begin
    $display("Assertion 9 is violated");
    $fatal;
end

logic flag_seller;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) 
        flag_seller <= 0;
    else begin
        if(inf.out_valid) flag_seller <= 0;
        else if(flag_act && inf.id_valid)
           flag_seller <= 1;
    end
end

assert_9_2: assert property(@(posedge clk) (act==Check && cnt_check==6 && !flag_seller) |-> ##[1:9994] (inf.out_valid===1))
else begin
    $display("Assertion 9 is violated");
    $fatal;
end

// assert_9_3: assert property(@(posedge clk) (act==Check && inf.id_valid===1) |=> ##[0:10000] (inf.out_valid===1))
// else begin
//     $display("Assertion 9 is violated");
//     $fatal;
// end
endmodule