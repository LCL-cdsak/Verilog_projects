module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output busy;
output valid;
output [7:0]candidate;
reg busy;
reg valid;
reg [7:0]candidate;

reg [3:0]x;
reg [3:0]y;
reg [3:0]x1;
reg [3:0]y1;
reg [3:0]x2;
reg [3:0]y2;
reg [3:0]r1;
reg [3:0]r2;
reg state;
reg [1:0]m;
reg [7:0]r1_square;
reg [7:0]r2_square;
reg [3:0]x1_difference;
reg [3:0]y1_difference;
reg [3:0]x2_difference;
reg [3:0]y2_difference;
reg [7:0]x1_length_square;
reg [7:0]y1_length_square;
reg [7:0]x2_length_square;
reg [7:0]y2_length_square;


parameter op = 0;
parameter out = 1;

always @(posedge rst  or posedge clk)
begin
    if(rst)
    begin
        valid<=0;
        busy<=0;
    end
    else if(en)
    begin
        valid<=0;
        m<=mode;
        x1<=central[23:20];
        y1<=central[19:16];
        x2<=central[15:12];
        y2<=central[11:8];
        r1<=radius[11:8];
        r2<=radius[7:4];
        x<=1;
        y<=1;
        busy<=1;
        state<=op;
        candidate<=0;
    end
    else
    begin
        case (state)
            op:
            begin
                case (m)
                    2'b00 ://|A|
                    begin
                        if((x1_length_square + y1_length_square) <= r1_square)
                            candidate <= candidate+1;
                        else
                            candidate <= candidate;
                    end
                    2'b01://|A intersect B|
                    begin
                        if((x1_length_square + y1_length_square) <= r1_square && (x2_length_square + y2_length_square) <= r2_square)
                            candidate <= candidate+1;
                        else
                            candidate <= candidate;
                    end
                    2'b10://|A - B|
                    begin
                        if(((x1_length_square + y1_length_square) <= r1_square && (x2_length_square + y2_length_square) > r2_square)
                                || ((x1_length_square + y1_length_square) > r1_square && (x2_length_square + y2_length_square) <= r2_square))
                            candidate <= candidate+1;
                        else
                            candidate <= candidate;
                    end
                    default:
                        ;
                endcase
                if(y==8)
                begin
                    x<=x+1;
                    y<=1;
                end
                else
                    y<=y+1;
                if(x==8 && y==8)
                begin
                    state<=out;
                    valid<=1;
                end
            end
            out:
            begin
                busy<=0;
                valid<=0;
            end
            default:
                ;
        endcase
    end
end
always @(*)
begin
    x1_length_square = x1_difference * x1_difference;
    x2_length_square = x2_difference * x2_difference;
    y1_length_square = y1_difference * y1_difference;
    y2_length_square = y2_difference * y2_difference;
end
always @(*)
begin
    r1_square = r1*r1;
    r2_square = r2*r2;
end
always @(*)
begin
    x1_difference = (x1>x)?x1-x:x-x1;
    x2_difference = (x2>x)?x2-x:x-x2;
    y1_difference = (y1>y)?y1-y:y-y1;
    y2_difference = (y2>y)?y2-y:y-y2;
end
endmodule
