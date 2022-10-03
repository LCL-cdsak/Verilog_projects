module huffman(clk, reset, gray_valid, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
               code_valid, HC1, HC2, HC3, HC4, HC5, HC6,M1, M2, M3, M4, M5, M6,gray_data);
input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;
reg [3:0]current_state,next_state;
reg [13:0]s_table[4:0][5:0]; //13:8 symbol, 7:0 count
reg [7:0]code_table[4:0][5:0];
reg [7:0]mask_table[4:0][5:0];
reg [2:0]record_index[4:0];
reg [2:0]i,j;
wire [2:0] i_add_1,j_add_1;
wire [2:0]record;
assign record = record_index[counter];
assign j_add_1 = (j==4)? 0 : j+1;
parameter read = 0;
parameter init = 1;
parameter sort = 2;
parameter combine = 3;
parameter swap = 4;
parameter temp = 9;
parameter split = 5;
parameter final_sort = 6;
parameter final_assign = 7;
parameter finish = 8;
reg swap_stop;
reg read_flag;
reg [2:0]counter;
reg [2:0]addr_now,addr_next;
always @(*)//next_state logic
begin
    case(current_state)
        read:
            if(read_flag==0 || gray_valid)
                next_state = read;
            else
                next_state = init;
        init:
            next_state = sort;
        sort:
            if(i==5)
                next_state = combine;
            else
                next_state = sort;
        combine:
            next_state = swap;
        swap:
            if(i==4 && swap_stop)
                next_state=temp;
            else if(i<4 && swap_stop)
                next_state=combine;
            else
                next_state = swap;
        temp:
            if(addr_now==5)
                next_state = split;
            else
                next_state = temp;
        split:
            if(counter==1)//釐清
                next_state = final_sort;
            else
                next_state = temp;
        final_sort:
            if(i==5)
                next_state =final_assign;
            else
                next_state = final_sort;
        final_assign:
            next_state = finish;
        default:
            next_state = read;
    endcase
end
always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state<=read;
    else
        current_state<=next_state;
end
always @(posedge clk or posedge reset)//CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
begin
    if(reset)
    begin
        CNT1<=0;
        CNT2<=0;
        CNT3<=0;
        CNT4<=0;
        CNT5<=0;
        CNT6<=0;
    end
    else if(current_state==read)
    begin
        if(gray_valid)
        begin
            case(gray_data)
                1:
                    CNT1<=CNT1+1;
                2:
                    CNT2<=CNT2+1;
                3:
                    CNT3<=CNT3+1;
                4:
                    CNT4<=CNT4+1;
                5:
                    CNT5<=CNT5+1;
                6:
                    CNT6<=CNT6+1;
            endcase
        end
    end
end
//i,j counter
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        i<=0;
        j<=0;
    end
    else if(current_state==sort || current_state==final_sort)
    begin
        j<=j_add_1;
        if(j==4)
            i<=i+1;
        else if(i==5)
            i<=0;
    end
    else if(current_state==combine)
    begin
        if(i==4)
        begin
            i<=0;
        end
        else
            i<=i+1;
    end
    else if(current_state==split)
    begin
        i<=0;
        j<=0;
    end
