module load_cntrl 
    import riscv::*;
    import core::*;
(
    input core::pipeline_bus_t bus_i,
    input logic [31:0] rdata_i,
    output core::pipeline_bus_t mem2se_o,
    input logic [31:0] addr
);

    always_comb begin
        mem2se_o.mem_op = bus_i.mem_op;
        mem2se_o.alu_op   = bus_i.alu_op;
        mem2se_o.format   = bus_i.format;
        mem2se_o.is_branch= bus_i.is_branch;
        mem2se_o.instr    = bus_i.instr;
        mem2se_o.imm      = bus_i.imm;
        mem2se_o.rs1      = bus_i.rs1;
        mem2se_o.rs2      = bus_i.rs2;
        mem2se_o.rd       = bus_i.rd;
        mem2se_o.rs1_data = bus_i.rs1_data;
        mem2se_o.rs2_data = bus_i.rs2_data;
        mem2se_o.pc       = bus_i.pc;
        mem2se_o.rf_wr_en = bus_i.rf_wr_en;
        mem2se_o.pipeline_stall = bus_i.pipeline_stall;
        mem2se_o.rd_res = 32'b0;

       // $display("BUS I : %0d MEM2SE %0d\n",bus_i.rd_res,mem2se_o.rd_res);
        if(bus_i.mem_op != core::MEM_NOP && bus_i.mem_op[MEM_OP_BITS-1] == core::LOAD_PRFX )begin
           // $display("RD_DATA :0x%0h\n",rdata_i);
           unique case(bus_i.mem_op)
                core::LB:begin
                    mem2se_o.rd_res[7:0] = rdata_i[addr[1:0]*8+:8]; 
                end
                core::LH:begin
                    //mem2se_o.rd_res[15:0] = rdata_i[addr[1:0]*8+:16];
                    case(addr[1:0])
                        2'b00: begin
                            mem2se_o.rd_res[15:0] = rdata_i[15:0];
                        end
                        2'b01: begin
                           $display("MISSALIGNED LOAD?\n"); 
                            mem2se_o.rd_res[15:0] = rdata_i[23:8];
                            
                        end
                        2'b10: begin
                            mem2se_o.rd_res[15:0] = rdata_i[31:16];
                        end
                        default: begin
                            ;
                        end
                    endcase
                end
                core::LW:begin
                    mem2se_o.rd_res[31:0] = rdata_i[31:0];
                end
                core::LBU:begin
                    mem2se_o.rd_res [7:0] = rdata_i[addr[1:0]*8+:8]; 
                end
                core::LHU:begin
                     case(addr[1:0])
                        2'b00: begin
                            mem2se_o.rd_res[15:0] = rdata_i[15:0];
                        end
                        2'b01: begin
                            mem2se_o.rd_res[15:0] = rdata_i[23:8];
                           $display("MISSALIGNED LOAD?\n"); 
                        end
                        2'b10: begin
                            mem2se_o.rd_res[15:0] = rdata_i[31:16];
                        end
                        default: begin
                            ;
                        end
                    endcase
                end
            endcase 
        end
        else begin 
            mem2se_o.rd_res = bus_i.rd_res;
        end
    
    end

    
endmodule