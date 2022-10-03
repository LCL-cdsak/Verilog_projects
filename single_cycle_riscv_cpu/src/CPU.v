

// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,//data send from {Data Memory}
    input      [31:0] instr_out,//instruction send from {Instruction Memory}
    output reg    instr_read,//whether the instruction should be read in {Instruction Memory}
    output reg    data_read,//whether the data should be read in {Data Memory}
    output reg [31:0] instr_addr,//instruction address in {Instruction Memory}
    output reg [31:0] data_addr,//data address in {Data Memory}
    output reg [3:0]  data_write,//control {Mem[0][31:24],Mem[0][23:16],Mem[0][15:8],Mem[0][7:0]}
    output reg [31:0] data_in//data will be wrote into {Data Memory}
);

/* Add your design */
integer i;
reg [4:0]rs1,rs2,rd;
reg [31:0] x[0:31];//register0~31
reg [31:0] PC;
reg [3:0] stage;//five stage:0->IF,1->ID,2->EX,3->MEM,4->WB
reg [31:0] immediate,instruction;
reg reg_write;
reg[6:0] funct7;
reg[2:0] funct3;
reg[4:0] shamt;
reg[3:0] read_type;//0:LW,1:LB,2:LH,3:LBU,4:LHU
reg[2:0] write_type;//0:SW,1:SB,2:SH
reg[63:0] mul_result;
//assign instr_read = Instr_read;
//assign instr_addr[31:0] = Instr_addr[31:0];
//assign data_addr[31:0] = Data_addr[31:0];
//assign data_read = Data_read;

