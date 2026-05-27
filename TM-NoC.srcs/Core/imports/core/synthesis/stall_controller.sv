module stall_controller 
    import riscv::*;
    import core::*;
(
    input logic clk,
    input logic rst,
    input logic [31:0] instr_i,
    input core::pipeline_bus_t exmem_bus_i,
    input  bit unstall_i,
    output bit stall_o,
    input logic [2:0] format_i ,
    input bit pipeline_stalled_i,
    output bit pipeline_stalled_o
);
    core::formats_t format;
    riscv::instruction_t instruction;
    assign instruction = riscv::instruction_t'(instr_i);
    assign format = core::formats_t'(format_i);
    logic [4:0] ld_rd;
    bit pipeline_stalled;

    assign pipeline_stalled = (pipeline_stalled_i | pipeline_stalled_o) & ~unstall_i;
    
    always_ff @(posedge clk,negedge rst ) begin : blockName
       if(~rst)
        pipeline_stalled_o <= 0;
       else 
        pipeline_stalled_o <= pipeline_stalled; 
    end


    always_comb begin
        ld_rd = 5'b0;
        stall_o = 1'b0;
        if(pipeline_stalled)
            stall_o = 1'b1;
        else if(instruction.instruction != riscv::I_NOP && exmem_bus_i.instr[6:0] == riscv::L_OP  ) begin
            ld_rd = exmem_bus_i.rd;
            unique  case(format_i)
                core::I_FORMAT: begin
                    stall_o = ld_rd!='0 && ld_rd == instruction.itype.rs1; 
                end
                core::S_FORMAT: begin
                    stall_o = ld_rd!='0 && (ld_rd == instruction.stype.rs1 || ld_rd == instruction.stype.rs2);
                end
                core::U_FORMAT: begin
                    ;
                end
                core::R_FORMAT: begin
                    stall_o = ld_rd!='0 && (ld_rd == instruction.rtype.rs1 || ld_rd == instruction.rtype.rs2);
                end
                core::B_FORMAT: begin
                    stall_o = ld_rd!='0 && (ld_rd == instruction.btype.rs1 || ld_rd == instruction.btype.rs2);
                end
                core::J_FORMAT: begin
                    if(instruction.instruction[6:0] == core::ALU_JALR) begin
                        stall_o = ld_rd!='0 && ld_rd == instruction.itype.rs1;
                    end
                    else begin
                        ;
                    end
                end
                core::NOP: begin
                    ;
                end
            endcase
        end
        else begin
            ;
        end
    end
    
endmodule