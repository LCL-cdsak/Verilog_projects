module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;
reg [2:0]current_state;
reg [2:0]next_state;
reg [19:0]receiver[5:0];//bit 19~10為x，bit 9~0為y
reg [19:0]object;
reg [2:0]counter;
reg [2:0]sort_index;
wire[2:0]sort_index_plus;
wire[2:0]counter_plus;
wire[2:0]sort_index_minus;
assign counter_plus = counter+1;
assign sort_index_plus = sort_index+1;
assign sort_index_minus = sort_index-1;
reg signed  [10:0]A_x,A_y,B_x,B_y;
reg signed [10:0]k1,k2;
wire signed [10:0]t1,t2,t3,t4;
assign t1 = A_x- k1;
assign t2 = B_y - k2;
assign t3 = B_x - k1;
assign t4 = A_y - k2;
wire signed [20:0]cross_result;
assign cross_result = (t1*t2) - (t3*t4);
parameter idle = 0;
parameter read_object = 1;
parameter read_receiver = 2;
parameter sort = 3;
parameter compare = 4;
parameter ready_to_compare = 5;
parameter finish = 6;
parameter temp = 7;
always @(*)
begin
    if(next_state ==sort)
    begin
        k1 = receiver[0][19:10];
        k2 = receiver[0][9:0];
    end
    else
    begin
        k1 = object[19:10];
        k2 = object[9:0];
    end   
end
always @(*) 
begin
    case(current_state)
    idle:
        next_state = read_object;
    read_object:
        next_state = read_receiver;
    read_receiver:
        if(counter==0)next_state = sort;
        else next_state = read_receiver;
    sort:
        if(counter==4) next_state = ready_to_compare;
        else next_state = sort;
    ready_to_compare:
        next_state = compare;
    compare:
        if(counter==6) next_state = finish;
        else next_state = compare;
    finish:
        next_state = idle;
    default:
        next_state = idle;
    endcase
end
always @(posedge clk)
begin
    if(next_state ==idle)
    begin
        counter<=0;
        sort_index<=1;
    end
    else if(next_state==read_receiver)
    begin
        receiver[counter][19:10]<=X;
        receiver[counter][9:0]<=Y;
        if(counter==5)
        begin
            A_x<=receiver[sort_index][19:10];
            A_y<=receiver[sort_index][9:0];
            B_x<=receiver[sort_index_plus][19:10];
            B_y<=receiver[sort_index_plus][9:0];//sort_index==1
            counter<=0;
            sort_index<=sort_index_plus;
        end
        else
            counter<=counter_plus;
    end
    else if(next_state == sort)
    begin
        if(cross_result < 0 && sort_index > 1) //swap，1->5順時針方向排序
        begin
            receiver[sort_index_minus]<=receiver[sort_index];
            receiver[sort_index]<=receiver[sort_index_minus];
        end
        if(sort_index==5)
        begin
            sort_index<=1;
            counter<=counter_plus;
        end
        else
        begin
            A_x<=receiver[sort_index][19:10];
            A_y<=receiver[sort_index][9:0];
            B_x<=receiver[sort_index_plus][19:10];
            B_y<=receiver[sort_index_plus][9:0];
            sort_index<=sort_index_plus;
        end
    end
    else if(next_state==ready_to_compare)
    begin
        is_inside<=1;
        counter<=0;
        A_x<=receiver[5][19:10];
        A_y<=receiver[5][9:0];
        B_x<=receiver[0][19:10] ;
        B_y<=receiver[0][9:0];
    end
    else if(next_state==compare)
    begin
        counter<=counter_plus;
        if(cross_result<=0)
            is_inside<=0;
        A_x<=receiver[counter][19:10];
        A_y<=receiver[counter][9:0];
        B_x<=receiver[counter_plus][19:10];
        B_y<=receiver[counter_plus][9:0];
    end
end
always @(posedge clk) //object
begin
    if(next_state==read_object)
    begin
        object[19:10]<=X;
        object[9:0]<=Y;
    end
    else ;
end
always @(posedge clk or posedge reset)
begin
    if(reset) current_state<=idle;
    else current_state<=next_state;
end
always @(posedge clk or posedge reset) //valid
begin
    if(reset) valid = 0;
    else if(next_state==finish) valid = 1;
    else valid = 0;
end
endmodule