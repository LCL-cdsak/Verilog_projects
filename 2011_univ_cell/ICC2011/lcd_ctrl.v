module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [2:0] cmd;
input cmd_valid;
output reg IROM_EN; //
output reg[5:0] IROM_A; //
output reg IRB_RW; //
output reg [7:0] IRB_D;
output reg [5:0] IRB_A;
output reg busy; 
output reg done; //

reg [2:0]current_state;//
reg [2:0]next_state;//
reg [2:0]x;//
reg [2:0]y;//
reg [2:0]center_x;
reg [2:0]center_y;
wire[2:0]center_x_minus_one;
wire[2:0]center_y_minus_one;
assign center_x_minus_one = center_x - 1 ;
assign center_y_minus_one = center_y - 1 ;
reg [7:0]img[7:0][7:0];
reg [2:0]operation;
reg [9:0]avg;
parameter idle = 0;
parameter read = 1;
parameter op = 2;
parameter out = 3;
parameter wait_cmd = 4;
parameter finish = 5;

parameter write = 0;
parameter shift_up = 1;
parameter shift_down = 2;
parameter shift_left = 3;
parameter shift_right = 4;
parameter average = 5;
parameter mirror_x = 6;
parameter mirror_y = 7;
always @(posedge clk or posedge reset) 
begin
    if(reset) current_state<=idle;
    else    current_state<=next_state;
end
always @(*) //next state logic
begin
    case (current_state)
        idle:
        if(!reset)next_state = read;
        else next_state = idle;
        read:
        if(IROM_A==8'h3f && y == 7)next_state = wait_cmd;
        else next_state = next_state;
        op:next_state = wait_cmd;
        wait_cmd:
        if(cmd_valid && cmd == write) next_state = out;
        else if(cmd_valid) next_state = op;
		else next_state = wait_cmd;
        out:
        if(IRB_A == 8'h3f)next_state = finish;
        else next_state = out;
        finish:
        next_state = finish;
        default: 
        next_state = next_state;
    endcase
end
always @(posedge clk or posedge reset) // IROM_EN
begin
    if(reset) IROM_EN<=0;
    else if(next_state==read)IROM_EN<=0;
    else IROM_EN<=1;
end
always @(negedge clk or posedge reset) // IROM_A ->負緣將位址送出
begin
    if(reset) IROM_A<=0;
    else if (current_state==read)IROM_A <= {x,y}+1;
    else IROM_A<=0;
end
always @(negedge clk or posedge reset) begin
	if(current_state==out)
	begin
		IRB_A<={x,y};
		IRB_D<=img[x][y];
	end
	else
	begin
		IRB_A<=0;
		IRB_D<=0;
	end
end
always @(posedge clk or posedge reset) //IRB_RW
begin
    if(reset) IRB_RW <= 1;
    else if(next_state == out) IRB_RW <= 0;
    else IRB_RW<=1;
end
always @(posedge clk or posedge reset) //done
begin
    if(reset) done<=0;
    else if(next_state == finish) done<=1;
    else done<=0;
end
always @(posedge clk or posedge reset) //busy
begin
        if(reset) busy<=1;
        else if(next_state == wait_cmd || next_state == finish) busy<=0;
        else   busy<=1;
end
always @(posedge clk or posedge reset) //x
begin
    if(reset) x<=3'b111;
    else if(next_state == read || next_state == out) 
    begin
       if(y==7) x<=x+1;
       else x<=x;
    end
    else x<=3'b111;
end
always @(posedge clk or posedge reset) //y
begin
    if(reset) y<=3'b111;
    else if(next_state == read || next_state == out) y<=y+1;
    else y<=3'b111;
end

always @(posedge clk) //img,center_x,center_y,operation
begin
	case (current_state)
		idle:
		begin
			center_x<=4;
			center_y<=4;
		end
		read:
			img[x][y]<=IROM_Q;
		op:
		begin
			case (operation)
				write :
				;
				shift_left :
				if(center_y == 1) center_y<=1;
				else center_y<=center_y-1;
				shift_right :
				if(center_y == 7) center_y<=7;
				else center_y<=center_y+1;
				shift_up :
				if(center_x == 1) center_x<=1;
				else center_x<=center_x-1;
				shift_down :
				if(center_x == 7) center_x<=7;
				else center_x<=center_x+1;
				average  :
				begin
					img[center_x][center_y]<=avg[7:0];
					img[center_x][center_y_minus_one]<=avg[7:0];
					img[center_x_minus_one][center_y]<=avg[7:0];
					img[center_x_minus_one][center_y_minus_one]<=avg[7:0];
				end
				mirror_y :
				begin
					img[center_x][center_y]<=img[center_x][center_y_minus_one];
					img[center_x][center_y_minus_one]<=img[center_x][center_y];
					img[center_x_minus_one][center_y]<=img[center_x_minus_one][center_y_minus_one];
					img[center_x_minus_one][center_y_minus_one]<=img[center_x_minus_one][center_y];
				end
				mirror_x :
				begin
					img[center_x][center_y]<=img[center_x_minus_one][center_y];
					img[center_x_minus_one][center_y]<=img[center_x][center_y];
					img[center_x][center_y_minus_one]<=img[center_x_minus_one][center_y_minus_one];
					img[center_x_minus_one][center_y_minus_one]<=img[center_x][center_y_minus_one];
				end
				default: 
				;
			endcase
		end
		out:
		;
		wait_cmd:
		begin
			if(cmd_valid && current_state == wait_cmd) operation<=cmd;
			else operation <= operation;
		end
		finish:
		;
		default:
		;
	endcase
end
always @(*) 
begin
	avg = (img[center_x][center_y]+img[center_x][center_y_minus_one]+img[center_x_minus_one][center_y]+img[center_x_minus_one][center_y_minus_one])>>2;
end
endmodule

