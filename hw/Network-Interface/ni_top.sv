`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2026 02:47:43
// Design Name: 
// Module Name: ni_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ni_top(
    input clk,
    input rst_n,
    mem_bus_if mem_bus
    );
    logic txfront_to_fsm_req [MEM_MAPPED_REGS-1:0];
    logic txfsm_to_back_req [MEM_MAPPED_REGS-1:0];
    logic txback_to_fsm_ack [MEM_MAPPED_REGS-1:0];
    logic tx_last_word [MEM_MAPPED_REGS-1:0];
    logic [NI_MEM_WIDTH-1:0] tx_raddr  [MEM_MAPPED_REGS-1:0];
    logic tx_done [MEM_MAPPED_REGS-1:0];
    
    ni_frontend ni_front(
        .clk(clk),
        .rst_n(rst),
        .mem_bus(mem_bus),
        .o_tx_req(txfront_to_fsm_req)
    );
    
   
    
    genvar i;
    generate
        for(i=0; i<MEM_MAPPED_REGS; i++) begin
            ni_fsm tx_fsm(
             .clk(clk),
             .rst_n(rst_n), 
             .i_last_word(tx_last_word[i]),
             .o_tx_raddr(tx_raddr[i]),
             .o_tx_done(tx_done[i]),
             .i_tx_request(txfront_to_fsm_req[i]),
             .o_tx_request(txfsm_to_back_req[i]),
             .i_tx_ack(txback_to_fsm_ack[i]));
            
            ni_fsm rx_fsm();
        end
    endgenerate
    
    
endmodule
