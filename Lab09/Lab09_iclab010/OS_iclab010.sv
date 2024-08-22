module OS(input clk, INF.OS_inf inf);
import usertype::*;

//================================
//       VARIABLES
//================================
typedef enum logic [3:0] { 
	No_Err					= 4'b0000, 
	INV_Not_Enough	= 4'b0010, //	Seller's inventory is not enough
	Out_of_money		= 4'b0011, //	Out of money
	INV_Full				= 4'b0100, //	User's inventory is full 
	Wallet_is_Full	= 4'b1000, //	Wallet is full
	Wrong_ID				= 4'b1001, //	Wrong seller ID 
	Wrong_Num				= 4'b1100, //	Wrong number
	Wrong_Item			= 4'b1010, //	Wrong item
	Wrong_act				= 4'b1111  //	Wrong operation
}	Msg ;
//FSM
typedef enum logic [3:0] {
    S_IDLE,
    S_BUY,
    S_BUY_CAL,
    S_BUY_CAL2, 
    S_BUY_CAL3,
    S_CHECK,
    S_CHECK_USER,
    S_CHECK_SELLER,
    S_CHECK_SELLER2,
    S_DEPOSIT,
    S_DEPOSIT_CAL,
    S_RETURN,
    S_RETURN_CAL,
    S_RETURN_CAL2,
    S_RETURN_CAL3,
    S_OUT
} STATE;
STATE current_state, next_state;
//INPUT
User_id buyer_id, seller_id;
Action act;
Msg out_msg;
User_Level user_level;
Item_id item_id;
Item_num item_num;
Money money;
//FLAG
logic flag_buyer, flag_seller, flag_act, flag_item, flag_num, flag_amnt;
//AXI
Shop_Info buyer_shop_info, seller_shop_info;
User_Info buyer_user_info, seller_user_info;
logic [1:0] cnt_in;
logic flag_data1;
//BUY
logic [5:0] exp;
EXP total_exp;
logic [8:0] price;
logic [6:0] delivery_fee;
Money total_cost, cost;
logic [1:0] cnt_buy_cal2;
//RETURN
logic [1:0] cnt_return_cal2;
//DEPOSIT
logic [2:0] cnt_check;
logic flag_check_user;
//DEPOSIT
logic [1:0] cnt_deposit_cal;
//RECORD
typedef logic [255:0] Id_re;
typedef enum logic [1:0] {
    Buy_re   = 2'd1,
    Sell_re  = 2'd2,
    Other_re = 2'd3
} Operation;

typedef struct packed {
    Id_re     id_re;
    Operation operation;    
} Recording;

Recording [0:255] recording;
//================================
//       FSM
//================================


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) current_state <= S_IDLE;
    else current_state <= next_state;
end

