module fw_controller 
    import riscv::*;
    import core::*;
(
    input logic clk,
    input logic rst,
    input core::pipeline_bus_t id_bus_i,
    input core::pipeline_bus_t ex_bus_i,
    input core::pipeline_bus_t mem_bus_i,
    input core::pipeline_bus_t wb_bus_i,
    input core::pipeline_bus_t wb_late_bus_i,
    output core::fw_cntrl_bus_t fw_cntrl_o   
);

    core::fw_cntrl_bus_t fw_cntrl;
    logic [4:0] rs1_id,rs2_id;
    logic [4:0] rd_ex,rd_mem,rd_wb,rd_wb_late;
    bit fw_from_mem;
    bit fw_from_wb;
    //if mem stage has a load
    always_comb begin : fw
        //rs1_id = id_bus_i.rs1;
        ///rs2_id = id_bus_i.rs2;
        rs1_id = ex_bus_i.rs1;
        rs2_id = ex_bus_i.rs2;
        rd_ex  = ex_bus_i.rd;
        rd_mem = mem_bus_i.rd;
        rd_wb  = wb_bus_i.rd;
        rd_wb_late = wb_late_bus_i.rd;
        fw_cntrl.stage = core::NONE_STAGE;
        fw_cntrl.regs  = core::RS_NONE;
        fw_cntrl.rs1 = core::NONE_STAGE;
        fw_cntrl.rs2 = core::NONE_STAGE;

            if((rs1_id == rd_mem && rd_mem!='0) && mem_bus_i.rf_wr_en == 1 ) begin
                fw_cntrl.rs1 = core::MEM_STAGE;
                fw_cntrl.rs1_addr = rd_mem;
            end
            else if((rs1_id == rd_wb && rd_wb !='0) && wb_bus_i.rf_wr_en == 1) begin
                fw_cntrl.rs1 = core::WB_STAGE;
                fw_cntrl.rs1_addr = rd_wb;
            end
            else if((rs1_id == rd_wb_late && rd_wb_late!='0) && wb_late_bus_i.rf_wr_en == 1) begin
                fw_cntrl.rs1 = core::WBLATE_STAGE;
                fw_cntrl.rs1_addr = rd_wb_late;
            end
            else begin
                fw_cntrl.rs1 = core::NONE_STAGE;
                fw_cntrl.rs1_addr = '0;
            end

            if((rs2_id == rd_mem && rd_mem!='0) && mem_bus_i.rf_wr_en == 1) begin
                fw_cntrl.rs2 = core::MEM_STAGE;
                fw_cntrl.rs2_addr = rd_mem;
            end
            else if((rs2_id == rd_wb && rd_wb!='0) && wb_bus_i.rf_wr_en == 1) begin
                fw_cntrl.rs2 = core::WB_STAGE;
                fw_cntrl.rs2_addr = rd_wb;
            end
            else if((rs2_id == rd_wb_late && rd_wb_late!='0) && wb_late_bus_i.rf_wr_en == 1) begin
                fw_cntrl.rs2 = core::WBLATE_STAGE;
                fw_cntrl.rs2_addr = rd_wb_late;
            end
            else begin
                fw_cntrl.rs2 = core::NONE_STAGE;
                fw_cntrl.rs2_addr = '0;
            end
 
    end



    assign fw_cntrl_o = fw_cntrl;


    
    
endmodule