module memory_unit 
    import riscv::*;
    import core::*;
(
    input core::pipeline_bus_t bus_i,
    output core::mem_cntrl_bus_t mem_bus,
    input logic [31:0] rs1_in_i,
    input logic [31:0] rs2_in_i
);

    bit is_mem;
    assign is_mem = ~bus_i.is_branch &&
     bus_i.alu_op == core::ALU_NOP   && 
     bus_i.mem_op != core::MEM_NOP; 

    always_comb begin : address_gen
        mem_bus.write_en  = '0;
        mem_bus.addr   = 32'b0;
        mem_bus.r_data = 32'b0;
        mem_bus.w_data = 32'b0;
        mem_bus.mem_op = core::MEM_NOP;
        mem_bus.mem_rd = '0;
        if(is_mem) begin
            mem_bus.addr= rs1_in_i + bus_i.imm;
            mem_bus.mem_op = bus_i.mem_op;
            if(bus_i.mem_op[MEM_OP_BITS-1] == core::STORE_PRFX)
                mem_bus.w_data = rs2_in_i;
            else begin
                mem_bus.mem_rd = bus_i.rd;
            end
        end
        else
            ;
        
    end
    
endmodule