end
always @(posedge clk or posedge reset) // code_table read_flag mask_table addr_now addr_next
begin
    if(reset)
    begin
        read_flag<=0;
        code_table[4][0]<=0;
        code_table[4][1]<=1;
        code_table[4][2]<=0;
        code_table[4][3]<=0;
        code_table[4][4]<=0;
        code_table[4][5]<=0;
        mask_table[4][0]<=1;
        mask_table[4][1]<=1;
        mask_table[4][2]<=1;
        mask_table[4][3]<=1;
        mask_table[4][4]<=1;
        mask_table[4][5]<=1;
        addr_now<=0;
        addr_next<=0;
    end
    else if(current_state==read)
    begin
        if(gray_valid)
            read_flag<=1;
    end
    else if(current_state==temp)
    begin
        if(addr_now!=record)
        begin
            addr_now <= addr_now+1;
            addr_next<=addr_next+1;
            code_table[counter-1][addr_next] <= code_table[counter][addr_now];
            mask_table[counter-1][addr_next] <= mask_table[counter][addr_now];
        end
        else
            addr_now <= addr_now+1;
    end
    else if(current_state==split)
    begin
        code_table[counter-1][5-counter]<=(code_table[counter][record]<<1);
        code_table[counter-1][6-counter]<=((code_table[counter][record]<<1) | 6'b1);
        mask_table[counter-1][5-counter]<=((mask_table[counter][record] << 1) | 6'b1);
        mask_table[counter-1][6-counter]<=((mask_table[counter][record] << 1) | 6'b1);
        addr_now<=0;
        addr_next<=0;
    end
    else if(current_state==final_sort)
    begin
        if(s_table[0][j][13:8]<=s_table[0][j+1][13:8])
        begin
            mask_table[0][j]<=mask_table[0][j+1];
            mask_table[0][j+1]<=mask_table[0][j];
            code_table[0][j]<=code_table[0][j+1];
            code_table[0][j+1]<=code_table[0][j];
        end
    end
end
always @(posedge clk)// s_table
begin
    if(current_state==init)
    begin
        s_table[0][0][13:8]<=6'b000001;
        s_table[0][1][13:8]<=6'b000010;
        s_table[0][2][13:8]<=6'b000100;
        s_table[0][3][13:8]<=6'b001000;
        s_table[0][4][13:8]<=6'b010000;
        s_table[0][5][13:8]<=6'b100000;
        s_table[0][0][7:0]<=CNT1;
        s_table[0][1][7:0]<=CNT2;
        s_table[0][2][7:0]<=CNT3;
        s_table[0][3][7:0]<=CNT4;
        s_table[0][4][7:0]<=CNT5;
        s_table[0][5][7:0]<=CNT6;
    end
    else if(current_state==sort)
    begin
        if(s_table[0][j][7:0]<=s_table[0][j+1][7:0])
        begin
            s_table[0][j]<=s_table[0][j+1];
            s_table[0][j+1]<=s_table[0][j];
        end
    end
    else if(current_state == final_sort)
    begin
        if(s_table[0][j][13:8]<=s_table[0][j+1][13:8])
        begin
            s_table[0][j]<=s_table[0][j+1];
            s_table[0][j+1]<=s_table[0][j];
        end
    end
    else if(current_state==combine)
    begin
        swap_stop<=0;
        case(i)
            0:
            begin
                s_table[1][0][13:0]<=s_table[0][0][13:0];
                s_table[1][1][13:0]<=s_table[0][1][13:0];
                s_table[1][2][13:0]<=s_table[0][2][13:0];
                s_table[1][3][13:0]<=s_table[0][3][13:0];
                s_table[1][4][7:0] <= (s_table[0][4][7:0] + s_table[0][5][7:0]);
                s_table[1][4][13:8]<=(s_table[0][4][13:8] | s_table[0][5][13:8]);
                record_index[1]<=4;
            end
            1:
            begin
                s_table[2][0][13:0]<=s_table[1][0][13:0];
                s_table[2][1][13:0]<=s_table[1][1][13:0];
                s_table[2][2][13:0]<=s_table[1][2][13:0];
                s_table[2][3][7:0] <=s_table[1][3][7:0]+s_table[1][4][7:0];
                s_table[2][3][13:8]<=(s_table[1][3][13:8]|s_table[1][4][13:8]);
                record_index[2]<=3;
            end
            2:
            begin
                s_table[3][0][13:0]<=s_table[2][0][13:0];
                s_table[3][1][13:0]<=s_table[2][1][13:0];
                s_table[3][2][7:0] <=s_table[2][2][7:0]+s_table[2][3][7:0];
                s_table[3][2][13:8] <=(s_table[2][2][13:8]|s_table[2][3][13:8]);
                record_index[3]<=2;
            end
            3:
            begin
                s_table[4][0][13:0]<=s_table[3][0][13:0];
                s_table[4][1][7:0]<=(s_table[3][1][7:0]+s_table[3][2][7:0]);
                s_table[4][1][13:8]<=(s_table[3][1][13:8]|s_table[3][2][13:8]);
                record_index[4]<=1;
            end
        endcase
    end
    else if(current_state==swap)
    begin
        if(record_index[i]>0)
        begin
            if(s_table[i][record_index[i]][7:0]>s_table[i][record_index[i]-1][7:0])
            begin
                s_table[i][record_index[i]] <= s_table[i][record_index[i]-1];
                s_table[i][record_index[i]-1] <= s_table[i][record_index[i]];
                record_index[i]<=record_index[i]-1;
            end
            else
                swap_stop<=1;
        end
        else
            swap_stop<=1;
    end
end
always @(posedge clk or posedge reset)//counter
begin
    if(reset)
        counter<=4;
    else if(current_state==split)
        counter<=counter-1;
end
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        HC1<=0;
        HC2<=0;
        HC3<=0;
        HC4<=0;
        HC5<=0;
        HC6<=0;
        M1<=0;
        M2<=0;
        M3<=0;
        M4<=0;
        M5<=0;
        M6<=0;
    end
    else if(current_state==final_assign)
    begin
        HC1<=code_table[0][5];
        HC2<=code_table[0][4];
        HC3<=code_table[0][3];
        HC4<=code_table[0][2];
        HC5<=code_table[0][1];
        HC6<=code_table[0][0];
        M1<=mask_table[0][5];
        M2<=mask_table[0][4];
        M3<=mask_table[0][3];
        M4<=mask_table[0][2];
        M5<=mask_table[0][1];
        M6<=mask_table[0][0];
    end
end
always @(posedge clk or posedge reset) //CNT_valid
begin
    if(reset)
        CNT_valid<=0;
    else if(current_state==final_assign)
        CNT_valid<=1;
    else
        CNT_valid<=0;
end
always @(posedge clk or posedge reset) //code_valid
begin
    if(reset)
        code_valid<=0;
    else if(current_state==final_assign)
        code_valid<=1;
    else
        code_valid<=0;
end
endmodule
