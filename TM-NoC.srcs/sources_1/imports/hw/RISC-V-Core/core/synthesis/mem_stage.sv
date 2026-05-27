module mem_stage
    import riscv::*;
    import core::*;
    import ni_pkg::*;
#(parameter NODE_IDX = 69)(
   input logic clk,
   input logic rst,
   input core::pipeline_bus_t bus_i,
   input core::mem_cntrl_bus_t mem_cntrl_i,
   output core::pipeline_bus_t mem_bus_o,
   output core::bypass_bus_t mem_bp_o,
   mem_bus_if mem_if_master_o
   
);

    logic [31:0] rdata;  
    logic [31:0] ld_data;  
    logic [31:0] addr;
   // assign addr = exmemop[MEM_OP_BITS-1] == core::LOAD_PRFX ? ld_addr : bus_i.mem_addr;
    
    
    core::mem_cntrl_bus_t store_cntrl;
    core::pipeline_bus_t mem2se;
    core::pipeline_bus_t mem2wb;
    logic [DATA_BYTES-1:0] mem_write_en;
    logic [31:0]           mem_w_data;

    always_ff@(posedge clk,negedge rst) begin
        if(~rst) 
            addr <= '0;
        else
            addr <= mem_cntrl_i.addr;
    end
    

    load_cntrl load_unit(
        .bus_i(bus_i),
        .rdata_i(ld_data),
        .mem2se_o(mem2se),
        .addr(addr));

    store_cntrl store_unit(
        .bus_i(mem_cntrl_i),
        .store_cntrl_o(store_cntrl));

    mem_signext mem_signext_inst(
        .bus_i(mem2se),
        .bus_o(mem2wb),
        .bp_o(mem_bp_o),
        .addr_offset_i(addr[1:0]));
        
    logic isExt;
    assign isExt = (unsigned'(mem_cntrl_i.addr) >= NI_MAPPED_REGS_BASE) && (unsigned'(mem_cntrl_i.addr) <= NI_MEM_END);
    logic isLoad;
    assign isLoad = mem_cntrl_i.mem_op != core::MEM_NOP && mem_cntrl_i.mem_op[MEM_OP_BITS-1] == core::LOAD_PRFX;
    logic isStore;
    assign isStore = mem_cntrl_i.mem_op != core::MEM_NOP && mem_cntrl_i.mem_op[MEM_OP_BITS-1] == core::STORE_PRFX;
    logic isIdReg;
    assign isIdReg = (unsigned'(mem_cntrl_i.addr) == NI_MEM_BASE );
    
    logic [31:0] id_reg_data;
    
    mem_mapped_reg #(.REG_NAME("ID_REG"), .READ_ONLY(1))
    id_reg (
        .clk(clk),
        .rst_n(rst),
        .i_per_we('0),
        .i_per_din('0),
        .o_per_dout(id_reg_data),
        .i_init_data(NODE_IDX)
    );
    
    
    mem_sync_sp_rvdmem #
    (.DATA_WIDTH(core::DATA_WIDTH),
    .INIT_FILE("C:\\Users\\Dimitris\\Desktop\\TM-NoC\\hw\\RISC-V-Core\\code\\ihex\\codemem.hex"))
    memory_instance(
        .clk(clk),
        .i_addr(mem_cntrl_i.addr),
        .i_wdata(mem_w_data),
        .i_wen(mem_write_en),
        .o_rdata(rdata)
    );
    always_ff @(posedge clk, negedge rst) begin
        if(~rst)
            ld_data <= '0;
        else if (isExt) begin
            ld_data <= mem_if_master_o.r_data;
        end
        else if(isIdReg) begin
            ld_data <= id_reg_data;
        end
        else 
            ld_data <= rdata;
    end
    
    always_comb begin : mem_cntrl
        mem_write_en ='0;
        mem_w_data   ='0;
        mem_if_master_o.write_en = '0;
        mem_if_master_o.addr     = '0;
        mem_if_master_o.w_data   = '0;
        if(isExt) begin
           // if(NODE_IDX == 2)
               // $display("External address %0h data %0h: \n",mem_cntrl_i.addr, store_cntrl.w_data);
            if(isLoad) begin
                mem_write_en = '0;
                mem_w_data   = '0;
                mem_if_master_o.write_en = '0;
                mem_if_master_o.addr     = mem_cntrl_i.addr;
                mem_if_master_o.w_data   = '0;
             
            end
            else if(isStore) begin
                mem_write_en = '0;
                mem_w_data   = '0;
                mem_if_master_o.write_en = store_cntrl.write_en;
                mem_if_master_o.addr     = mem_cntrl_i.addr;
                mem_if_master_o.w_data   = store_cntrl.w_data;
                
 
            end
        end
        else if(isIdReg) begin
             mem_write_en = '0;
             mem_w_data   = '0;
             mem_if_master_o.write_en = '0;
             mem_if_master_o.addr     = '0;
             mem_if_master_o.w_data   = '0;
        
        end
        else begin
            mem_write_en = store_cntrl.write_en;
            mem_w_data   = store_cntrl.w_data;
            mem_if_master_o.write_en = '0;
            mem_if_master_o.addr     = '0;
            mem_if_master_o.w_data   = '0;
        end
    
    end
    
    always_ff @( posedge clk,negedge rst ) begin : blockName
       if(~rst) begin
            mem_bus_o[core::BUS_BITS-1:0] <= '0;
            mem_bus_o.mem_op <= core::MEM_NOP;
            mem_bus_o.alu_op <= core::ALU_NOP;
            mem_bus_o.format <= core::NOP;
            mem_bus_o.instr <= riscv::I_NOP;
            mem_bus_o <= '0;
        end    
        else begin
            mem_bus_o <= mem2wb;
        end
    end

endmodule