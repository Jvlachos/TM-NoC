module if_stage
    import core::*;
(
    input  logic clk,
    input  logic rst,
    input  logic [core::DATA_WIDTH-1:0] wdata_i,
    input  logic [core::DATA_BYTES-1:0] wen_i,
    input  logic pc_incr_en_i,
    output logic [31:0] instr_o,
    output logic [31:0] pc_o,
    input core::br_cntrl_bus_t br_bus_i,
    input core::btb_entry_t btb_entry_i,
    input bit prediction_i
);

    logic [31:0] pc;
    
    bit entry_found;
    bit branch_instr;
    bit target_jump_en;
    logic [6:0] op;
    assign entry_found = btb_entry_i.i_addr != '0;
    assign op = instr_o[6:0];
    assign branch_instr = op == riscv::B_OP ||  op == riscv::JAL_OP || op == riscv::JALR_OP; 
    assign target_jump_en = entry_found & prediction_i & ~br_bus_i.mispredict & branch_instr & pc_incr_en_i;
    logic [31:0] instr;

    mem_sync_sp 
    #(.INIT_FILE("C:\\Users\\dvlac\\Desktop\\TM-NoC\\hw\\RISC-V-Core\\code\\ihex\\code.hex"),
      .ADDR_WIDTH(core::ADDR_WIDTH),
      .DEPTH(core::DEPTH),
      .DATA_WIDTH(core::DATA_WIDTH),
      .DATA_BYTES(core::DATA_BYTES))
    i_mem (
    .clk(clk),
    .i_addr(pc[core::ADDR_WIDTH+1:2]),
    .i_wdata(wdata_i),
    .i_wen(wen_i),
    .o_rdata(instr_o));

    //assign instr_o = br_bus_i.mispredict ? riscv::I_NOP : instr;
     always_comb begin  
        pc = 'h100;
       // $display("ENTRY TARGET : %0x\n",btb_entry_i.target_addr);
        if(~pc_incr_en_i )
            pc = pc_o;
        else if(br_bus_i.mispredict) begin
            pc = br_bus_i.mispredict_target;
           // $display("PC MIS : %0x\n",pc);
        end
        else if(target_jump_en) begin
            pc = btb_entry_i.target_addr;
        end
    
        else if(pc_incr_en_i) begin
                pc = pc_o +4 ; 
        end
        else
            ;
        
        
    end
  /*  always_comb begin  
        pc = 'h100;
        if(br_bus_i.is_taken) begin
            pc = br_bus_i.branch_target;
        end
        else if(pc_incr_en_i) begin 
            pc = pc_o + 4;            
        end
        else begin
            pc = pc_o;
        end
    end */
    
    always_ff @(posedge clk,negedge rst ) begin  
        if(~rst) begin
            pc_o <= 'h100;
        end
 
        //else if(target_jump_en) begin
         //   pc_o <= btb_entry_i.target_addr;
            
            //$display("J to target:%x PC: %x PRED: %0b\n",btb_entry_i.target_addr,btb_entry_i.i_addr,prediction_i);
      //  end
        else begin
            pc_o <= pc;
            //$display(" pc :%x\n",pc);
            //$display("ENTRY at %x with ENTRY PC : %x\n",pc,btb_entry_i.i_addr);
        end
    end
    
endmodule