always_comb begin 
    case(current_state)
        S_IDLE: begin
            if(inf.act_valid) begin
                case(inf.D.d_act[0])
                    Buy:    next_state = S_BUY;
                    Check:  next_state = S_CHECK;
                    Deposit:next_state = S_DEPOSIT;
                    Return: next_state = S_RETURN;
                    default:next_state = S_IDLE;
                endcase
            end
            else next_state = S_IDLE;
        end
        S_BUY:begin
            if(flag_buyer) next_state = (flag_data1 && flag_seller)? S_BUY_CAL:S_BUY;
            else           next_state = (flag_seller)?               S_BUY_CAL:S_BUY;
        end
        S_BUY_CAL: next_state = (inf.C_out_valid)? S_BUY_CAL2:S_BUY_CAL;
        S_BUY_CAL2: begin
            if(cnt_buy_cal2==1 && out_msg!=No_Err) next_state = S_OUT;
            else                                     next_state = inf.C_out_valid? S_BUY_CAL3:S_BUY_CAL2;
        end
        S_BUY_CAL3:                                  next_state = inf.C_out_valid? S_OUT:S_BUY_CAL3;
        S_CHECK: begin
            if(flag_buyer) begin
                if(flag_data1 && cnt_check==7 && !flag_seller)     next_state = S_CHECK_USER;
                else if(flag_data1 && cnt_check==7 && flag_seller) next_state = S_CHECK_SELLER;
                else                                               next_state = S_CHECK;
            end      
            else begin
                if(cnt_check==7 && !flag_seller)                   next_state = S_CHECK_USER;
                else if(cnt_check==7 && flag_seller)               next_state = S_CHECK_SELLER;
                else                                               next_state = S_CHECK;
            end
        end 
        S_CHECK_USER:    next_state = S_OUT;
        S_CHECK_SELLER:  next_state = inf.C_out_valid? S_CHECK_SELLER2:S_CHECK_SELLER;
        S_CHECK_SELLER2: next_state = S_OUT;
        S_DEPOSIT: begin
            if(flag_buyer) next_state = (flag_data1 && flag_amnt)? S_DEPOSIT_CAL:S_DEPOSIT;
            else           next_state = (flag_amnt)?               S_DEPOSIT_CAL:S_DEPOSIT;
        end
        S_DEPOSIT_CAL: begin
            if(cnt_deposit_cal==1 && out_msg!=No_Err) next_state = S_OUT;
            else                                        next_state = inf.C_out_valid? S_OUT:S_DEPOSIT_CAL;
        end
        S_RETURN:begin
            if(flag_buyer) next_state = (flag_data1 && flag_seller)? S_RETURN_CAL:S_RETURN;
            else           next_state = (flag_seller)?               S_RETURN_CAL:S_RETURN;
        end
        S_RETURN_CAL:      next_state = (inf.C_out_valid)? S_RETURN_CAL2:S_RETURN_CAL;
        S_RETURN_CAL2: begin
            if(cnt_return_cal2==1 && out_msg!=No_Err) next_state = S_OUT;
            else                                        next_state = inf.C_out_valid? S_RETURN_CAL3:S_RETURN_CAL2;
        end
        S_RETURN_CAL3:                                  next_state = inf.C_out_valid? S_OUT:S_RETURN_CAL3;
        S_OUT:next_state = S_IDLE;
        default: next_state = S_IDLE;
    endcase
end
//================================
//      Input
//================================

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) buyer_id <= 0;
    else begin
        if(current_state==S_IDLE && inf.id_valid)
            buyer_id <= inf.D.d_id[0];
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) seller_id <= 0;
    else begin
        if(current_state!=S_IDLE && inf.id_valid)
            seller_id <= inf.D.d_id[0];
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) act <= No_action;
    else begin
        if(inf.act_valid)
            act <= inf.D.d_act[0]; 
    end 
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) item_id <= No_item;
    else begin
        if(inf.item_valid)
            item_id <= inf.D.d_item[0];
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) item_num <= 0;
    else begin
        if(inf.num_valid)
            item_num <= inf.D.d_item_num;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) money <= 0;
    else begin
        if(inf.amnt_valid)
            money <= inf.D.d_money; 
    end
end


//================================
//      Flag
//================================

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_buyer <= 0;
    else begin
        if(current_state==S_IDLE && inf.id_valid)
            flag_buyer <= 1;
        else if(next_state==S_OUT)
            flag_buyer <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_seller <= 0;
    else begin
        if(current_state!=S_IDLE && inf.id_valid)
            flag_seller <= 1;
        else if(next_state==S_OUT)
            flag_seller <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_act <= 0;
    else begin
        if(inf.act_valid)
            flag_act <= 1;
        else if(next_state==S_OUT) 
            flag_act <= 0;
    end 
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_item <= 0;
    else begin
        if(inf.item_valid)
            flag_item <= 1;
        else if(next_state==S_OUT)
            flag_item <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_num <= 0;
    else begin
        if(inf.num_valid)
            flag_num <= 1;
        else if(next_state==S_OUT)
            flag_num <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_amnt <= 0;
    else begin
        if(inf.amnt_valid)
            flag_amnt <= 1;
        else if(next_state==S_OUT) 
            flag_amnt <= 0;
    end
