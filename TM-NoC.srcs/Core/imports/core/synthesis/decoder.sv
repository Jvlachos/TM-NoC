module decoder
    import core::*;
    import riscv::*;
 (
   input logic clk,
   input logic rst, 
   input logic [31:0] instruction_i,
   input  logic [31:0] pc_i,
   input core::pipeline_bus_t wb_bus_i,
   output core::pipeline_bus_t id_bus_o,
   output logic [2:0] format,
   input bit pred_i,
   input btb_entry_t btb_entry_i
);
   imm_generator im_gen(
        .instr_i(instruction_i),
        .format_i(format),
        .imm_o(id_bus_o.imm));

   regfile_2r1w rf(
      .clk(clk),
      .i_raddr_a(id_bus_o.rs1),
      .i_raddr_b(id_bus_o.rs2),
      .i_wen(wb_bus_i.rf_wr_en),
      .i_waddr(wb_bus_i.rd),
      .i_wdata(wb_bus_i.rd_res),
      .o_rdata_a(id_bus_o.rs1_data),
      .o_rdata_b(id_bus_o.rs2_data)
   );

   riscv::instruction_t instruction;
   assign instruction = riscv::instruction_t'(instruction_i); 
   riscv::reg_t rs1_t;
   riscv::reg_t rs2_t;
   riscv::reg_t rd_t;
 
   
   always_comb begin : instr_decoder
      format               =  core::NOP;
      id_bus_o.mem_op      =  core::MEM_NOP;
      id_bus_o.alu_op      =  core::ALU_NOP;
      id_bus_o.format      =  core::NOP;
      id_bus_o.instr       =  instruction_i; 
      //id_bus_o.rs1         =  'b0;
      //id_bus_o.rs2         =  'b0;
     // id_bus_o.rd          =  'b0;
      id_bus_o.is_branch   = 1'b0;
      id_bus_o.rd_res      =  'b0;
      id_bus_o.pc          =  pc_i;
      id_bus_o.rf_wr_en    = 1'b0;
      id_bus_o.pipeline_stall =1'b0;
      id_bus_o.prediction = 0;
      id_bus_o.btb_entry= '0;

       case (instruction.instruction[6:0])
         riscv::I_OP: begin
            rs1_t = riscv::reg_t'(instruction.itype.rs1);
            rd_t  = riscv::reg_t'(instruction.itype.rd);
            format = core::I_FORMAT;

            //bus
            id_bus_o.format = core::I_FORMAT;
            id_bus_o.rs1    = instruction.itype.rs1;
            id_bus_o.rs2    = '0;
            id_bus_o.rd     = instruction.itype.rd;
            if(instruction.itype.rs1 == 5'b0 &&  instruction.itype.rd == 5'b0 && instruction.itype.imm =='0 )
                     id_bus_o.alu_op = core::ALU_NOP;
            else begin
               id_bus_o.alu_op = core::ALU_OP_t'({core::ARITHM_PRFX,instruction.itype.funct3});
               id_bus_o.rf_wr_en = rd_t != riscv::zero;
            end
         end

         riscv::S_OP: begin 
            format = core::S_FORMAT;
            rs1_t = riscv::reg_t'(instruction.stype.rs1);
            rs2_t  = riscv::reg_t'(instruction.stype.rs2);
            id_bus_o.rs1 = instruction.stype.rs1;
            id_bus_o.rs2 = instruction.stype.rs2;
            id_bus_o.rd = '0;
            id_bus_o.format = core::S_FORMAT;
            id_bus_o.mem_op = core::MEM_OP_t'({core::STORE_PRFX,instruction.stype.funct3});
         end          
         riscv::L_OP: begin
            
            format = core::I_FORMAT; 
            rs1_t = riscv::reg_t'(instruction.itype.rs1);
            rd_t  = riscv::reg_t'(instruction.itype.rd);
            id_bus_o.rs1 = instruction.itype.rs1;
            id_bus_o.rd  = instruction.itype.rd;
            id_bus_o.rs2 = '0;
            id_bus_o.format = core::I_FORMAT;
            id_bus_o.mem_op = core::MEM_OP_t'({core::LOAD_PRFX,instruction.itype.funct3});
            id_bus_o.rf_wr_en = rd_t != riscv::zero;
         end
         riscv::LUI_OP: begin;
            format = core::U_FORMAT;
            rd_t = riscv::reg_t'(instruction.utype.rd);
            id_bus_o.rd = instruction.utype.rd;
            id_bus_o.rs1 = '0;
            id_bus_o.rs2 = '0;
            id_bus_o.format = core::U_FORMAT;
            id_bus_o.alu_op    = core::ALU_LUI;
            id_bus_o.rf_wr_en  = rd_t != riscv::zero;
         end
         riscv::AUI_OP: begin;
            format = core::U_FORMAT;
            rd_t = riscv::reg_t'(instruction.utype.rd);
            id_bus_o.rd = instruction.utype.rd;
            id_bus_o.rs1 = '0;
            id_bus_o.rs2 = '0;
            id_bus_o.format = core::U_FORMAT;
            id_bus_o.alu_op = core::ALU_AUIPC;
            id_bus_o.rf_wr_en = rd_t!= riscv::zero;
         end
         riscv::JAL_OP: begin; 
            format = core::J_FORMAT;
            rd_t   = riscv::reg_t'(instruction.utype.rd);
            id_bus_o.is_branch = 1'b1;
            id_bus_o.btb_entry = btb_entry_i;
            id_bus_o.rd = instruction.utype.rd;
            id_bus_o.rs1 = '0;
            id_bus_o.rs2 = '0;
            id_bus_o.format = core::J_FORMAT;
            id_bus_o.alu_op = core::ALU_JAL;
            id_bus_o.rf_wr_en = rd_t != riscv::zero;

            id_bus_o.prediction = pred_i && btb_entry_i.i_addr != '0;

         end
         riscv::JALR_OP: begin;
            format = core::J_FORMAT;
            id_bus_o.is_branch = 1'b1;
            id_bus_o.btb_entry = btb_entry_i;

            rd_t = riscv::reg_t'(instruction.itype.rd);
            rs1_t = riscv::reg_t'(instruction.itype.rs1);
            id_bus_o.rd = instruction.itype.rd;
            id_bus_o.rs1 = instruction.itype.rs1;
            id_bus_o.rs2 = '0;
            id_bus_o.format = core::J_FORMAT;
            id_bus_o.alu_op = core::ALU_JALR;
            id_bus_o.rf_wr_en = rd_t != riscv::zero;
           
            id_bus_o.prediction = pred_i && btb_entry_i.i_addr != '0;

         end
         riscv::B_OP: begin;
            format = core::B_FORMAT;
            id_bus_o.btb_entry = btb_entry_i;
            rs1_t = riscv::reg_t'(instruction.btype.rs1);
            rs2_t = riscv::reg_t'(instruction.btype.rs2);
            id_bus_o.is_branch = 1'b1;
            id_bus_o.rs1 = instruction.btype.rs1;
            id_bus_o.rs2 = instruction.btype.rs2;
            id_bus_o.rd = '0;
            id_bus_o.format = core::B_FORMAT;
            id_bus_o.alu_op = core::ALU_OP_t'({core::BRANCH_PRFX,instruction.btype.funct3});
            id_bus_o.prediction = pred_i && btb_entry_i.i_addr != '0;
         end
         riscv::RR_OP: begin;
            format = core::R_FORMAT;
            rs1_t = riscv::reg_t'(instruction.rtype.rs1);
            rd_t  = riscv::reg_t'(instruction.rtype.rd);
            rs2_t  = riscv::reg_t'(instruction.rtype.rs2);
            id_bus_o.rs1 = instruction.rtype.rs1;
            id_bus_o.rd= instruction.rtype.rd;
            id_bus_o.rs2 = instruction.rtype.rs2;
            id_bus_o.format = core::R_FORMAT;
            id_bus_o.alu_op = core::ALU_OP_t'({core::ARITHM_PRFX,instruction.rtype.funct3});
            id_bus_o.rf_wr_en = rd_t != riscv::zero;
         end
         riscv::E_OP: begin; end
         default: 
            
         ;

      endcase

   end





endmodule