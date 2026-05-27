module store_cntrl 
    import riscv::*;
    import core::*;
(
    input core::mem_cntrl_bus_t bus_i,
    output core::mem_cntrl_bus_t store_cntrl_o
);

    always_comb begin : store_unit
        store_cntrl_o.addr = bus_i.addr;
        store_cntrl_o.r_data = '0;
        store_cntrl_o.w_data = 32'b0;
        store_cntrl_o.write_en = '0;
        if(bus_i.mem_op != core::MEM_NOP && bus_i.mem_op[MEM_OP_BITS-1] == core::STORE_PRFX) begin
           //$display("STORE DATA : %0d\n",bus_i.w_data);
            unique case(bus_i.mem_op)
                core::SB:begin
                    store_cntrl_o.write_en[bus_i.addr[1:0]+:1] = 1'b1;
                    //$display("BYTE EN : %b\n",store_cntrl_o.write_en);
                    store_cntrl_o.w_data[bus_i.addr[1:0]*8 +: 8] = bus_i.w_data[7:0];
                end
                core::SH:begin
                 //   store_cntrl_o.write_en[bus_i.mem_addr[1:0]+:2] = 2'b11;
                   // store_cntrl_o.w_data[bus_i.mem_addr[1:0]*8 +: 16] = bus_i.mem_w_data[15:0];

                    case(bus_i.addr[1:0])
                        2'b00: begin
                            store_cntrl_o.write_en = 4'b0011;
                            store_cntrl_o.w_data[15:0] = bus_i.w_data[15:0];
                        end
                        2'b01:begin
                            store_cntrl_o.write_en[2:1] = 2'b11;
                            store_cntrl_o.w_data[23:8] = bus_i.w_data[15:0];
                            $display("MISSALIGNED STORE? \n");
                        end
                        2'b10:begin
                            store_cntrl_o.write_en = 4'b1100;
                            store_cntrl_o.w_data[31:16] = bus_i.w_data[15:0];
                        end
                        default: ;

                    endcase
                end
                core::SW:begin
                   // $display("STORE ADDR: 0x%0h\n",bus_i.addr);
                    store_cntrl_o.write_en = 4'b1111;
                    store_cntrl_o.w_data[31:0] = bus_i.w_data[31:0];
                end
            endcase 
        end
        else begin
            ;
        end
    end



endmodule