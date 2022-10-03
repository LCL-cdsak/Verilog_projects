module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;
output is_inside;
reg valid;//
reg is_inside;//
reg [4:0]current_state,next_state,flag;
reg signed[10:0]object_x[5:0],object_y[5:0];
reg signed[11:0]object_r[5:0];
reg [2:0]counter;
reg [2:0]index;
reg sorting;
reg [21:0]k3;
reg [24:0]high,low,s1,c;
reg [24:0]mid;
reg signed[24:0]triangle;//
reg squart_flag;//
reg signed [23:0]hexagon;
wire signed [42:0] mul_result;
reg signed [42:0] temp;
reg signed [24:0] k1,k2;
wire signed [24:0]vector_x,vector_y;
assign vector_x = sorting ? k1 - object_x[0] : k1;
assign vector_y = sorting ? k2 - object_y[0] : k2;
assign mul_result = vector_x * vector_y;

wire [2:0]index_add_1;
assign index_add_1 = (index==5)?0:index+1;
localparam read = 0;
localparam sort = 1;
localparam mul = 2;
localparam cross_1 = 4;//算外積
localparam cross_2 = 5;
localparam swap = 6;
localparam assign_hexagon_area_1 = 7;
localparam hexagon_area_1 = 8;
localparam assign_hexagon_area_2 = 9;
localparam hexagon_area_2 = 10;
localparam square_start = 11;
localparam compute_mid = 12;
localparam product = 13;
localparam compare = 14;
localparam get_c_1 = 15;
localparam get_c_2 = 16;
localparam Pythagorean = 17;
localparam get_s_1 = 18;
localparam get_s_2 = 19;
localparam store_k_1 = 20;
localparam store_k_2 = 21;
localparam mul_s1_s2 = 22;
localparam add_triangle = 23;
localparam fianl_compare = 30;
localparam finish = 31;
always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= read;
    else
        current_state<=next_state;
end
always @(*)//next_state logic
begin
    case(current_state)
        read:
            if(counter == 5)
                next_state = sort;
            else
                next_state = read;
        sort:
            if(counter==5)
                next_state = assign_hexagon_area_1;
            else
                next_state = cross_1 ;
        cross_1:
            next_state = mul;
        mul:
            next_state = flag;
        cross_2:
            next_state = swap;
        swap:
            if(index==4)
                next_state = sort;
            else
                next_state = cross_1;
        assign_hexagon_area_1:
            next_state = hexagon_area_1;
        hexagon_area_1:
            next_state = assign_hexagon_area_2;
        assign_hexagon_area_2:
            next_state = hexagon_area_2;
        hexagon_area_2:
            if(index==0)
                next_state = get_c_1;
            else
                next_state = assign_hexagon_area_1;
        get_c_1:
            next_state = mul;
        get_c_2:
            next_state = Pythagorean;
        Pythagorean:
            next_state = square_start;
        square_start://將k3放入high
            next_state = compute_mid;
        compute_mid:
            next_state = product;
        product:
            if(squart_flag)
                next_state = flag;//開根號完去flag stage
            else
                next_state = compare;
        compare:
            next_state = compute_mid;
        get_s_1:
            next_state = store_k_1;
        get_s_2:
            next_state = store_k_2;
        store_k_1:
            next_state = square_start;
        store_k_2:
            next_state = square_start;
        mul_s1_s2:
            next_state = add_triangle;
        add_triangle:
            if(index==5)
                next_state = fianl_compare;
            else
                next_state = get_c_1;
        fianl_compare:
            next_state=finish;
        finish:
            next_state = read;
        default:
            next_state = read;
    endcase
end
always @(posedge clk or posedge reset)//index
begin
    if(reset)
        index<=1;
    else if(current_state==sort)
        index<=1;
    else if(current_state==swap)
        index<=index_add_1;
    else if(current_state == hexagon_area_2)
        if(index==0)
            index<=index;
        else
            index<=index_add_1;
    else if(current_state == add_triangle)
        index<=index_add_1;
    else if(current_state==finish)
        index<=1;

end
always @(posedge clk or posedge reset)//counter
begin
    if(reset)
        counter<=0;
    else if(current_state==read)
    begin
        if(counter==5)
            counter<=0;
        else
            counter<=counter+1;
    end
    else if(current_state==sort)
        counter<=counter+1;
    else if(current_state==finish)
        counter<=0;
