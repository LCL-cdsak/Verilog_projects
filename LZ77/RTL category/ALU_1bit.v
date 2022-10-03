module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output   result;
output       c_out;
output       set;
output       overflow;

wire A,B;
wire sum;
assign A = a ^ Ainvert;
assign B = b ^ Binvert;
FA fa1(.s(sum), .carry_out(c_out), .x(A), .y(B), .carry_in(c_in));
assign overflow = c_in ^ c_out;
assign set = sum;
reg temp;
assign result = temp;
always @(*)
begin
    case(op)
        2'b00:
            temp = A & B;
        2'b01:
            temp = A | B;
        2'b10:
            temp = sum;
        2'b11:
            temp = less;
    endcase
end
endmodule
