module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input clk;
input reset;
input [7:0] datain;
input [2:0] cmd;
input cmd_valid;

output reg [7:0] dataout;
output reg output_valid;
output reg busy;
reg [1:0]state;
reg [1:0]next;
reg [3:0]x;
reg [3:0]y;
reg [7:0]img[8:0][11:0];
reg [3:0]op;
reg [3:0]counter;
reg [3:0]center_x;
reg [3:0]center_y;
parameter Load_Data = 0;
parameter Zoom_In = 1;
parameter Zoom_Fit = 2;
parameter Shift_Right  = 3;
parameter Shift_Left  = 4;
parameter Shift_Up = 5;
parameter Shift_Down = 6;
parameter Output_1 = 7;
parameter Output_2 = 8;
parameter Idle = 9;//WAIT FOR NEXT CMD

parameter Output_State = 0;
parameter Initial_State = 1;
parameter Zoom_Fit_State = 2;
parameter Zoom_In_State = 3;

always @(posedge clk or posedge reset) //處理state
begin
    if(reset)
    begin
        x<=0;
        y<=0;
        op<=Idle;
        busy<=0;
        output_valid<=0;
    end
    else
    begin
        case(op)
            Idle:
            begin
                if(cmd_valid)
                begin
                    x<=0;
                    y<=0;
                    busy<=1;
                    op<=cmd;
                end 
                else
                begin
                    busy<=0;
                    op<=Idle;
                end
                output_valid<=0;
            end
            Load_Data:
            begin
                state<=Zoom_Fit_State;
                img[x][y]<=datain;
                if(y==11)
                begin
                    if(x==8)
                    begin
                        y<=1;
                        x<=1;
                        op<=Output_1;
                    end
                    else
                    begin
                        y<=0;
                        x<=x+1;
                    end   
                end
                else
                    y<=y+1;
            end
            Output_1:
            begin
                output_valid<=1;
                dataout<=img[x][y];
                if(y==10)
                begin
                    if(x==7)
                    begin
                        x<=0;
                        y<=0;
                        op<=Idle;
                    end
                    else
                    begin
                        y<=1;
                        x<=x+2;
                    end
                end
                else
                    y<=y+3;
            end
            Output_2:
            begin
                output_valid<=1;
                dataout<=img[x][y];
                if(y==center_y+1)
                begin
                    if(x==center_x+1)
                    begin
                        x<=0;
                        y<=0;
                        op<=Idle;
                    end
                    else
                    begin
                        y<=center_y-2;
                        x<=x+1;
                    end
                end
                else
                    y<=y+1;
            end
            Zoom_Fit:
            begin
                x<=1;
                y<=1;
                op<=Output_1;
                state<=Zoom_Fit_State;
            end
            Zoom_In:
            begin
                if(state!=Zoom_In_State)
                begin
                    center_x<=5;
                    center_y<=6;
                    x<=3;
                    y<=4;
                    op<=Output_2;
                    state<=Zoom_In_State;
                end
                else
                begin
                    center_x<=center_x;
                    center_y<=center_y;
                    x<=center_x-2;
                    y<=center_y-2;
                    op<=Output_2;
                end
            end
            Shift_Right:
            begin
                if(state==Zoom_In_State)
                begin
                    if(center_y==10)
                    begin
                        center_x<=center_x;
                        center_y<=center_y;
                        x<=center_x-2;
                        y<=center_y-2;
                        op<=Output_2;
                    end
                    else
                    begin
                        center_x<=center_x;
                        center_y<=center_y+1;
                        x<=center_x-2;
                        y<=center_y-1;
                        op<=Output_2;
                    end
                    
                end
                else
                begin
                    op<=Output_1;
                    x<=1;
                    y<=1;
                end
            end
            Shift_Left:
            begin   
                if(state==Zoom_In_State)
                begin
                    if(center_y==2)
                    begin
                        center_x<=center_x;
                        center_y<=center_y;
                        x<=center_x-2;
                        y<=center_y-2;
                        op<=Output_2;
                    end
                    else
                    begin
                        center_x<=center_x;
                        center_y<=center_y-1;
                        x<=center_x-2;
                        y<=center_y-3;
                        op<=Output_2;
                    end
                    
                end
                else
                begin
                    op<=Output_1;
                    x<=1;
                    y<=1;
                end
            end
            Shift_Up:
            begin
                if(state==Zoom_In_State)
                begin
                    if(center_x==2)
                    begin
                        center_x<=center_x;
                        center_y<=center_y;
                        x<=center_x-2;
                        y<=center_y-2;
                        op<=Output_2;
                    end
                    else
                    begin
                        center_x<=center_x-1;
                        center_y<=center_y;
                        x<=center_x-3;
                        y<=center_y-2;
                        op<=Output_2; 
                    end
                    
                end
                else
                begin
                    op<=Output_1;
                    x<=1;
                    y<=1;
                end
            end
            Shift_Down:
            begin
                if(state==Zoom_In_State)
                begin
                    if(center_x==7)
                    begin
                        center_x<=center_x;
                        center_y<=center_y;
                        x<=center_x-2;
                        y<=center_y-2;
                        op<=Output_2;
                    end
                    else
                    begin
                        center_x<=center_x+1;
                        center_y<=center_y;
                        x<=center_x-1;
                        y<=center_y-2;
                        op<=Output_2;
                    end  
                end
                else
                begin
                    op<=Output_1;
                    x<=1;
                    y<=1;
                end
            end
        endcase
    end
end
endmodule
