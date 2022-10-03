module DT(
           input 			clk,
           input			reset,
           output	reg		done ,
           output	reg		sti_rd ,
           output	reg 	[9:0]	sti_addr ,
           input		[15:0]	sti_di,
           output	reg		res_wr ,
           output	reg		res_rd ,
           output	reg 	[13:0]	res_addr ,
           output	reg 	[7:0]	res_do,
           input		[7:0]	res_di
       );
parameter idle = 0;
parameter read_center_f = 1;
parameter read_f = 2;
parameter write_f = 3;
parameter read_center_b = 4;
parameter read_b = 5;
parameter write_b = 6;
parameter finish = 7;

reg [1:0]counter;
reg [3:0]current_state,next_state;
reg [6:0]x,y;
wire [7:0]res_di_adder;
wire[6:0] x_minus_1,x_plus_1,y_minus_1,y_plus_1;
wire[3:0] center;
assign res_di_adder = res_di+1;
assign center = 4'b1111 - y[3:0];
assign x_minus_1 = x-1;
assign x_plus_1 = x+1;
assign y_minus_1 = y-1;
assign y_plus_1 = y+1;

always @(*) //next_state logic
begin
    if(!reset)
        next_state = idle;
    else
    begin
        case(current_state)

            idle:
                if(reset) next_state = read_center_f;
                else next_state = idle;

            read_center_f:
                if(sti_di[center]==0|| x == 0 || y == 0 || x==7'b1111111 || y== 7'b1111111)next_state = write_f;
                else next_state = read_f;

            read_f:
                if(counter==0) next_state = write_f;
                else next_state = read_f;

            write_f:
                if(x==7'b1111111 && y== 7'b1111111)next_state = read_center_b;
                else next_state = read_center_f;

            read_center_b:
                if(sti_di[center]==0|| x == 0 || y == 0 || x==7'b1111111 || y== 7'b1111111) next_state = write_b;
                else next_state = read_b;

            read_b:
                if(counter==0) next_state = write_b;
                else next_state = read_b;

            write_b:
                if(x==0 && y== 0)next_state = finish;
                else next_state = read_center_b;

            finish: next_state = finish;

            default: next_state = next_state;

        endcase
    end
end
always @(posedge clk or negedge reset) //current_state
begin
    if(!reset) current_state<=idle;
    else current_state<=next_state;
end
always @(posedge clk or negedge reset) //counter
begin
    if(!reset) 
        counter<=0;
    else if (next_state==read_f||next_state==read_b)
        counter<=counter+1;
    else
        counter<=0;
end
always @(posedge clk or negedge reset) //x
begin
    if(!reset) 
        x <= 0;
    else if(next_state == write_f )
    begin
        if(y == 7'b1111111) x<=x+1;
        else x<=x;
    end
    else if(next_state == write_b )
    begin
        if(y == 0) x<=x-1;
        else x<=x;
    end
    else
    ;
end
always @(posedge clk or negedge reset) //y
begin
    if(!reset)
        y<=0;
    else if(next_state == write_f )
        y<=y+1;
    else if(next_state == write_b )
        y<=y-1;
    else 
    ;
end
always @(posedge clk or negedge reset) //res_addr
begin
    if(!reset)
        res_addr<=0;
    else if(next_state == read_center_b|| next_state == read_center_f||next_state == write_b||next_state == write_f)
        res_addr<={x,y};
    else if(next_state == read_f)
    begin
        case(counter)
        0:res_addr<={x,y_minus_1};
        1:res_addr<={x_minus_1,y_minus_1};
        2:res_addr<={x_minus_1,y};
        3:res_addr<={x_minus_1,y_plus_1};
        default:res_addr<=res_addr;
        endcase
    end
    else if(next_state == read_b)
    begin
        case(counter)
        0:res_addr<={x,y_plus_1};
        1:res_addr<={x_plus_1,y_minus_1};
        2:res_addr<={x_plus_1,y};
        3:res_addr<={x_plus_1,y_plus_1};
        default:res_addr<=res_addr;
        endcase
    end
    else
    ;
end
always @(posedge clk or negedge reset) //sti_addr
begin
    if(!reset)
        sti_addr<=0;
    else if (next_state == read_center_b|| next_state == read_center_f)
        sti_addr<={x,y}>>4;
    else
    ;
end
always @(posedge clk or negedge reset) //res_do
begin
    if(!reset)
        res_do<=0;
    else if(current_state ==read_center_b||current_state==read_center_f)
    begin
        if(sti_di[center]==0 ||x==0||y==0||x == 7'b1111111 || y ==7'b1111111) res_do<=0;
        else res_do<=res_di;
    end
    else if(current_state == read_f)
    begin
        if(counter==1)    
            res_do <= res_di + 1;
        else
            res_do <= res_do < res_di_adder ? res_do : res_di_adder;
    end
    else if(current_state == read_b)
        res_do <= res_do < res_di_adder ?res_do : res_di_adder;
    else
    ;
end
always @(posedge clk or negedge reset) //done
begin
    if(!reset)
        done<=0;
    else if(next_state==finish)
        done<=1;
    else
        done<=0;
end
always @(posedge clk or negedge reset) //res_wr
begin
    if(!reset)
        res_wr<=0;
    else if(next_state == write_b||next_state == write_f)
        res_wr<=1;
    else
        res_wr<=0;
end
always @(posedge clk or negedge reset) //sti_rd
begin
    if(!reset)
        sti_rd<=0;
    else if(next_state==read_center_b||next_state == read_center_f)
        sti_rd<=1;
    else
        sti_rd<=0;
end
always @(posedge clk or negedge reset) //res_rd
begin
    if(!reset)
        res_rd<=0;
    else if(next_state == read_b||next_state == read_f||next_state==read_center_b||next_state == read_center_f)
        res_rd<=1;
    else
        res_rd<=0;
end
endmodule