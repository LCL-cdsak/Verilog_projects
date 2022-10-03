
`timescale 1ns/10ps

module  CONV(
            input		clk,
            input		reset,
            output	reg	busy,
            input		ready,

            output  reg [11:0] iaddr,
            input	 [19:0] idata,

            output	reg 	cwr,
            output	reg [11:0]	caddr_wr,
            output	reg [19:0]	cdata_wr,

            output	reg 	crd,
            output	reg [11:0]	caddr_rd,
            input	 [19:0]	cdata_rd,

            output	reg [2:0]csel
        );
reg [2:0]current_state,next_state;
reg debug;
reg [3:0]counter;
reg [5:0]x,y;
wire [5:0]x_plus,y_plus,x_minus,y_minus;
reg signed [44:0]mul;//8 + 32 + 1(signed)
wire signed [44:0]result;
assign result = mul + 40'h0013108000;
assign x_plus = x+1;
assign x_minus = x-1;
assign y_plus = y+1;
assign y_minus = y-1;
reg signed [19:0]k[8:0]; // kernel
parameter idle = 0;
parameter read_0 = 1;
parameter write_0 = 2;
parameter read_1 = 3;
parameter write_1 = 4;
parameter finish = 5;
parameter next_0 = 6;
parameter next_1 = 7;
always @(*) //next_state logic
begin
    if(reset)
        next_state = idle;
    else
    begin
        case(current_state)
            idle:
                if(ready)
                    next_state = read_0;
                else
                    next_state = idle;
            read_0:
                if(counter == 9)
                    next_state = write_0;
                else
                    next_state = read_0;
            write_0:
                next_state = next_0;
            next_0:
                if(x == 0 && y == 0)
                    next_state = read_1;
                else
                    next_state = read_0;
            read_1:
                if(counter == 4)
                    next_state = write_1;
                else
                    next_state = read_1;
            write_1:
                next_state = next_1;
            next_1:
                if(x == 0 && y ==0)
                    next_state = finish;
                else
                    next_state = read_1;
            finish:
                next_state = finish;
            default:
                next_state = idle;
        endcase
    end
end
always @(posedge clk or posedge reset) //csel
begin
    if(reset)
        csel<=0;
    else if(next_state == write_0 || next_state == read_1)
        csel<=3'b001;
    else if(next_state == write_1)
        csel<=3'b011;
    else
        csel<=csel;
end
always @(posedge clk or posedge reset) //cwr
begin
    if(reset)
        cwr<=0;
    else if(current_state == write_0 || current_state == write_1)
        cwr<=1;
    else
        cwr<=0;
end
always @(posedge clk or posedge reset) //crd
begin
    if(reset)
        crd<=0;
    else if(next_state == read_1)
        crd<=1;
    else
        crd<=0;
end
always @(posedge clk or posedge reset)//busy
begin
    if(reset)
        busy<=0;
    else if (next_state == finish)
        busy<=0;
    else if(next_state == read_0)
        busy<=1;
    else
        busy<=busy;
end
always @(posedge clk or posedge reset) //caddr_wr
begin
    if(reset)
        caddr_wr<=0;
    else if(current_state == write_0)
        caddr_wr<={x,y};
    else if(current_state==write_1)
        caddr_wr<={2'b0,x[5:1],y[5:1]};
end
always @(posedge clk or posedge reset)//cdata_wr
begin
    if(reset)
    begin
        k[0] <= 20'h0A89E;
        k[1] <= 20'h092D5;
        k[2] <= 20'h06D43;
        k[3] <= 20'h01004;
        k[4] <= 20'hF8F71;
        k[5] <= 20'hF6E54;
        k[6] <= 20'hFA6D7;
        k[7] <= 20'hFC834;
        k[8] <= 20'hFAC19;
        cdata_wr<=0;
        mul<=0;
    end
    else if(current_state == read_0)//CONV
    begin
        if( (x==0 && counter < 4) || (x==63 && counter > 6) || (y==0 && (counter == 1 || counter == 4||counter == 7)) ||(y==63 && (counter == 3 || counter == 6||counter == 9)))
            mul<=mul;
        else
        begin
            mul <= mul+ k[counter-1]* $signed (idata);
            debug<=1;
        end
    end
    else if(current_state == write_0)//relu
    begin
        mul<=0;
        if(result < 0)
            cdata_wr <= 0;
        else
            cdata_wr <= result[35:16];
    end
    else if(current_state == read_1)//max_pooling
    begin
        if(cdata_wr < cdata_rd)
            cdata_wr<= cdata_rd;
        else
            cdata_wr<=cdata_wr;
    end
    else if(current_state == next_1||current_state == next_0)
        cdata_wr<=0;
    else
        ;
end
always @(posedge clk or posedge reset) //caddr_rd
begin
    if(reset)
        caddr_rd<=0;
    else if(next_state == read_1)
    begin
        case(counter)
            0:
                caddr_rd<={x,y};
            1:
                caddr_rd<={x,y_plus};
            2:
                caddr_rd<={x_plus,y};
            3:
                caddr_rd<={x_plus,y_plus};
            default:
                caddr_rd<=caddr_rd;
        endcase
    end
    else
        ;
end
always @(posedge clk )//iaddr
begin

    if(next_state == read_0)
    begin
        case(counter)
            0:
                iaddr<={x_minus,y_minus};
            1:
                iaddr<={x_minus,y};
            2:
                iaddr<={x_minus,y_plus};
            3:
                iaddr<={x,y_minus};
            4:
                iaddr<={x,y};
            5:
                iaddr<={x,y_plus};
            6:
                iaddr<={x_plus,y_minus};
            7:
                iaddr<={x_plus,y};
            8:
                iaddr<={x_plus,y_plus};
            default:
                iaddr<=iaddr;
        endcase
    end
    else
        ;
end
always @(posedge clk or posedge reset)//counter
begin
    if(reset)
        counter<=0;
    else if(next_state == read_0 || next_state == read_1)
        counter<=counter+1;
    else
        counter<=0;
end
always @(posedge clk or posedge reset)//x
begin
    if(reset)
        x<=0;
    else if(next_state == next_0)
    begin
        if(y==6'b111111)
            x<=x+1;
        else
            x<=x;
    end
    else if(next_state == next_1)
    begin
        if(y==62)
            x<=x+2;
        else
            x<=x;
    end
end
always @(posedge clk or posedge reset)//y
begin
    if(reset)
        y<=0;
    else if(next_state == next_0)
        y<=y+1;
    else if(next_state == next_1)
        y<=y+2;
end
always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= idle;
    else
        current_state <= next_state;
end
endmodule
