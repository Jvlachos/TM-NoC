module imm_generator 
    import core::*;
    import riscv::*;
(
    input logic [31:0] instr_i,
    input logic [2:0]  format_i,
    output logic signed [31:0] imm_o
);
    core::formats_t format;
    riscv::instruction_t instruction;
    assign instruction = riscv::instruction_t'(instr_i);

    assign format =  core::formats_t'(format_i);
    always_comb begin : imm_mux
        //imm_o = 32'b0;
        unique case (format)
            core::I_FORMAT: begin
                if(instruction.itype.opcode == riscv::I_OP &&  (instruction.itype.funct3 == riscv::SRLI_SRAI || instruction.itype.funct3 == riscv::SLLI_F3)) begin
                    imm_o = {{28{instr_i[24]}},instr_i[23:20]};
                end
                else begin
                    imm_o = {{21{instr_i[31]}},instr_i[30:20]};
                end
                         

            end
            core::R_FORMAT: begin
                imm_o = 32'b0;
            end
            core::U_FORMAT:begin
                if(instruction.utype.opcode == riscv::LUI_OP || instruction.utype.opcode == riscv::AUI_OP )    begin
                    imm_o = {instruction.utype.imm,12'b0};
                end
                else begin 
                    ;
                end
            end
            core::J_FORMAT: begin
                if(instruction.itype.opcode == riscv::JALR_OP) begin
                    imm_o =  {{21{instr_i[31]}},instr_i[30:20]};
                end 
                else if(instruction.utype.opcode == riscv::JAL_OP) begin
                    imm_o = {{12{instr_i[31]}},{instr_i[19:12],instr_i[20],instr_i[30:25],instr_i[24:21],1'b0}};               end
                else begin 
                    ;
                end
            end

            core::S_FORMAT:begin
                imm_o = {{21{instr_i[31]}},{instr_i[30:25],instr_i[11:8],instr_i[7]}}; 
                //$display("instruction in s %b\n",instr_i);
                //$display("immediate sw : %d\n",imm_o);
            end
            core::B_FORMAT:begin
                imm_o ={ {19{instr_i[31]}},{instr_i[31],instr_i[7],instr_i[30:25],instr_i[11:8],1'b0}};
      //          $display("B Imm : %b , %d",imm_o,imm_o);
            end 
            default: begin
                 imm_o = 32'b0;
            end
        endcase
        
    end

endmodule