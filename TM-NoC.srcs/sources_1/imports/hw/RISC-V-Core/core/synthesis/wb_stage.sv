module wb_stage 
    import riscv::*;
    import core::*;
(
    input logic clk,
    input logic rst,
    input core::pipeline_bus_t bus_i,
    output core::pipeline_bus_t wb_bus_o,
    output bit unstall_o,
    output core::bypass_bus_t wb_bp_o,
    output core::pipeline_bus_t wb_late_o,
    output core::bypass_bus_t wb_bp_late_o);


    logic [31:0] rd;
    
    //always_comb begin 
      //  if(bus_i.alu_op != core::ALU_NOP || bus_i.mem_op!= core::MEM_NOP)
        //    rd = bus_i.rd_res;
       // else
         //   rd = '0;
    //end
    assign wb_bp_o.rd = bus_i.rd_res;
    assign wb_bp_o.rd_addr = bus_i.rd;
    assign wb_bus_o = bus_i;

    always_ff @( posedge clk) begin 
            unstall_o <= bus_i.pipeline_stall;
    end
    assign wb_bp_late_o.rd = wb_late_o.rd_res;
    assign wb_bp_late_o.rd_addr = wb_late_o.rd;

    always_ff @( posedge clk,negedge rst ) begin  
       if(~rst) begin
            wb_late_o[core::BUS_BITS-1:0] <= '0;
            wb_late_o.mem_op <= core::MEM_NOP;
            wb_late_o.alu_op <= core::ALU_NOP;
            wb_late_o.format <= core::NOP;
            wb_late_o.instr <= riscv::I_NOP;
            wb_late_o <= '0;
       end
        else
            wb_late_o <= bus_i;
    end


    
endmodule