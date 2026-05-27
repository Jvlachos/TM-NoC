module id_stage 
    import riscv::*;
    import core::*;
(
    input logic clk,
    input logic rst,
    input logic [31:0] instruction_i,
    input  logic [31:0] pc_i,
    input  core::pipeline_bus_t wb_bus_i,
    output core::pipeline_bus_t id_bus_o,
    input logic flush_i,
    input bit stall_i,
    output logic[2:0] format_o,
    output core::pipeline_bus_t id2fw_cntrl_o,
    input bit prediction_i,
    input core::btb_entry_t btb_entry_i);

    core::pipeline_bus_t id_bus;
    assign id2fw_cntrl_o = id_bus;
    decoder ins_decoder(
    .clk(clk),
    .rst(rst),
    .instruction_i(instruction_i),
    .pc_i(pc_i),
    .wb_bus_i(wb_bus_i),
    .id_bus_o(id_bus),
    .format(format_o),
    .pred_i(prediction_i),
    .btb_entry_i(btb_entry_i));


 
    always_ff @(posedge clk,negedge rst ) begin
        if(~rst) begin
            id_bus_o[core::BUS_BITS-1:0] <= '0;
            id_bus_o.mem_op <= core::MEM_NOP;
            id_bus_o.alu_op <= core::ALU_NOP;
            id_bus_o.format <= core::NOP;
            id_bus_o.instr  <= riscv::I_NOP;
        end
        else if(flush_i ) begin
           // $display("Flushing..\n");
            id_bus_o[core::BUS_BITS-1:0] <= '0;
            id_bus_o.mem_op <= core::MEM_NOP;
            id_bus_o.alu_op <= core::ALU_NOP;
            id_bus_o.format <= core::NOP;
            id_bus_o.instr  <= riscv::I_NOP; 
        end
        else if(stall_i) begin
            //$display("Stalling..\n");
            id_bus_o[core::BUS_BITS-1:0] <= '0;
            id_bus_o.mem_op <= core::MEM_NOP;
            id_bus_o.alu_op <= core::ALU_NOP;
            id_bus_o.format <= core::NOP;
            id_bus_o.instr  <= riscv::I_NOP;
            id_bus_o.pipeline_stall <= 1'b1; 
            //id_bus_o.rd_res = '0;
        end
        else begin
            id_bus_o <= id_bus;
        end
        
    end

endmodule