module mem_signext 
    import core::*;
(
    input core::pipeline_bus_t bus_i,
    output core::pipeline_bus_t bus_o,
    output core::bypass_bus_t bp_o,
    input logic[1:0] addr_offset_i
); 

   
    always_comb begin 
        bus_o.mem_op = bus_i.mem_op;
        bus_o.alu_op   = bus_i.alu_op;
        bus_o.format   = bus_i.format;
        bus_o.is_branch= bus_i.is_branch;
        bus_o.instr    = bus_i.instr;
        bus_o.imm      = bus_i.imm;
        bus_o.rs1      = bus_i.rs1;
        bus_o.rs2      = bus_i.rs2;
        bus_o.rd       = bus_i.rd;
        bus_o.rs1_data = bus_i.rs1_data;
        bus_o.rs2_data = bus_i.rs2_data;
        bus_o.pc       = bus_i.pc;
        bus_o.pipeline_stall = bus_i.pipeline_stall;
        bus_o.rd_res = 32'b0;
        bp_o.rd = 32'b0;
        bp_o.rd_addr = 32'b0;

        if(bus_i.mem_op != core::MEM_NOP && bus_i.mem_op[MEM_OP_BITS-1] == core::LOAD_PRFX) begin
         
            //$display("MEMSE :0x%0h\n",bus_i.rd_res); //if its a load give the result to wb and bypass
            unique case (bus_i.mem_op)
                core::LB:begin
                   bus_o.rd_res = {{24{bus_i.rd_res[7]}},bus_i.rd_res[7:0]};
                end
                core::LH:begin
                    bus_o.rd_res = {{16{bus_i.rd_res[15]}},bus_i.rd_res[15:0]};
                    //$display("MEMSE bus_o RD:0x%0h\n",bus_o.rd_res); 
                end
                core::LW:begin
                    bus_o.rd_res = bus_i.rd_res;
                end
                core::LBU:begin
                    bus_o.rd_res = {24'b0,bus_i.rd_res[7:0]};
                end
                core::LHU:begin
                    bus_o.rd_res = {16'b0,bus_i.rd_res[15:0]};
                end
            endcase
            bus_o.rf_wr_en = 1;
            bp_o.rd = bus_o.rd_res;
            bp_o.rd_addr = bus_o.rd;
        end
        else if(bus_i.mem_op!= core::MEM_NOP && bus_i.mem_op[MEM_OP_BITS-1] == core::STORE_PRFX) begin //if its a store bypass the sign extended value,don't give it to wbi
            bp_o.rd_addr = bus_i.rd;
            bus_o.rf_wr_en = 0;
        end
        else begin //if neither pass regular values to bp and wb
            bus_o.rd_res = bus_i.rd_res;
            bp_o.rd = bus_i.rd_res;
            bp_o.rd_addr = bus_i.rd;
            bus_o.rf_wr_en = bus_i.rf_wr_en;
        end

    end
    
endmodule