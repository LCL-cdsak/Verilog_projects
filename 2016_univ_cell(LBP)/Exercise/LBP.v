
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg[13:0] 	gray_addr;
output  reg       	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  reg[13:0] 	lbp_addr;
output  reg	lbp_valid;
output  reg[7:0] 	lbp_data;
output  reg	finish;
//====================================================================
reg [2:0]current_state;
reg [2:0]next_state;
reg [6:0]x,y;
reg [7:0]center;
reg [2:0]counter;
reg [7:0]result;
reg [7:0]gray_temp;
wire[6:0]x_plus_one;
wire[6:0]x_minus_one;
wire[6:0]y_plus_one;
wire[6:0]y_minus_one;
wire[3:0]counter_minus_one;
assign counter_minus_one = counter-1;
assign x_plus_one = x+1;
assign x_minus_one = x-1;
assign y_plus_one = y+1;
assign y_minus_one = y-1;
parameter idle = 0;
parameter read_center = 1;
parameter read = 2;
parameter write = 3;
parameter done = 4;
//====================================================================
always @(*) //next state logic
begin
    case (current_state)
        idle:
        if(gray_ready)
            next_state = read_center;
        else
            next_state = idle;
        read_center:
            next_state = read;
        read:
            if(counter==7)
                next_state = write;
            else
                next_state = read;
        write:  
            if({x,y} == 16257)next_state = done;
            else next_state = read_center;
        done:
            next_state = done;
        default: 
        ;
    endcase
end

always @(posedge clk or posedge reset)
begin
    if (reset)  current_state<=idle;
    else    current_state<=next_state;
end
always @(posedge clk or posedge reset) //gray_addr
begin
    if(reset) gray_addr <= {x,y};//x == y == 1
    else if(next_state==read_center) //要看current state 或 next state?
        gray_addr <={x,y};
    else if(next_state==read)
    begin
        case (counter)
            7:gray_addr<={x_minus_one,y_minus_one};
            0:gray_addr<={x_minus_one,y};
            1:gray_addr<={x_minus_one,y_plus_one};
            2:gray_addr<={x,y_minus_one};
            3:gray_addr<={x,y_plus_one};
            4:gray_addr<={x_plus_one,y_minus_one};
            5:gray_addr<={x_plus_one,y};
            6:gray_addr<={x_plus_one,y_plus_one};
            default:gray_addr<=0;
        endcase
    end
    else
        gray_addr<=gray_addr;
end
always @(posedge clk or posedge reset) //counter
begin
    if(reset) counter<=7;
    else if (next_state==read)
        counter<=counter+1;
    else 
        counter<=counter;
end
always @(posedge clk or posedge reset) //lbp_data
begin
    if(reset)lbp_data<=0;
    else
    begin
        if(current_state==read)
            if(gray_data >= center)
                lbp_data <= lbp_data + (8'b00000001<<counter);
            else
                lbp_data<=lbp_data;
        else if(current_state==read_center)
            lbp_data <= 0;
        else 
            lbp_data <= lbp_data;
    end
end
always @(posedge clk or posedge reset) 
begin
    if(reset)center<=0;
    else if(current_state==read_center)
        center<=gray_data;
    else
        center<=center;
end
always @(posedge clk or posedge reset) //x
begin
    if(reset) x<=1;
    else if(next_state==write)
    begin
        if(y==126)
            x <= x + 1;
        else
            x <= x;
    end
    else
        x <= x;
end
always @(posedge clk or posedge reset) //y
begin
    if(reset) y<=1;
    else if(next_state==write)
    begin
        if(y==126)
            y <= 1;
        else
            y <= y+1;
    end
    else
        y <= y;
end
always @(posedge clk or posedge reset)
begin
    if(reset)
        gray_req <= 0;
    else if(next_state==read_center || next_state ==read)
        gray_req <= 1;
    else
        gray_req <= 0;
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
        lbp_valid <= 0;
    else if(current_state==write)
        lbp_valid <= 1;
    else
        lbp_valid <= 0;
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
        finish <= 0;
    else if(next_state==done)
        finish<=1;
    else
        finish<=0;
end
always @(posedge clk) begin
    if(next_state==write)
        lbp_addr<={x,y};
    else
        lbp_addr<=lbp_addr;
end
endmodule