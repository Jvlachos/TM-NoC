module predictor_cntrl
    import  core::*;
(
    input logic clk,
    input logic rst,
    input core::br_cntrl_bus_t br_cntrl_i,
    input  bit is_branch_i,
    input  logic [31:0] read_addr_i,
    input  logic [31:0] read_addr_b_i,
    output bit prediction_o,
    output bit pred2id
);

    localparam DH = 1;
    localparam ghr_sel = core::GHR_SELECT -1;
    localparam pc_sel  = core::PC_SELECT  -1;

    logic [core::COUNTER_TABLE_BITS-1:0] r_addr;
    logic [core::COUNTER_TABLE_BITS-1:0] r_addr_b;
    logic [core::COUNTER_TABLE_BITS-1:0] w_addr;
    logic [core::GHR_SIZE-1:0] GHR_ff;
    logic [core::GHR_SIZE-1:0] ghr;
    core::cntr_table_entry_t cntr_table [0:core::COUNTER_TABLE_SZ-1];
    core::cntr_pattern_t curr_state;
    core::cntr_pattern_t next_state;
    bit taken;
    logic [core::COUNTER_TABLE_BITS-1:0] tmp;

  //  assign tmp = {GHR_ff[ghr_sel:0],read_addr_i[12:5]};
    
    assign taken = br_cntrl_i.is_taken;
    
    assign r_addr = {GHR_ff[ghr_sel:0] ,read_addr_i[2+:pc_sel]};
    assign r_addr_b = {GHR_ff[ghr_sel:0],read_addr_b_i[2+:pc_sel]};
    assign w_addr = {GHR_ff[ghr_sel:0] , br_cntrl_i.i_addr[2+:pc_sel]};

    // assign r_addr = tmp ^ read_addr_i[4:0];
    //assign r_addr_b = tmp ^ read_addr_i[4:0];
    //ssign w_addr   = {GHR_ff[ghr_sel:0],br_cntrl_i.i_addr[4:0]} ^ br_cntrl_i.i_addr[6:0];


    assign #DH prediction_o = cntr_table[r_addr].counter[1];
    assign #DH pred2id = cntr_table[r_addr_b].counter[1];
    

    always @(posedge clk,negedge rst) begin
        if(~rst)
            GHR_ff <= '0;
        else if(is_branch_i) begin
            cntr_table[w_addr].counter <= next_state;
            GHR_ff <= ghr;
           // $display("COUNTER %b GHR %b ADDR %0d PC : %x Taken : %0b\n ",next_state,ghr,w_addr,br_cntrl_i.i_addr,taken);
        end
    end


    always_comb begin
        curr_state = cntr_table[w_addr].counter;
        //next_state = core::STRONGLY_NOT_TAKEN;
        ghr = '0;
        if(is_branch_i) begin
            ghr = GHR_ff << 1;
            ghr[0] = taken;
            unique case (curr_state)
                core::STRONGLY_NOT_TAKEN:begin
                    next_state = taken ? core::WEAKLY_NOT_TAKEN : core::STRONGLY_NOT_TAKEN;   
                end
                core::WEAKLY_NOT_TAKEN:begin
                    next_state = taken ? core::WEAKLY_TAKEN : core::STRONGLY_NOT_TAKEN;
                end
                core::WEAKLY_TAKEN: begin
                    next_state = taken ? core::STRONGLY_TAKEN : core::WEAKLY_NOT_TAKEN;
                end
                core::STRONGLY_TAKEN: begin
                    next_state = taken ? core::STRONGLY_TAKEN : core::WEAKLY_TAKEN;
                end 
                
            endcase
        end
    end    
    

    initial begin
        assert (core::PC_SELECT + core::GHR_SELECT == core::COUNTER_TABLE_BITS) 
        else   $finish;
        for(int i = 0; i < core::COUNTER_TABLE_SZ; i++) begin
            cntr_table[i] = '0;
        end
    end
endmodule