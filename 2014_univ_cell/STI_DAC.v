module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
               so_data, so_valid,
               pixel_finish, pixel_dataout, pixel_addr,
               pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end;
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;

output reg so_data, so_valid;
output reg pixel_finish, pixel_wr;
output reg [7:0] pixel_addr;
output reg [7:0] pixel_dataout;

//==============================================================================
parameter idle = 0;
parameter read = 1;
parameter out = 2;
parameter finish = 3;

reg [4:0]counter;
reg [4:0]reverse_counter;
reg [2:0]current_state;
reg [2:0]next_state;
reg [2:0]dac_counter;
reg [31:0]data;

always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state<=idle;
    else
        current_state<=next_state;
end
always @(*) //next state logic
begin
    case(current_state)
        idle:
            if(load)
                next_state = read;
            else
                next_state = load;
        read:
            next_state = out;
        out:
            if(counter == 0 && pi_end)
                next_state = finish;
            else if (counter == 0 && !pi_end)
                next_state = idle;
            else
                next_state = out;
        finish:
            next_state = finish;
    endcase
end
always @(posedge clk or posedge reset) //data
begin
    if(reset)
        data<=0;
    else if(load)
    begin
        case (pi_length)
            2'b00: //8bit
            begin
                if(pi_low && pi_msb)//high 8 bit ，不反轉
                    data<={16'b0,pi_data[7:0],pi_data[15:8]};
                else if(!pi_low && pi_msb)//low 8 bit，不反轉
                    data<={16'b0,pi_data};
                else if(pi_low && !pi_msb)//high 8 bit ，反轉
                    data<=
                    {
                        16'b0,pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                        pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                        pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                        ,pi_data[14],pi_data[15]
                    };
                else //low 8 bit，反轉
                    data<={16'b0,pi_data[8],pi_data[9],pi_data[10],pi_data[11]
                           ,pi_data[12],pi_data[13],pi_data[14],pi_data[15],
                           pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                           pi_data[4],pi_data[5],pi_data[6],pi_data[7]
                          };
            end
            2'b01: // 16bit
            begin
                if(pi_msb)
                    data<={16'b0,pi_data};
                else
                    data<=
                    {
                        16'b0,pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                        pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                        pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                        ,pi_data[14],pi_data[15]
                    };
            end
            2'b10: //24bit
            begin
                if(!pi_msb && pi_fill) //低位補零，反轉
                begin
                    data<=
                    {
                        16'b0,pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                        pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                        pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                        ,pi_data[14],pi_data[15]
                    };

                end
                else if (pi_msb && pi_fill)//低位補零，不反轉
                begin
                    data<={8'b0,pi_data,8'b0};
                end
                else if (pi_msb && !pi_fill)//高位補零，不反轉
                begin
                    data<={16'b0,pi_data};
                end
                else//高位補零，不反轉
                    data <={8'b0,pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                            pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                            pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                            ,pi_data[14],pi_data[15],8'b0};
            end
            2'b11://32bit
            begin
                if(!pi_msb && pi_fill) //低位補零，反轉
                begin
                    data<=
                    {
                        16'b0,pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                        pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                        pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                        ,pi_data[14],pi_data[15]
                    };

                end
                else if (pi_msb && pi_fill)//低位補零，不反轉
                begin
                    data<={pi_data,16'b0};
                end
                else if (!pi_msb && !pi_fill)//高位補零，反轉
                begin
                    data <={pi_data[0],pi_data[1],pi_data[2],pi_data[3],
                            pi_data[4],pi_data[5],pi_data[6],pi_data[7],pi_data[8],
                            pi_data[9],pi_data[10],pi_data[11],pi_data[12],pi_data[13]
                            ,pi_data[14],pi_data[15],16'b0};
                end
                else//高位補零，不反轉
                    data<={16'b0,pi_data};
            end
        endcase
    end
    else
        data<=data;
end
always @(posedge clk or posedge reset)
begin
    if(reset)
        counter<=0;
    else if(load)
    begin
        if(pi_length == 0)
            counter<=7;
        else if(pi_length == 1)
            counter<=15;
        else if(pi_length == 2)
            counter<=23;
        else
            counter<=31;
    end
    else if(current_state == out)
        counter<=counter-1;
    else
        counter<=counter;
end
always @(posedge clk or posedge reset) //so_valid
begin
    if(reset)
        so_valid<=0;
    else if(current_state == out)
        so_valid<=1;
    else
        so_valid<=0;
end
always @(posedge clk or posedge reset) //so_data
begin
    if(reset)
    begin

    end
    else if(current_state == out)
    begin
        so_data<=data[counter];
    end
    else
        so_data<=so_data;
end

always @(posedge clk or posedge reset) //DAC
begin
    if(reset)
    begin
        dac_counter<=7;
        pixel_addr<=8'b11111111;
        pixel_wr<=0;
        pixel_finish<=0;
        pixel_dataout<=0;
    end
    else if(current_state == out)
    begin
        dac_counter<=dac_counter-1;
        pixel_dataout[dac_counter]<=data[counter];
        if(dac_counter==0) // send data
        begin
            pixel_addr<=pixel_addr+1;
            pixel_wr<=1;
        end
        else
        begin
            pixel_addr<=pixel_addr;
            pixel_wr<=0;
        end
    end
    else if(current_state == finish && pixel_addr!=255)
    begin
        dac_counter<=dac_counter-1;
        pixel_dataout[dac_counter]<=0;
        if(dac_counter==0) // send data
        begin
            pixel_addr<=pixel_addr+1;
            pixel_wr<=1;
        end
        else
        begin
            pixel_addr<=pixel_addr;
            pixel_wr<=0;
        end
    end
    else
        ;
end
always @(posedge clk or posedge reset)
begin
    if(reset)
        pixel_finish<=0;
    else if(next_state==finish && pixel_addr==255)
        pixel_finish<=1;
    else
        pixel_finish<=0;
end
endmodule
