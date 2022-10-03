module SET (clk ,rst, en,central,radius, mode, busy, valid, candidate);
input clk;
input rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0]mode;
output reg busy;//
output reg valid;//
output reg [7:0]candidate;
//====================================================================

reg [3:0]x1,x2,x3,y1,y2,y3;//
reg [1:0]mode_buffer;//
reg [7:0]r1_square,r2_square,r3_square;//
reg signed[9:0]temp;
reg signed[10:0]d;//
reg signed[4:0]k;//
wire signed[9:0]mul_result;//
wire signed[4:0]sub_x;//
wire signed[4:0]sub_y;//
wire [3:0]tx2,ty2;//


reg [1:0]flag;//
reg [2:0]counter;//
reg [3:0]tx1,ty1;//
reg [3:0]current_state,next_state;
reg read_flag;//
reg in_A,in_B,in_C;

assign tx2 =
       (flag==0)?x1:
       (flag==1)?x2:
       (flag==2)?x3:x1;
assign ty2 =
       (flag==0)?y1:
       (flag==1)?y2:
       (flag==2)?y3:y1;

assign sub_x = tx1-tx2;//
assign sub_y = ty1-ty2;//
assign mul_result = k*k;//


localparam read = 0;
localparam assign_k = 1;
localparam get_mul_result = 2;
localparam add = 3;
localparam judge = 4;
localparam final_judge = 5;
localparam out = 6;
always @(posedge clk or posedge rst)
begin
    if(rst)
        current_state<=read;
    else
        current_state<=next_state;
end
always @(*) //next_state logic
begin
    case(current_state)
        read:
            if(read_flag)
                next_state = read;
            else
                next_state = assign_k;
        assign_k:
            next_state = get_mul_result;
        get_mul_result:
            if(counter==4)
                next_state = add;
            else
                next_state = assign_k;
        add:
            next_state = judge;
        judge:
            if(!flag)
                next_state = final_judge;
            else
                next_state = assign_k;
        final_judge:
            if(tx1 == 8 && ty1 == 8)
                next_state = out;
            else
                next_state = assign_k;
        out:
            next_state = read;
	default:
            next_state = read;
    endcase
end
always @(posedge clk)//x1,x2,x3,y1,y2,y3
begin
    if(current_state==read)
    begin
        if(en)
        begin
            x1<=central[23:20];
            y1<=central[19:16];
            x2<=central[15:12];
            y2<=central[11:8];
            x3<=central[7:4];
            y3<=central[3:0];
            mode_buffer<=mode;
        end
    end
end
always @(posedge clk )//r1 r2 r3
begin
    if(current_state==read)
    begin
        if(en)
        begin
            r1_square<={4'b0,radius[11:8]};
            r2_square<={4'b0,radius[7:4]};
            r3_square<={4'b0,radius[3:0]};
        end
    end
    else if(current_state==get_mul_result)
    begin
        case(counter)
            0:
                r1_square<=mul_result[7:0];
            1:
                r2_square<=mul_result[7:0];
            2:
                r3_square<=mul_result[7:0];
        endcase
    end
end
always @(posedge clk or posedge rst)//flag
begin
    if(rst)
        flag<=3;
    else if(current_state==read)
    begin
        if(mode==0||mode==1)
            flag<=mode;
        else
            flag<=mode-1;
    end
    else if(current_state==judge)
        flag<=flag-1;
    else if(current_state==final_judge)
    begin
        if(mode_buffer==0||mode_buffer==1)
            flag<=mode_buffer;
        else
            flag<=mode_buffer-1;
    end
end
always @(posedge clk)//counter
begin
    if(current_state ==read)
        counter<=0;
    else if(current_state==get_mul_result)
        counter<=counter+1;
    else if(current_state==judge)
        counter<=3;
end
always @(posedge clk )//k
begin
    case(counter)
        0:
            k<=r1_square[3:0];
        1:
            k<=r2_square[3:0];
        2:
            k<=r3_square[3:0];
        3:
            k<=sub_x;
        4:
            k<=sub_y;
    endcase
end
always @(posedge clk)//tx1,ty1
begin
    if(current_state == read)
    begin
        tx1 <= 1;
        ty1 <= 1;
    end
    else if(current_state == final_judge)
    begin
        if(ty1 == 8)
        begin
            tx1<=tx1+1;
            ty1<=1;
        end
        else
            ty1<=ty1+1;
    end
end
always @(posedge clk)//in_A in_B in_C candidate
begin
    if(current_state==read)
    begin
        in_A<=0;
        in_B<=0;
        in_C<=0;
        candidate<=0;
    end
    else if(current_state==judge)
    begin
        if(flag == 2) //in_C
        begin
            if(d[7:0] <= r3_square)//?
                in_C<=1;
        end
        else if(flag == 1)//in_B
        begin
            if(d[7:0] <= r2_square)
                in_B<=1;
        end
        else if(flag == 0)//in_A
        begin
            if(d[7:0]<=r1_square)
                in_A<=1;
        end
    end
    else if(current_state==final_judge)
    begin
        case(mode_buffer)
            0:
                if(in_A)
                    candidate<=candidate+1;
            1:
                if(in_A && in_B)
                    candidate<=candidate+1;
            2:
                if((in_A && !in_B) || (!in_A && in_B))
                    candidate<=candidate+1;
            3:
                if((in_A&&in_B&&!in_C)||(in_A&&!in_B&&in_C)||(!in_A&&in_B&&in_C))
                    candidate<=candidate+1;
        endcase
        in_A<=0;
        in_B<=0;
        in_C<=0;
    end
end
always @(posedge clk)//read_flag
begin
    if(current_state ==read)
        read_flag<=0;
    else
        read_flag<=1;
end
always @(posedge clk or posedge rst)//busy valid
begin
    if(rst)
    begin
        busy<=0;
        valid<=0;
    end
    else if(current_state == out)
    begin
        valid<=1;
    end
    else if(current_state == read)
    begin
        if(en)
            busy<=1;
        else
            busy<=0;
        valid<=0;
    end
end
always @(posedge clk)//temp d
begin
    if(current_state==read)
        temp <=0;
    else if(current_state == get_mul_result && counter == 3)
        temp<=mul_result;
    else if(current_state == add)
        d <= temp + mul_result;
end
endmodule
