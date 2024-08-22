`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
integer seed = 67;
integer pat;
parameter PATNUM = 400;
integer index_seller;
integer index_seller2;
integer index_seller3;
integer index_seller4;
integer index_money;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM[ ((65536+256*8)-1) : (65536+0)];
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
Msg golden_msg;

logic [31:0] golden_out;
logic golden_complete;
//================================================================
// initial
//================================================================
integer cycles;
initial begin
    random_dram_task;
    read_dram_task;
    reset_task;
    for(pat=0; pat<PATNUM; pat=pat+1) begin
        gen_input_task;
        input_task;
        cal_task;
        wait_task;
        check_task;
       //$display("\033[0;34m PATTER NO.%4d\033[m ", pat);
    end
    $finish;
    //pass_task;
end
//================================================================
//    Dram
//================================================================
parameter INPUT_ADDR_OFFSET = 'h10000;
parameter INPUT_ADDR_MAX    = 'h107FC;
integer addr;
integer file_dram;
logic [7:0] dram_num;
logic [7:0] dram_seller;
logic [31:0] data_shop;
logic [31:0] data_user;
task random_dram_task; begin
    dram_num = 0;
    file_dram = $fopen(DRAM_p_r,"w");
    for(addr=INPUT_ADDR_OFFSET ; addr<=INPUT_ADDR_MAX ; addr=addr+'h8) begin
            $fwrite(file_dram, "@%5h\n", addr);

            data_shop = {6'd32, 6'd0, 6'd62, 2'd0, 12'd0}; //large:32 medium:0 small:62 user_level:platinum exp:0
            //shop_info
            $fwrite(file_dram, "%h ", data_shop[31:24]);

            $fwrite(file_dram, "%h ", data_shop[23:16]);

            $fwrite(file_dram, "%h ", data_shop[15:8]);

            $fwrite(file_dram, "%h\n", data_shop[7:0]);

            //user_infp
            dram_seller = dram_num % 255 + 1; //1~255
            data_user = {16'd9300, 2'b11, 6'd1, dram_seller}; //money:9300
            $fwrite(file_dram, "@%5h\n", addr+'h4);

            $fwrite(file_dram, "%h ", data_user[31:24]);

            $fwrite(file_dram, "%h ", data_user[23:16]);

            $fwrite(file_dram, "%h ", data_user[15:8]);

            $fwrite(file_dram, "%h\n", data_user[7:0]);

            dram_num = dram_num + 1;

        end
    $fclose(file_dram);
end endtask

integer i;
Shop_Info [0:255] dram_shop_info;
User_Info [0:255] dram_user_info;
task read_dram_task; begin
    $readmemh(DRAM_p_r, golden_DRAM);
    for(i=0; i<=255; i=i+1) begin
        dram_shop_info[i] = { golden_DRAM['h10000 + i*8], golden_DRAM['h10000 + i*8 +1], golden_DRAM['h10000 + i*8 +2], golden_DRAM['h10000 + i*8 +3]};
        dram_user_info[i] = { golden_DRAM['h10000 + i*8 +4], golden_DRAM['h10000 + i*8 +5], golden_DRAM['h10000 + i*8 +6], golden_DRAM['h10000 + i*8 +7]};
    end
    //$display("%h, %h", dram_shop_info[255], dram_user_info[255]);
end endtask

//**************************************
//      Reset Task
//**************************************
User_id buyer_id, seller_id;
task reset_task; begin
    //force clk = 0;
    inf.rst_n      = 1;
    inf.id_valid   = 0;
    inf.act_valid  = 0;
    inf.item_valid = 0;
    inf.num_valid  = 0;
    inf.amnt_valid = 0;

    inf.D          = 'dx;

    index_seller   = 128;
    index_seller2  = 40;
    index_seller3  = 255;
    index_seller4  = 216;
    index_money    = 10000;
    for(i=0; i<=255; i=i+1) begin
        recording[i] = 0;
    end
    #(1.0) inf.rst_n = 0;
    #(10/2.0) inf.rst_n = 1;

    //#(10/2.0) release clk;
end endtask

//**************************************
//      Input Task
//**************************************
Action act;
Item_id item_id;
Item_num item_num;
Money money;
integer tras_order;
integer re_order;

task gen_input_task; begin
    if(pat<256) buyer_id = pat;
    else buyer_id = pat / 2;
    if(pat<20) begin  //act:Buy item:Medium target:INV_Not_Enough*20  (0~19)
        act       = Buy;
        item_id   = Medium;
        item_num  = 1;
        seller_id = pat + 1 ;
    end
    else if(pat>=20 && pat<40) begin //act:Buy item:Large target:Out_of_money*20 (20~39)
        act       = Buy;
        item_id   = Large;
        item_num  = 31;
        seller_id = pat + 1 ;
    end
    else if(pat>=40 && pat<200) begin //act:B B R R B D D B C C R D R C D C item:Small target:INV_Full & tansition(16*10) (40~199)
        tras_order = pat - 40; //0~159
        if(tras_order % 16 == 0)        act = Buy;
        else if(tras_order % 16 == 1)   act = Buy;
        else if(tras_order % 16 == 2)   act = Return;
        else if(tras_order % 16 == 3)   act = Return;
        else if(tras_order % 16 == 4)   act = Buy;
        else if(tras_order % 16 == 5)   act = Deposit;
        else if(tras_order % 16 == 6)   act = Deposit;
        else if(tras_order % 16 == 7)   act = Buy;
        else if(tras_order % 16 == 8)   act = Check;
        else if(tras_order % 16 == 9)   act = Check;
        else if(tras_order % 16 == 10)  act = Return;
        else if(tras_order % 16 == 11)  act = Deposit;
        else if(tras_order % 16 == 12)  act = Return;
        else if(tras_order % 16 == 13)  act = Check;
        else if(tras_order % 16 == 14)  act = Deposit;
        else if(tras_order % 16 == 15)  begin
            act = Check;
            index_money = (index_money + 12000) % 60000;
        end
        item_id   = Small;
        item_num  = 2;
        if(act==Buy || act==Return) index_seller = index_seller - 1;
        seller_id = index_seller;
        money     = index_money;
    end
    else if(pat>=200 && pat<256) begin //act:Check (200~255)
        act = Check;
    end
    else if(pat>=256 && pat<296)  begin//act:Buy&Return item:Small target:Wrong_Item*20 (256~295)
        re_order = pat - 256; //(0~39)
        if(re_order % 2 ==0) begin       
            act = Buy;
            item_id = Small;
            item_num  = 1;
            seller_id = index_seller3;
        end
        else if(re_order % 2 ==1) begin  
            act = Return; 
            seller_id = index_seller3;
            item_num  = 1;
            item_id   = Large;
            index_seller3 = index_seller3 - 1; 
        end
    end
    else if(pat>=296 && pat<336)  begin//act:Buy&Return item:Small target:Wrong_Num*20 (296~335)
        re_order = pat - 296; //(0~39)
        if(re_order % 2 ==0) begin       
            act = Buy;
            item_id = Small;
            item_num  = 1;
            seller_id = index_seller3;
        end
        else if(re_order % 2 ==1) begin  
            act = Return; 
            seller_id = index_seller3;
            item_num  = 2;
            item_id = Small;
            index_seller3 = index_seller3 - 1;
        end
    end
    else if(pat>=336 && pat<376)  begin//act:Buy&Return item:Small target:Wrong_ID*20 (336~375)
        re_order = pat - 336; //(0~39)
        if(re_order % 2 ==0) begin       
            act = Buy;
            item_id = Small;
            item_num  = 1;
            index_seller4 = index_seller4 - 1;
            seller_id = index_seller4;
        end
        else if(re_order % 2 ==1) begin  
            act = Return; 
            index_seller2 = index_seller2 + 1;
            seller_id = index_seller2 % 48;
            item_num  = 1;
            item_id = Small;
        end
    end
    else if(pat>=376 && pat<394) begin //act:Deposit arget:coverage spec1 (376~393)
        act = Deposit;
        if(pat>=376 && pat<386)       money = 60000;
        else if(pat>=386 && pat<388)  money = 48000;
        else if(pat>=388 && pat<390)  money = 36000;
        else if(pat>=390 && pat<392)  money = 24000;
        else if(pat>=392 && pat<394)  money = 12000;
    end
    else begin //act:Check (394~399)
        act = Check;
        if(pat==399) begin
            seller_id = 0;
        end
    end
end endtask
task input_task; begin
    @(negedge clk);

    if(pat<256) begin
        inf.id_valid = 1'b1;
        inf.D    = buyer_id;
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;
        @(negedge clk);
    end
    else begin
        if(pat%2 == 0) begin
        inf.id_valid = 1'b1;
        inf.D    = buyer_id;
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;
        @(negedge clk);
    end

    end
    
    inf.act_valid = 1'b1;
    inf.D = act;
    @(negedge clk);
    inf.act_valid = 1'b0;
    inf.D = 'dx;
    @(negedge clk);

    case(act) 
        Buy, Return: begin
            //item_id
            inf.item_valid = 1'b1;
            inf.D = item_id;
            @(negedge clk);
            inf.item_valid = 1'b0;
            inf.D = 'dx;
            @(negedge clk);

            //item_num
            inf.num_valid = 1'b1;
            inf.D = item_num;
            @(negedge clk);
            inf.num_valid = 1'b0;
            inf.D = 'dx;
            @(negedge clk);

            //seller_id
            inf.id_valid = 1'b1;
            inf.D = seller_id;
            @(negedge clk);
            inf.id_valid = 1'b0;
            inf.D = 'dx;
        end
        Deposit: begin
            inf.amnt_valid = 1'b1;
            inf.D = money;
            @(negedge clk);
            inf.amnt_valid = 1'b0;
            inf.D = 'dx;
        end
        Check:begin
            if(pat==399) begin
                //seller_id
                inf.id_valid = 1'b1;
                inf.D = seller_id;
                @(negedge clk);
                inf.id_valid = 1'b0;
                inf.D = 'dx;
            end
        end
    endcase
end endtask

//**************************************
//      Cal Task
//**************************************

task cal_task; begin
    golden_out = 0;
    case(act) 
        Buy:begin
            case(item_id)
                Large: begin
                    if(dram_shop_info[buyer_id].large_num + item_num > 63)        golden_msg = INV_Full;
                    else if(dram_shop_info[seller_id].large_num < item_num)       golden_msg = INV_Not_Enough;
                    else if(dram_user_info[buyer_id].money < ('d300*item_num+'d10)) golden_msg = Out_of_money;
                    else begin
                        golden_msg = No_Err;
                        dram_shop_info[buyer_id].large_num = dram_shop_info[buyer_id].large_num + item_num;
                        dram_user_info[buyer_id].money = dram_user_info[buyer_id].money - ('d300*item_num+'d10);
                        dram_user_info[buyer_id].shop_history = {item_id, item_num, seller_id};

                        dram_shop_info[seller_id].large_num = dram_shop_info[seller_id].large_num - item_num;
                        if(dram_user_info[seller_id].money + 'd300*item_num <= 'd65535) dram_user_info[seller_id].money = dram_user_info[seller_id].money + 'd300*item_num;
                        else                                                            dram_user_info[seller_id].money = 'd65535;

                        golden_out = dram_user_info[buyer_id];
                    end
                end
                Medium: begin
                    if(dram_shop_info[buyer_id].medium_num + item_num > 63)         golden_msg = INV_Full;
                    else if(dram_shop_info[seller_id].medium_num < item_num)        golden_msg = INV_Not_Enough;
                    else if(dram_user_info[buyer_id].money < ('d200*item_num+'d10)) golden_msg = Out_of_money;
                    else begin
                        golden_msg = No_Err;
                        dram_shop_info[buyer_id].medium_num = dram_shop_info[buyer_id].medium_num + item_num;
                        dram_user_info[buyer_id].money = dram_user_info[buyer_id].money - ('d200*item_num+'d10);
                        dram_user_info[buyer_id].shop_history = {item_id, item_num, seller_id};

                        dram_shop_info[seller_id].medium_num = dram_shop_info[seller_id].medium_num - item_num;
                        if(dram_user_info[seller_id].money + 'd200*item_num <= 'd65535) dram_user_info[seller_id].money = dram_user_info[seller_id].money + 'd200*item_num;
                        else                                                            dram_user_info[seller_id].money = 'd65535;

                        golden_out = dram_user_info[buyer_id];
                    end
                end
                Small: begin
                    if(dram_shop_info[buyer_id].small_num + item_num > 63)          golden_msg = INV_Full;
                    else if(dram_shop_info[seller_id].small_num < item_num)         golden_msg = INV_Not_Enough;
                    else if(dram_user_info[buyer_id].money < ('d100*item_num+'d10)) golden_msg = Out_of_money;
                    else begin
                        golden_msg = No_Err;
                        dram_shop_info[buyer_id].small_num = dram_shop_info[buyer_id].small_num + item_num;
                        dram_user_info[buyer_id].money = dram_user_info[buyer_id].money - ('d100*item_num+'d10);
                        dram_user_info[buyer_id].shop_history = {item_id, item_num, seller_id};

                        dram_shop_info[seller_id].small_num = dram_shop_info[seller_id].small_num - item_num;
                        if(dram_user_info[seller_id].money + 'd100*item_num <= 'd65535) dram_user_info[seller_id].money = dram_user_info[seller_id].money + 'd100*item_num;
                        else                                                            dram_user_info[seller_id].money = 'd65535;

                        golden_out = dram_user_info[buyer_id];
                    end
                end
            endcase
        end
        Return: begin
            if(recording[buyer_id]=={dram_user_info[buyer_id].shop_history.seller_ID, Buy_re} && recording[dram_user_info[buyer_id].shop_history.seller_ID]=={buyer_id, Sell_re}) begin
                if(recording[buyer_id].id_re!=seller_id)                                   golden_msg = Wrong_ID;
                        else if(dram_user_info[buyer_id].shop_history.item_num!=item_num)  golden_msg = Wrong_Num;
                        else if(dram_user_info[buyer_id].shop_history.item_ID!=item_id)    golden_msg = Wrong_Item;
                        else begin                                                             
                            case(item_id) 
                                Large: begin
                                    //buyer
                                    dram_shop_info[buyer_id].large_num = dram_shop_info[buyer_id].large_num - item_num;
                                    dram_user_info[buyer_id].money = dram_user_info[buyer_id].money + ('d300*item_num); 
                                    
                                    //seller
                                    dram_shop_info[seller_id].large_num = dram_shop_info[seller_id].large_num + item_num;
                                    dram_user_info[seller_id].money = dram_user_info[seller_id].money - 'd300*item_num;
                                end
                                Medium: begin
                                    //buyer
                                    dram_shop_info[buyer_id].medium_num = dram_shop_info[buyer_id].medium_num - item_num;
                                    dram_user_info[buyer_id].money = dram_user_info[buyer_id].money + ('d200*item_num); 
                                    
                                    //seller
                                    dram_shop_info[seller_id].medium_num = dram_shop_info[seller_id].medium_num + item_num;
                                    dram_user_info[seller_id].money = dram_user_info[seller_id].money - 'd200*item_num;
                                end
                                Small: begin
                                    //buyer
                                    dram_shop_info[buyer_id].small_num = dram_shop_info[buyer_id].small_num - item_num;
                                    dram_user_info[buyer_id].money = dram_user_info[buyer_id].money + ('d100*item_num); 
                                    
                                    //seller
                                    dram_shop_info[seller_id].small_num = dram_shop_info[seller_id].small_num + item_num;
                                    dram_user_info[seller_id].money = dram_user_info[seller_id].money - 'd100*item_num;
                                end
                            endcase

                        golden_msg = No_Err;
                        golden_out = {dram_shop_info[buyer_id].large_num, dram_shop_info[buyer_id].medium_num, dram_shop_info[buyer_id].small_num};    
                        end
            end
            else  golden_msg = Wrong_act;
        end
        Check: begin
            if(pat==399) begin
                golden_msg = No_Err;
                golden_out = {dram_shop_info[seller_id].large_num, dram_shop_info[seller_id].medium_num, dram_shop_info[seller_id].small_num}; 
            end
            else begin
                golden_msg = No_Err;
                golden_out = dram_user_info[buyer_id].money;
            end
            
        end
        Deposit: begin
            if(dram_user_info[buyer_id].money + money > 'd65535) golden_msg = Wallet_is_Full;
            else begin
                golden_msg = No_Err;
                dram_user_info[buyer_id].money = dram_user_info[buyer_id].money + money;
                golden_out = dram_user_info[buyer_id].money;
            end
        end
    endcase

    //recording
    case(act)
        Buy: begin
            if(golden_msg==No_Err) begin
                recording[buyer_id].operation  = Buy_re;
                recording[buyer_id].id_re      = seller_id;
                recording[seller_id].operation     = Sell_re;
                recording[seller_id].id_re         = buyer_id;
            end
        end
        Check: begin
            if(pat==399) begin
                recording[buyer_id].operation = Other_re;
                recording[seller_id].operation = Other_re;
            end
            else begin
                recording[buyer_id].operation = Other_re;
            end
                
        end
        Deposit: begin
            if(golden_msg==No_Err) recording[buyer_id].operation = Other_re;
        end
        Return: begin
            if(golden_msg==No_Err) begin
                recording[buyer_id].operation = Other_re;
                recording[seller_id].operation = Other_re;
            end
        end
    endcase

    if(golden_msg==No_Err) begin
        golden_complete = 1;
    end
    else begin
        golden_complete = 0;
    end
end endtask

//**************************************
//      Wait Task
//**************************************
task wait_task; begin
    while(inf.out_valid !== 1) begin
        @(negedge clk);
    end
end endtask

//**************************************
//      Check Task
//**************************************
task check_task; begin
    while(inf.out_valid===1) begin
        if(inf.complete!==golden_complete || inf.err_msg!==golden_msg || inf.out_info!==golden_out) begin
            $display("Wrong Answer");
            $finish;
        end
        @(negedge clk);
    end
end endtask
endprogram