end
//================================
//      AXI
//================================

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)  flag_data1 <= 0;
    else begin
        if(next_state==S_OUT)
            flag_data1 <= 0;
        else if(inf.C_out_valid)
            flag_data1 <= 1;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cnt_in <= 0;
    else begin
        if((next_state==S_BUY_CAL && cnt_in<=1) || (next_state==S_CHECK_SELLER && cnt_in<=1) || (next_state==S_RETURN_CAL && cnt_in<=1))
            cnt_in <= cnt_in + 1;
        else if(next_state==S_OUT)
            cnt_in <= 0;
    end
end
//C_in_valid
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.C_in_valid <= 0;
    else begin
        case(current_state)
        S_IDLE   :                                    inf.C_in_valid <= (inf.id_valid)? 1:0;
        S_BUY_CAL, S_CHECK_SELLER, S_RETURN_CAL:      inf.C_in_valid <= (cnt_in==1)?    1:0;
        S_BUY_CAL2:                                   inf.C_in_valid <= (cnt_buy_cal2==2 && out_msg==No_Err || inf.C_out_valid)? 1:0; 
        S_BUY_CAL3, S_RETURN_CAL3:                    inf.C_in_valid <= 0; 
        S_DEPOSIT_CAL:                                inf.C_in_valid <= (cnt_deposit_cal==2 && out_msg==No_Err)? 1:0;
        S_RETURN_CAL2:                                inf.C_in_valid <= (cnt_return_cal2==2 && out_msg==No_Err || inf.C_out_valid)? 1:0;
        endcase
    end
end
//C_addr
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.C_addr <= 0;
    else begin
        if((current_state==S_IDLE && inf.id_valid) || (current_state!=S_IDLE && inf.id_valid))
            inf.C_addr <= inf.D.d_id[0];
        else if((current_state==S_BUY_CAL2 && cnt_buy_cal2==2 && out_msg==No_Err) || (current_state==S_DEPOSIT_CAL && cnt_deposit_cal==2 && out_msg==No_Err) || (current_state==S_RETURN_CAL2 && cnt_return_cal2==2 && out_msg==No_Err))
            inf.C_addr <= buyer_id;
        else if((current_state==S_BUY_CAL2 && inf.C_out_valid) || (current_state==S_RETURN_CAL2 && inf.C_out_valid))
            inf.C_addr <= seller_id;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.C_data_w <= 0;
    else begin
        if((current_state==S_BUY_CAL2 && cnt_buy_cal2==2 && out_msg==No_Err) || (current_state==S_DEPOSIT_CAL && cnt_deposit_cal==2 && out_msg==No_Err) || (current_state==S_RETURN_CAL2 && cnt_return_cal2==2 && out_msg==No_Err)) begin
            inf.C_data_w <= {buyer_user_info[7:0], buyer_user_info[15:8] , buyer_user_info[23:16] , buyer_user_info[31:24],
                            buyer_shop_info[7:0] , buyer_shop_info[15:8] , buyer_shop_info[23:16] , buyer_shop_info[31:24]};  
        end
        else if (current_state==S_BUY_CAL2 && inf.C_out_valid || (current_state==S_RETURN_CAL2 && inf.C_out_valid)) begin                            
            inf.C_data_w <= {seller_user_info[7:0], seller_user_info[15:8] , seller_user_info[23:16] , seller_user_info[31:24],
                             seller_shop_info[7:0] , seller_shop_info[15:8] , seller_shop_info[23:16] , seller_shop_info[31:24]}; 
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.C_r_wb <= 0;
    else begin
        if(current_state==S_BUY_CAL2 && cnt_buy_cal2==2 && out_msg==No_Err || (current_state==S_DEPOSIT_CAL && cnt_deposit_cal==2 && out_msg==No_Err) || (current_state==S_RETURN_CAL2 && cnt_return_cal2==2 && out_msg==No_Err)) 
            inf.C_r_wb <= 0;
        else if (current_state==S_BUY_CAL2 && inf.C_out_valid || (current_state==S_RETURN_CAL2 && inf.C_out_valid)) 
            inf.C_r_wb <= 0;
        else  inf.C_r_wb <= 1;
    end      
end