end
always @(posedge clk)//object_x object_y object_r
begin
    if(current_state==read)
    begin
        object_x[counter]<=X;
        object_y[counter]<=Y;
        object_r[counter]<=R;
    end
    else if(current_state==swap)
    begin
        if(temp>mul_result)
        begin
            object_x[index]<=object_x[index_add_1];
            object_y[index]<=object_y[index_add_1];
            object_r[index]<=object_r[index_add_1];
            object_x[index_add_1]<=object_x[index];
            object_y[index_add_1]<=object_y[index];
            object_r[index_add_1]<=object_r[index];
        end
    end
end
always @(posedge clk)//temp
begin
    if(current_state==mul)
        temp<=mul_result;
end
always @(posedge clk)//k1 k2
begin
    if(current_state==cross_1)
    begin
        k1 <= object_x[index];
        k2 <= object_y[index_add_1];
    end
    else if(current_state==cross_2)
    begin
        k1 <= object_x[index_add_1];
        k2 <= object_y[index];
    end
    else if(current_state == assign_hexagon_area_1)
    begin
        k1 <= object_x[index];
        k2 <= object_y[index_add_1];
    end
    else if(current_state == assign_hexagon_area_2)
    begin
        k1 <= object_x[index_add_1];
        k2 <= object_y[index];
    end
    else if(current_state == get_c_1)
    begin
        k1 <= object_x[index_add_1] - object_x[index];
        k2 <= object_x[index_add_1] - object_x[index];
    end
    else if(current_state == get_c_2)
    begin
        k1 <= object_y[index_add_1] - object_y[index];
        k2 <= object_y[index_add_1] - object_y[index];
    end
    else if(current_state == product)
    begin
        k1 <= mid;
        k2 <= mid;
    end
    else if(current_state==get_s_1)
    begin
        k1 <= ((object_r[index] +  object_r[index_add_1] +(low>>3) )>>1);
        k2 <= ((object_r[index_add_1] + (low>>3) - object_r[index])>>1);
    end
    else if(current_state == get_s_2)
    begin
        k1 <= ((object_r[index] -  object_r[index_add_1] + (c>>3))>>1);
        k2 <= ((object_r[index_add_1] - (c>>3) + object_r[index])>>1);
    end
    else if(current_state==mul_s1_s2)
    begin
        k1<=s1;
        k2<=low;
    end
end
always @(posedge clk)//sorting
begin
    if(current_state==sort)
        sorting<=1;
    else if(current_state==assign_hexagon_area_1)
        sorting<=0;
end
always @(posedge clk)//flag
begin
    if(current_state==cross_1)
        flag<=cross_2;
    else if(current_state==get_c_1)
        flag<=get_c_2;
    else if(current_state==Pythagorean)
        flag<=get_s_1;
    else if(current_state == store_k_1)
        flag<=get_s_2;
    else if(current_state==store_k_2)
        flag<= mul_s1_s2;
end
always @(posedge clk)//hexagon
begin
    if(current_state==read)
        hexagon<=0;
    else if(current_state==hexagon_area_1)
        hexagon <= hexagon + mul_result;
    else if(current_state == hexagon_area_2)
        hexagon <= hexagon - mul_result;
end
always @(posedge clk or posedge reset)//k3 s1
begin
    if(reset)
    begin
        k3<=188;
        s1<=0;
    end

    else if(current_state == Pythagorean)
    begin
        k3 <= mul_result + temp;
    end
    else if(current_state == store_k_1||current_state == store_k_2)
    begin
        k3 <= mul_result;
    end
    else if(current_state == get_s_2)
        s1 <= low;
    else if(current_state == get_s_1)
        c <= low;
end
//*************************************************
always @(posedge clk)//high low mid squart_flag
begin
    if(current_state == square_start)
    begin
        high<={k3,3'b000};
        low<=0;
        squart_flag<=0;
    end
    else if(current_state == compute_mid)
    begin
        if(high - low > 2)
            squart_flag<=0;
        else
            squart_flag<=1;
        mid <= (high+low)>>1;
    end
    else if(current_state == compare)
    begin
        if(mul_result <= {k3,6'b000000})
            low <= mid;
        if(mul_result >= {k3,6'b000000})
            high <=mid;
    end
end
//*************************************************
always @(posedge clk or posedge reset)
begin
    if(reset)
        triangle<=0;
    else if(current_state==add_triangle)
        triangle<=triangle + (mul_result>>6);
    else if(current_state==finish)
        triangle<=0;
end

always @(posedge clk or posedge reset)//is_inside
begin
    if(reset)
        is_inside<=0;
    else if(current_state==fianl_compare)
    begin
        valid<=1;
        if(((-hexagon)>>1)>triangle)
            is_inside <=1;
        else
            is_inside <=0;
    end
    else
    begin
        valid<=0;
        is_inside<=0;
    end
end
endmodule
