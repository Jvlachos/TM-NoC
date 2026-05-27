`define CLK_PERIOD 5


module decoder_tb(
	input logic clk,
	input logic rst,
	input [31:0] instruction_i
);
	import core::*;
	import riscv::*;
	logic [4:0] rs1_o;
	logic [4:0] rs2_o;
	logic [4:0] rd_o;
	logic [31:0] instruction_gen;
	core::ALU_OP_t alu_op;
	riscv::reg_t register;	
	logic [31:0] immediate ;
	//id_stage id(.clk(clk),.rst(rst),.instruction_i(instruction_i),.rs1_o(rs1_o),.rs2_o(rs2_o),.rd_o(rd_o),.alu_op_o(alu_op),.immediate_o(immediate));
	initial begin
		
		@(posedge clk);
		@(posedge clk);

		@(posedge clk);

	$finish;
    end


	task generate_instrs();
		instruction_gen = riscv::xori(riscv::x0,riscv::x0,-15);
		@(posedge clk);
		instruction_gen = riscv::andi(riscv::x1,riscv::x5,5);
		$display("ALU_OP : %s",alu_op.name);
		@(posedge clk);
		
		instruction_gen = riscv::store_num(riscv::x1,riscv::x5,-10,riscv::HWORD);
		@(posedge clk);
		instruction_gen = riscv::store_num(riscv::x1,riscv::x5,20,riscv::HWORD);
		@(posedge clk);
		
		instruction_gen = riscv::store_num(riscv::x1,riscv::x5,-20,riscv::HWORD);

		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::ADD_SUB,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::SLL,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::SLT,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::SLTU,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::XOR,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::SRL_SRA,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::OR,riscv::x3,0);
		@(posedge clk);
		instruction_gen = riscv::gen_rr(riscv::x1,riscv::x2,riscv::AND,riscv::x3,0);
		@(posedge clk);	
	endtask

	task display_instr(logic [31:0] ins);
		riscv::instruction_t instruction ; 

		riscv::reg_t rs1;
		riscv::reg_t rs2;
		riscv::reg_t rd;
		instruction = riscv::instruction_t'(ins);
		$display("op : %b\n",ins[6:0]);
		case (instruction.instruction[6:0])
			riscv::I_OP:begin

				rs1 = riscv::reg_t'(instruction.itype.rs1);		
				rd = riscv::reg_t'(instruction.itype.rd);
				

				$display("Immediate: %d\nrs1: %s\nfunct3: %b\nrd: %s\nop: %b\n",instruction.itype.imm,
				rs1.name(),instruction.itype.funct3,
				rd.name(),instruction.itype.opcode) ;
			end
			riscv::L_OP:
			begin

				rs1 = riscv::reg_t'(instruction.itype.rs1);	
				rd = riscv::reg_t'(instruction.itype.rd);	
			 	$display("Immediate: %d\nrs1: %s\nfunct3: %b\nrd: %s\nop: %b\n",instruction.itype.imm,
				rs1.name(),instruction.itype.funct3,
				rd.name(),instruction.itype.opcode) ;
			end
			riscv::S_OP:
			begin
				
				rs1 = riscv::reg_t'(instruction.stype.rs1);	
				rs2 = riscv::reg_t'(instruction.stype.rs2);	
			  	$display("Immediate1: %d\nrs2: %s\nrs1: %s\nfunc3: %b\nImmediate2: %b\nop: %b\n",instruction.stype.imm,
				rs2.name(),rs1.name(),
				instruction.stype.funct3,instruction.stype.imm_2,instruction.stype.opcode);
			end
			riscv::RR_OP:begin  

				rs1 = riscv::reg_t'(instruction.rtype.rs1);	
				rs2 = riscv::reg_t'(instruction.rtype.rs2);		
				rd = riscv::reg_t'(instruction.rtype.rd);	
				$display("funct7: %d\nrs2: %s\nrs1: %s\nfunc3: %b\nrd: %s\nop: %b\n",instruction.rtype.funct7,
				rs2.name(),rs1.name(),
				instruction.rtype.funct3,rd.name(),instruction.stype.opcode);
			end
			default: $display("nothing? \n");
		endcase

	endtask

endmodule