always@(posedge clk)
begin
	x[0] <= 32'b0;//zero
	if(rst==1'b1)
	begin 	
		PC=0;
		data_write<=4'b0000;
		data_addr<=32'b0;
		instr_addr<=32'b0;
		instr_read<=1'b0;
		data_read<=0;
		stage<=1;
		instruction<=32'b0;
		read_type<=4'b0;
		mul_result<=64'b0;
		immediate<=0;
		instr_read<=1;
		data_read<=0;
		instr_addr = PC;
		data_write<=4'b0000;
		stage<=1;
	end
	else
	begin
		case(stage)
		0://Intruction Fetch
		begin
			immediate<=0;
			instr_read<=1;
			data_read<=0;
			instr_addr <= PC;
			data_write<=4'b0000;
			stage<=1;
		end
		1://wait for instr_out
		begin
			stage<=2;
			case(write_type)//data_in,data_write
				0:
				begin
					data_write <= 4'b1111;
					data_addr <= x[rs1] + immediate;
					data_in <= x[rs2];
				end
				1:
				begin
					data_write <= 4'b0001<<(x[rs1]+immediate)%4;
					data_addr <= x[rs1] + immediate;
					data_in <= {{24{x[rs2][7]}}, x[rs2][7:0]}<<((x[rs1]+immediate)%4)*8;
				end
				2:
				begin
					data_write <= 4'b0011<<(x[rs1]+immediate)%4;
					data_addr <= x[rs1] + immediate;
					data_in <= {{16{x[rs2][7]}}, x[rs2][15:0]}<<((x[rs1]+immediate)%4)*8;
				end
				3:
				begin end
				endcase
			write_type<=3;//none
			instr_read<=0;
		end
		2://Intruction Decode
		begin
			data_write <=4'b0000;
			instruction<=instr_out;
			case(instr_out[6:0])
			7'b0110011://r type
			begin
				funct7=instr_out[31:25];
				rs2=instr_out[24:20];
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				rd=instr_out[11:7];
				PC=PC+4;
				case({funct7,funct3})
				10'b0000000000:x[rd]<=x[rs1]+x[rs2];//ADD
				10'b0100000000:x[rd]<=x[rs1]-x[rs2];//SUB
				10'b0000000001:x[rd]<=($unsigned(x[rs1])<<x[rs2][4:0]);//SLL
				10'b0000000010://SLT
				begin
					if($signed(x[rs1])<$signed(x[rs2]))
						x[rd] <= 1;
					else
						x[rd] <= 0;
				end
				10'b0000000011://SLTU
				begin
					if($unsigned(x[rs1])<$unsigned(x[rs2]))
						x[rd] <= 1;
					else
						x[rd] <= 0;
				end
				10'b0000000100:x[rd]<=x[rs1]^x[rs2];//XOR
				10'b0000000101:x[rd]<=($unsigned(x[rs1])>>x[rs2][4:0]);//SRL
				10'b0100000101:x[rd]<=($signed(x[rs1])>>>x[rs2][4:0]);//SRA
				10'b0000000110:x[rd]<=x[rs1]|x[rs2];//OR
				10'b0000000111:x[rd]<=x[rs1]&x[rs2];//AND
				10'b0000001000://MUL
				begin
					mul_result = $signed(x[rs1]) * $signed(x[rs2]);
					x[rd]<=mul_result[31:0];
				end
				10'b0000001001://MULH
				begin
					mul_result = $signed(x[rs1]) * $signed(x[rs2]);
					x[rd]<=mul_result[63:32];
				end
				10'b0000001011://MULHU
				begin
					mul_result = $unsigned(x[rs1]) * $unsigned(x[rs2]);
					x[rd]<=mul_result[63:32];
				end
				endcase
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b0000011:// LW,LB,LH,LBU,LHU
			begin
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				rd=instr_out[11:7];
				immediate={{20{instr_out[31]}},instr_out[31:20]};
				stage<=4;//wait for mem access
				data_read<=1;
				PC<=PC+4;
				data_addr<=x[rs1]+immediate;
				case(funct3)
				3'b010:read_type<=0;
				3'b000:read_type<=1;
				3'b001:read_type<=2;
				3'b100:read_type<=3;
				3'b101:read_type<=4;
				endcase
			end
			7'b0010011://ADDDI,SLTI,SLYIIU,XORI,ORI,ANDI,SLLI,SRLI,SRAI
			begin
				shamt=instr_out[24:20];
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				rd=instr_out[11:7];
				immediate={{20{instr_out[31]}},instr_out[31:20]};//using immediate[11:5] to identify SLRI and SRAI
				PC=PC+4;
				case(funct3)
				3'b000:x[rd]<=x[rs1]+immediate;//ADDI
				3'b010://SLTI
				begin
					if($signed(x[rs1])<$signed(immediate))
						x[rd]<=1;
					else
						x[rd]<=0;
				end
				3'b011://SLTIU
				begin
					if($unsigned(x[rs1])<$unsigned(immediate))
						x[rd]<=1;
					else
						x[rd]<=0;
				end
				3'b100:x[rd]<=x[rs1]^immediate;//XORI
				3'b110:x[rd]<=x[rs1]|immediate;//ORI
				3'b111:x[rd]<=x[rs1]&immediate;//ANDI
				3'b001:x[rd]<=$unsigned(x[rs1])<<shamt;//SLLI
				3'b101:
				begin
					if(immediate[11:5]==7'b0000000)//SRLI
						x[rd]<=$unsigned(x[rs1])>>shamt;
					else//SRAI
						x[rd]<=$signed(x[rs1])>>>shamt;
				end
				endcase
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b1100111://JALR
			begin
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				rd=instr_out[11:7];
				immediate={{20{instr_out[31]}},instr_out[31:20]};
				x[rd]<=PC+4;
				PC=immediate + x[rs1];
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b0100011://s type
			begin
				immediate={{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
				rs2=instr_out[24:20];
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				PC=PC+4;
				case(funct3)//data_in,data_write
				3'b010:
				begin
					write_type<=0;
				end
				3'b000:
				begin
					write_type<=1;
				end
				3'b001:
				begin
					write_type<=2;
				end
				endcase
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				stage<=1;
			end
			7'b1100011://b type
			begin
				rs2=instr_out[24:20];
				rs1=instr_out[19:15];
				funct3=instr_out[14:12];
				immediate={{19{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0};
				case(funct3)
				3'b000://BEQ
				begin
					if(x[rs1]==x[rs2])
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				3'b001://BNE
				begin
					if(x[rs1]!=x[rs2])
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				3'b100://BLT
				begin
					if($signed(x[rs1])<$signed(x[rs2]))
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				3'b101://BGE
				begin
					if($signed(x[rs1])>=$signed(x[rs2]))
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				3'b110://BLTU
				begin
					if($unsigned(x[rs1])<$unsigned(x[rs2]))
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				3'b111://BGEU
				begin
					if($unsigned(x[rs1])>=$unsigned(x[rs2]))
						PC=PC+immediate;
					else
						PC=PC+4;
				end
				endcase
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b0010111://AUIPC
			begin
				rd=instr_out[11:7];
				immediate={instr_out[31:12],12'b0};
				x[rd]<=PC+immediate;
				PC=PC+4;
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b0110111://LUI
			begin
				rd=instr_out[11:7];
				immediate={instr_out[31:12],12'b0};
				PC=PC+4;
				x[rd]<=immediate;
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			7'b1101111://JAL
			begin
				rd=instr_out[11:7];
				immediate={{11{instr_out[31]}},instr_out[31],instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
				x[rd]<=PC+4;
				PC=PC+immediate;
				immediate<=0;
				instr_read<=1;
				data_read<=0;
				instr_addr = PC;
				data_write<=4'b0000;
				stage<=1;
			end
			endcase
		end
		4://mem access
		begin
			stage<=5;
			instr_read<=1;//cont
			data_read<=0;
			immediate<=0;
			instr_addr = PC;
			data_write<=4'b0000;
		end
		5://Write Back Register
		begin
			case(read_type)//0:LW,1:LB,2:LH,3:LBU,4:LHU
			0:x[rd]<=data_out;//LW
			1:x[rd]<=$signed({{24{data_out[7]}},data_out[7:0]});//LB
			2:x[rd]<=$signed({{16{data_out[7]}},data_out[15:0]});//LH
			3:x[rd]<=$unsigned({24'b0,data_out[7:0]});//LBU
			4:x[rd]<=$unsigned({16'b0,data_out[15:0]});//LHU
			5:begin end
			endcase
			stage<=2;
		end
		endcase
	end
end

endmodule