// buyer && seller 
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        buyer_shop_info <= 0;
    end
    else begin
        case(current_state)
            S_BUY, S_CHECK, S_DEPOSIT, S_RETURN: begin
                if(inf.C_out_valid)
                    buyer_shop_info <= { inf.C_data_r[7:0] , inf.C_data_r[15:8] , inf.C_data_r[23:16] , inf.C_data_r[31:24] };
            end 
            S_BUY_CAL2:begin
                if(cnt_buy_cal2==1 && out_msg==No_Err) begin
                    case(item_id)
                        Large:  buyer_shop_info.large_num <= buyer_shop_info.large_num + item_num;
                        Medium: buyer_shop_info.medium_num <= buyer_shop_info.medium_num + item_num;
                        Small:  buyer_shop_info.small_num <= buyer_shop_info.small_num + item_num;
                    endcase
                    case(buyer_shop_info.level)
                        Copper: begin
                            if(buyer_shop_info.exp + total_exp >= 'd1000) begin
                                buyer_shop_info.level <= Silver;
                                buyer_shop_info.exp   <= 0;
                            end
                            else buyer_shop_info.exp <= buyer_shop_info.exp + total_exp;
                        end
                        Silver: begin
                            if(buyer_shop_info.exp + total_exp >= 'd2500) begin
                                buyer_shop_info.level <= Gold;
                                buyer_shop_info.exp   <= 0;
                            end
                            else buyer_shop_info.exp <= buyer_shop_info.exp + total_exp;
                        end
                        Gold: begin
                            if(buyer_shop_info.exp + total_exp >= 'd4000) begin
                                buyer_shop_info.level <= Platinum;
                                buyer_shop_info.exp   <= 0;
                            end
                            else buyer_shop_info.exp <= buyer_shop_info.exp + total_exp;
                        end
                    endcase
                end               
            end
            S_RETURN_CAL2:begin
                if(cnt_return_cal2==1 && out_msg==No_Err) begin
                    case(item_id)
                        Large:  buyer_shop_info.large_num <= buyer_shop_info.large_num - item_num;
                        Medium: buyer_shop_info.medium_num <= buyer_shop_info.medium_num - item_num;
                        Small:  buyer_shop_info.small_num <= buyer_shop_info.small_num - item_num;
                    endcase
                end            
            end
        endcase
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        buyer_user_info <= 0;
    end
    else begin
        case(current_state)
            S_BUY, S_CHECK, S_DEPOSIT, S_RETURN: begin
                if(inf.C_out_valid)
                    buyer_user_info <= { inf.C_data_r[39:32] , inf.C_data_r[47:40] , inf.C_data_r[55:48] , inf.C_data_r[63:56] };
            end
            S_BUY_CAL2:begin
                if(cnt_buy_cal2==1 && out_msg==No_Err) begin
                    buyer_user_info.money <= buyer_user_info.money - total_cost;
                    buyer_user_info.shop_history <= {item_id, item_num, seller_id};
                end
            end
            S_DEPOSIT_CAL:begin
                if(cnt_deposit_cal==1 && out_msg==No_Err) begin
                    buyer_user_info.money <= buyer_user_info.money + money;
                end
            end
            S_RETURN_CAL2: begin
                if(cnt_return_cal2==1 && out_msg==No_Err) begin
                    buyer_user_info.money <= buyer_user_info.money + cost;
                end
            end
        endcase
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        seller_shop_info <= 0;
    end
    else begin
        case(current_state)
            S_BUY_CAL, S_CHECK_SELLER, S_RETURN_CAL: begin
                if(inf.C_out_valid)
                    seller_shop_info <= { inf.C_data_r[7:0] , inf.C_data_r[15:8] , inf.C_data_r[23:16] , inf.C_data_r[31:24] };
            end
            S_BUY_CAL2:begin
                if(cnt_buy_cal2==1 && out_msg==No_Err) begin
                    case(item_id)
                        Large:  seller_shop_info.large_num  <= seller_shop_info.large_num - item_num;
                        Medium: seller_shop_info.medium_num <= seller_shop_info.medium_num - item_num;
                        Small:  seller_shop_info.small_num  <= seller_shop_info.small_num - item_num;
                    endcase
                end
            end
            S_RETURN_CAL2:begin
                if(cnt_return_cal2==1 && out_msg==No_Err) begin
                    case(item_id)
                        Large:  seller_shop_info.large_num  <= seller_shop_info.large_num + item_num;
                        Medium: seller_shop_info.medium_num <= seller_shop_info.medium_num + item_num;
                        Small:  seller_shop_info.small_num  <= seller_shop_info.small_num + item_num;
                    endcase
                end
            end
        endcase
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        seller_user_info <= 0;
    end
    else begin
        case(current_state)
            S_BUY_CAL, S_CHECK_SELLER, S_RETURN_CAL: begin
                if(inf.C_out_valid)
                    seller_user_info <= { inf.C_data_r[39:32] , inf.C_data_r[47:40] , inf.C_data_r[55:48] , inf.C_data_r[63:56] };
            end
            S_BUY_CAL2:begin
                if(cnt_buy_cal2==1 && out_msg==No_Err) begin
                    if(seller_user_info.money + cost <= 'd65535) seller_user_info.money  <= seller_user_info.money + cost;
                    else                                         seller_user_info.money  <= 'd65535;
                end
            end
            S_RETURN_CAL2: begin
                if(cnt_return_cal2==1 && out_msg==No_Err) begin
                    seller_user_info.money  <= seller_user_info.money - cost;
                end
            end
        endcase
    end
end
//================================
//     BUY
//================================
//exp

always_comb begin
    case(item_id)
        Large:   exp = 'd60;
        Medium:  exp = 'd40;
        Small:   exp = 'd20;
        No_item: exp = 0;
    endcase
end

assign total_exp = item_num*exp;
//cost

always_comb begin
    case(item_id)
        Large:   price = 'd300;
        Medium:  price = 'd200;
        Small:   price = 'd100;
        No_item: price = 0;
    endcase
end

always_comb begin
    case(buyer_shop_info.level)
        Platinum:   delivery_fee = 'd10;
        Gold:       delivery_fee = 'd30;
        Silver:     delivery_fee = 'd50;
        Copper:     delivery_fee = 'd70;
    endcase
end

assign cost = item_num*price;
assign total_cost = cost + delivery_fee;


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) out_msg <= No_Err;
    else begin
        case(current_state)
            S_BUY_CAL2: begin
                if(cnt_buy_cal2==0) begin
                    case(item_id)
                        Large: begin
                            if((buyer_shop_info.large_num + item_num) > 63)
                                out_msg <= INV_Full;
                            else if(item_num > seller_shop_info.large_num)
                                out_msg <= INV_Not_Enough;
                            else if(buyer_user_info.money < total_cost)
                                out_msg <= Out_of_money;    
                            else
                                out_msg <= No_Err;
                        end
                        Medium: begin
                            if((buyer_shop_info.medium_num + item_num) > 63)
                                out_msg <= INV_Full;
                            else if(item_num > seller_shop_info.medium_num)
                                out_msg <= INV_Not_Enough;
                            else if(buyer_user_info.money < total_cost)
                                out_msg <= Out_of_money;
                            else
                                out_msg <= No_Err;
                        end
                        Small: begin
                            if((buyer_shop_info.small_num + item_num) > 63)
                                out_msg <= INV_Full;
                            else if(item_num > seller_shop_info.small_num)
                                out_msg <= INV_Not_Enough;
                            else if(buyer_user_info.money < total_cost)
                                out_msg <= Out_of_money;
                            else
                                out_msg <= No_Err;
                        end
                    endcase
                end
            end
            S_CHECK:       out_msg <= No_Err;
            S_DEPOSIT_CAL: if(cnt_deposit_cal==0)  out_msg <= ((buyer_user_info.money+money)>65535)? Wallet_is_Full:No_Err;
            S_RETURN_CAL2: begin
                if(cnt_return_cal2==0) begin
                    if(recording[buyer_id]=={buyer_user_info.shop_history.seller_ID, Buy_re} && recording[buyer_user_info.shop_history.seller_ID]=={buyer_id, Sell_re}) begin
                        if(recording[buyer_id].id_re!=seller_id)                  out_msg <= Wrong_ID;
                        else if(buyer_user_info.shop_history.item_num!=item_num)  out_msg <= Wrong_Num;
                        else if(buyer_user_info.shop_history.item_ID!=item_id)    out_msg <= Wrong_Item;
                        else                                                      out_msg <= No_Err;
                    end
                    else                                                          out_msg <= Wrong_act;
                end
            end
            S_OUT  :       out_msg <= No_Err;
        endcase
    end
    
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cnt_buy_cal2 <= 0;
    else begin
        if(next_state==S_OUT) cnt_buy_cal2 <= 0;
        else if(current_state==S_BUY_CAL2 && cnt_buy_cal2<=2) cnt_buy_cal2 <= cnt_buy_cal2 +1;
    end  
end
//================================
//     RETURN
//================================

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cnt_return_cal2 <= 0;
    else begin
        if(next_state==S_OUT) cnt_return_cal2 <= 0;
        else if(current_state==S_RETURN_CAL2 && cnt_return_cal2<=2) cnt_return_cal2 <= cnt_return_cal2 +1;
    end  
end
//================================
//     CHECK
//================================

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cnt_check <= 0;
    else begin
        if(next_state==S_OUT)   cnt_check <= 0;
        else if(flag_act && cnt_check<=6) cnt_check <= cnt_check + 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) flag_check_user <= 0;
    else begin
        if(current_state==S_CHECK && cnt_check && !inf.id_valid) flag_check_user <= 1;
        else if(next_state==S_OUT)                               flag_check_user <= 0;
    end
end
//================================
//     DEPOSIT
//================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) cnt_deposit_cal <= 0;
    else begin
        if(next_state==S_OUT) cnt_deposit_cal <= 0;
        else if(current_state==S_DEPOSIT_CAL && cnt_deposit_cal<=2) 
            cnt_deposit_cal <= cnt_deposit_cal +1;       
    end  
end
//================================
//      Record
//================================
integer i;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        for(i=0; i<=255; i=i+1)
            recording[i] <= 0;
    end
    else begin
        if(current_state==S_BUY_CAL2 && cnt_buy_cal2==1 && out_msg==No_Err) begin
            recording[buyer_id].operation  <= Buy_re;
            recording[buyer_id].id_re      <= seller_id;
            recording[seller_id].operation <= Sell_re;
            recording[seller_id].id_re     <= buyer_id;
        end
        else if(current_state==S_CHECK_USER) begin
            recording[buyer_id].operation <= Other_re;
        end
        else if(current_state==S_CHECK_SELLER2) begin
            recording[buyer_id].operation <= Other_re;
            recording[seller_id].operation <= Other_re;
        end
        else if(current_state==S_DEPOSIT_CAL && cnt_deposit_cal==1 && out_msg==No_Err) begin
            recording[buyer_id].operation  <= Other_re;
        end
        else if(current_state==S_RETURN_CAL2 && cnt_return_cal2==1 && out_msg==No_Err) begin
            recording[buyer_id].operation <= Other_re;
            recording[seller_id].operation <= Other_re;
        end
    end
end
//================================
//     OUTPUT
//================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.err_msg <= No_Err;
    else begin
        if(next_state==S_OUT)  inf.err_msg <= out_msg;
        else                   inf.err_msg <= No_Err;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.complete <= 0;
    else begin
        if(next_state==S_OUT && out_msg==No_Err)  inf.complete <= 1;
        else                                        inf.complete <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.out_valid <= 0;
    else begin
        if(next_state==S_OUT) inf.out_valid <= 1;
        else                    inf.out_valid <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.out_info <= 0;
    else begin
        if(next_state==S_OUT && out_msg==No_Err) begin
            case(current_state)
                S_BUY_CAL3 :    inf.out_info <= buyer_user_info;
                S_CHECK_USER:   inf.out_info <= buyer_user_info.money;
                S_CHECK_SELLER2:inf.out_info <= {seller_shop_info.large_num, seller_shop_info.medium_num, seller_shop_info.small_num};
                S_DEPOSIT_CAL:  inf.out_info <= buyer_user_info.money;
                S_RETURN_CAL3:  inf.out_info <= {buyer_shop_info.large_num, buyer_shop_info.medium_num, buyer_shop_info.small_num};
            endcase 
        end
        else inf.out_info <= 0;
    end
end
endmodule