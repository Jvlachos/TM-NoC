
import core::*;
interface mem_bus_if;
    
    logic [DATA_BYTES-1:0] write_en;
    logic [31:0] addr;
    logic [31:0] w_data;
    logic [31:0] r_data;
    
    modport memory_master(output write_en, addr, w_data);
    modport memory_slave(input write_en, addr, w_data);
endinterface
