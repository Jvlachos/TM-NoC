module metrics_cntrl 
    import riscv::*;
    import core::*;
(
    input logic clk,
    input logic rst,
    output core::metrics_t metrics_o, 
    input  core::pipeline_bus_t ex_bus,
    input  bit flush_i
);

    core::metrics_t metrics;
   
    bit invalid_instr;
    assign invalid_instr = ex_bus.mem_op == core::MEM_NOP && ex_bus.alu_op == core::ALU_NOP ;

    always_comb begin
        metrics.br_metrics.no_conditional = '0;
        metrics.br_metrics.no_jumps       = '0;
        metrics.br_metrics.mispredictions = '0;
        metrics.total_ins          = '0;
        
     if(ex_bus.is_branch) begin
        if(ex_bus.alu_op[4:3] == core::BRANCH_PRFX) begin
            
            metrics.br_metrics.no_conditional = metrics_o.br_metrics.no_conditional + 1;
        end
        else
            metrics.br_metrics.no_conditional = metrics_o.br_metrics.no_conditional;
           
        if(ex_bus.alu_op[4:3] == core::J_PRFX) begin
            metrics.br_metrics.no_jumps = metrics_o.br_metrics.no_jumps + 1;
        end
        else
            metrics.br_metrics.no_jumps = metrics_o.br_metrics.no_jumps;
     end
     else begin
        metrics.br_metrics.no_conditional = metrics_o.br_metrics.no_conditional;
        metrics.br_metrics.no_jumps = metrics_o.br_metrics.no_jumps;
     end

     if(~invalid_instr) begin
        metrics.total_ins = metrics_o.total_ins + 1;
     end
     else
        metrics.total_ins = metrics_o.total_ins;
    
    if(flush_i)
        metrics.br_metrics.mispredictions = metrics_o.br_metrics.mispredictions + 1;
    else
        metrics.br_metrics.mispredictions = metrics_o.br_metrics.mispredictions;
    
    end

    always_ff @(posedge clk,negedge rst ) begin : blockName
        if(~rst)
            metrics_o <= '0;
        else begin
            metrics_o <= metrics;
        end

    end

endmodule