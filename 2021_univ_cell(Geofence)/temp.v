module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;
reg [2:0]current_state,next_state;
reg [9:0]point[6:0][1:0];
wire signed[20:0]cross;
parameter idle = 0;
always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state<= idle;
    else
        current_state<=next_state;
end
endmodule
