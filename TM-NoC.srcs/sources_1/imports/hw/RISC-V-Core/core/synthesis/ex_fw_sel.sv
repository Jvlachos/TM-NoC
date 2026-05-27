module ex_fw_sel 
    import core::*;
(
    input core::pipeline_bus_t bus_i,
    input core::fw_cntrl_bus_t fw_cntrl_i,
    input core::bypass_bus_t mem_bypass_i,
    input core::bypass_bus_t wb_bypass_i,
    input core::bypass_bus_t wb_bypass_late_i,
    output logic [31:0] rs1_in_o,
    output logic [31:0] rs2_in_o
);


    always_comb begin : blockName
        rs1_in_o = 32'b0;
        rs2_in_o = 32'b0;
       // $display("FW FROM : %s - %s\n ",fw_cntrl_i.rs1.name,fw_cntrl_i.rs2.name);
        if(fw_cntrl_i.rs1 == core::MEM_STAGE)
            rs1_in_o = mem_bypass_i.rd;
        else if(fw_cntrl_i.rs1 == core::WB_STAGE)
            rs1_in_o = wb_bypass_i.rd;
        else if(fw_cntrl_i.rs1 == core::WBLATE_STAGE)
            rs1_in_o = wb_bypass_late_i.rd;
        else
            rs1_in_o = bus_i.rs1_data;
        
        if(fw_cntrl_i.rs2 == core::MEM_STAGE)
            rs2_in_o = mem_bypass_i.rd;
        else if(fw_cntrl_i.rs2 == core::WB_STAGE)
            rs2_in_o = wb_bypass_i.rd;
        else if(fw_cntrl_i.rs2 == core::WBLATE_STAGE)
            rs2_in_o = wb_bypass_late_i.rd;
        else    
            rs2_in_o = bus_i.rs2_data;

    end
    
endmodule