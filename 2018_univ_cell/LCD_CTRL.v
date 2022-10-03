module LCD_CTRL(clk,
                reset,
                cmd,
                cmd_valid,
                IROM_Q,
                IROM_rd,
                IROM_A,
                IRAM_valid,
                IRAM_D,
                IRAM_A,
                busy,
                done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output IRAM_valid;
output [7:0] IRAM_D;
output [5:0] IRAM_A;
output busy;
output done;
parameter IDLE  = 0;
parameter READ  = 1;
parameter WRITE = 2;
parameter OP    = 3;
//state: 0->idle, 1->read, 2->write, 3->operation
reg [1:0]current;
reg [1:0]next;
reg [7:0]ImageBuffer[63:0];//Total #64 8bit reg
reg [3:0]operation;
reg [2:0]x;
reg [2:0]y;
reg [5:0]address;
reg [7:0]max;
reg [7:0]min;
reg [9:0]average;

reg IROM_rd;
reg [5:0] IROM_A;
reg IRAM_valid;
reg [7:0] IRAM_D;
reg [5:0] IRAM_A;
reg busy;
reg done;

always@(posedge clk or posedge reset)
begin
    if (reset)
    begin
        IROM_A  <= 6'd0;
        current <= READ;
        x       <= 4;
        y       <= 4;
        min     <= 0;
        max     <= 0;
    end
    else if (cmd_valid && current == IDLE)
    begin
        current   <= OP;
        operation <= cmd;
    end
    else
    begin
    end
end

always @(posedge clk)
begin
    case (current)
        READ:
        begin
            if (IROM_rd)
            begin
                if (IROM_A == 63)
                begin
                    IROM_A  <= 0;
                    ImageBuffer[IROM_A] <= IROM_Q;
                    current <= IDLE;
                end
                else
                begin
                    IROM_A              <= IROM_A+1;
                    ImageBuffer[IROM_A] <= IROM_Q;
                    current             <= READ;
                end
            end
            else
            begin
            end
        end
        OP://remain busy while handling cmd
        begin
            case (operation)
                0://write
                begin
                    if (IRAM_A == 63)
                    begin
                        //IRAM_D <= ImageBuffer[IRAM_A];
                        done <= 1;
                    end
                    else
                    begin
                        IRAM_A <= IRAM_A+1;
                        //IRAM_D <= ImageBuffer[IRAM_A];
                    end
                end
                1://shift up
                begin
                    if (y == 1)
                        y <= 1;
                    else
                        y       <= y-1;
                    current <= IDLE;
                end
                2://shift Down
                begin
                    if (y == 7)
                        y <= 7;
                    else
                        y       <= y+1;
                    current <= IDLE;
                end
                3://shift Left
                begin
                    if (x == 1)
                        x <= 1;
                    else
                        x       <= x-1;
                    current <= IDLE;
                end
                4://shift Right
                begin
                    if (x == 7)
                        x <= 7;
                    else
                        x       <= x+1;
                    current <= IDLE;
                end
                5://max
                begin
                    ImageBuffer[address]   <= max;
                    ImageBuffer[address-1] <= max;
                    ImageBuffer[address-8] <= max;
                    ImageBuffer[address-9] <= max;
                    current <= IDLE;
                end
                6://min
                begin
                    ImageBuffer[address]   <= min;
                    ImageBuffer[address-1] <= min;
                    ImageBuffer[address-8] <= min;
                    ImageBuffer[address-9] <= min;
                    current <= IDLE;
                end
                7://average
                begin
                    ImageBuffer[address]   <= average;
                    ImageBuffer[address-1] <= average;
                    ImageBuffer[address-8] <= average;
                    ImageBuffer[address-9] <= average;
                    current <= IDLE;
                end

                8://Counterclockwise Rotation
                begin
                    ImageBuffer[address]   <= ImageBuffer[address-1];
                    ImageBuffer[address-1] <= ImageBuffer[address-9];
                    ImageBuffer[address-9] <= ImageBuffer[address-8];
                    ImageBuffer[address-8] <= ImageBuffer[address];
                    current                <= IDLE;
                end
                9://Clockwise Rotation
                begin
                    ImageBuffer[address-1] <= ImageBuffer[address];
                    ImageBuffer[address-9] <= ImageBuffer[address-1];
                    ImageBuffer[address-8] <= ImageBuffer[address-9];
                    ImageBuffer[address]   <= ImageBuffer[address-8];
                    current                <= IDLE;
                end
                10://mirror x
                begin
                    ImageBuffer[address]   <= ImageBuffer[address-8];
                    ImageBuffer[address-8] <= ImageBuffer[address];
                    ImageBuffer[address-1] <= ImageBuffer[address-9];
                    ImageBuffer[address-9] <= ImageBuffer[address-1];
                    current                <= IDLE;
                end
                11://mirror y
                begin
                    ImageBuffer[address]   <= ImageBuffer[address-1];
                    ImageBuffer[address-1] <= ImageBuffer[address];
                    ImageBuffer[address-8] <= ImageBuffer[address-9];
                    ImageBuffer[address-9] <= ImageBuffer[address-8];
                    current                <= IDLE;
                end
                default:
                    ;
            endcase
        end
        default:
            ;
    endcase
end
always @(*)
begin
    address = x + (y << 3);
end
always @(*)
begin
    if (ImageBuffer[address] <= ImageBuffer[address-1] && ImageBuffer[address] <= ImageBuffer[address-8] && ImageBuffer[address] <= ImageBuffer[address-9])
        min = ImageBuffer[address];
    else if (ImageBuffer[address-1] <= ImageBuffer[address] && ImageBuffer[address-1] <= ImageBuffer[address-8] && ImageBuffer[address-1] <= ImageBuffer[address-9])
        min = ImageBuffer[address-1];
    else if (ImageBuffer[address-8] <= ImageBuffer[address] && ImageBuffer[address-8] <= ImageBuffer[address-1] && ImageBuffer[address-8] <= ImageBuffer[address-9])
        min = ImageBuffer[address-8];
    else
        min = ImageBuffer[address-9];
end
always @(*)
begin
    if (ImageBuffer[address] >= ImageBuffer[address-1] && ImageBuffer[address] >= ImageBuffer[address-8] && ImageBuffer[address] >= ImageBuffer[address-9])
        max = ImageBuffer[address];
    else if (ImageBuffer[address-1] >= ImageBuffer[address] && ImageBuffer[address-1] >= ImageBuffer[address-8] && ImageBuffer[address-1] >= ImageBuffer[address-9])
        max = ImageBuffer[address-1];
    else if (ImageBuffer[address-8] >= ImageBuffer[address] && ImageBuffer[address-8] >= ImageBuffer[address-1] && ImageBuffer[address-8] >= ImageBuffer[address-9])
        max = ImageBuffer[address-8];
    else
        max = ImageBuffer[address-9];
end
always @(*)
begin
    average = (ImageBuffer[address]+ImageBuffer[address-1]+ImageBuffer[address-8]+ImageBuffer[address-9])>>2;
end
always@(*)//control signal assignment
begin
    case(current)
        IDLE://idle -> get new cmd
        begin
            IROM_rd    = 0;
            busy       = 0;
            IRAM_valid = 0;
            IRAM_A     = 0;
            IRAM_D     = 0;
            IRAM_A     = 0;
        end
        READ://READ
        begin
            IROM_rd    = 1;
            busy       = 1;
            IRAM_valid = 0;
        end
        WRITE://WRITE
        begin
            IROM_rd    = 0;
            busy       = 1;
            IRAM_valid = 1;
        end
        OP://OPERATE
        begin
            IROM_rd    = 0;
            busy       = 1;
            IRAM_valid = 0;
        end
        default:
            ;
    endcase
end
always @(*)
begin
    IRAM_D = ImageBuffer[IRAM_A];
end
always @(*)
begin
    if(operation==0)
        IRAM_valid = 1;
    else
        IRAM_valid = 0;
end
endmodule
