module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;
wire cout[6:0];
wire set;
wire comb_out;
assign comb_out = set ^ overflow;
assign zero = !(result[0]|result[1]|result[2]|result[3]|result[4]|result[5]|result[6]|result[7]);
ALU_1bit ALU1(.result(result[0]), .c_out(cout[0]),  .less(comb_out), .a(ALU_src1[0]), .b(ALU_src2[0]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op));
ALU_1bit ALU2(.result(result[1]), .c_out(cout[1]),  .less(0), 		 .a(ALU_src1[1]), .b(ALU_src2[1]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[0]), .op(op));
ALU_1bit ALU3(.result(result[2]), .c_out(cout[2]),  .less(0), 		 .a(ALU_src1[2]), .b(ALU_src2[2]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[1]), .op(op));
ALU_1bit ALU4(.result(result[3]), .c_out(cout[3]),  .less(0), 		 .a(ALU_src1[3]), .b(ALU_src2[3]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[2]), .op(op));
ALU_1bit ALU5(.result(result[4]), .c_out(cout[4]),  .less(0), 		 .a(ALU_src1[4]), .b(ALU_src2[4]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[3]), .op(op));
ALU_1bit ALU6(.result(result[5]), .c_out(cout[5]),  .less(0), 		 .a(ALU_src1[5]), .b(ALU_src2[5]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[4]), .op(op));
ALU_1bit ALU7(.result(result[6]), .c_out(cout[6]),  .less(0), 		 .a(ALU_src1[6]), .b(ALU_src2[6]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[5]), .op(op));
ALU_1bit ALU8(.result(result[7]), .set(set), .overflow(overflow), .less(0), .a(ALU_src1[7]), .b(ALU_src2[7]), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(cout[6]), .op(op));

endmodule
