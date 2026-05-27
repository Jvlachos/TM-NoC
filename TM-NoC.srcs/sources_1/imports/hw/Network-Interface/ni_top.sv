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


module  ni_top #(parameter NODE_IDX = 0)(
    input clk,
    input rst_n,
    output logic o_tx_router_request,
    input  logic i_tx_router_ack,
    output FLIT_t o_flit,
    input FLIT_t i_flit,
    input logic i_rx_router_req,
    output logic o_rx_router_ack,
    mem_bus_if mem_bus
    );
    logic txfront_to_fsm_req [MEM_MAPPED_REGS-1:0] = '{default: '0}; 
    logic txfsm_to_back_req [MEM_MAPPED_REGS-1:0]=  '{default: '0}; 
    logic txback_to_fsm_ack [MEM_MAPPED_REGS-1:0] =  '{default: '0}; 
    logic tx_last_word [MEM_MAPPED_REGS-1:0] =  '{default: '0}; ;
    logic [NI_MEM_WIDTH-1:0] tx_raddr  [MEM_MAPPED_REGS-1:0];
    logic tx_done [MEM_MAPPED_REGS-1:0];
    logic tx_mem_ren [MEM_MAPPED_REGS-1:0];
    logic [NI_DATA_SIZE-1:0] tx_mem_data [MEM_MAPPED_REGS-1:0];
    TX_CNTRL_t tx_regs_data [MEM_MAPPED_REGS-1:0];
    
    logic rx_backToFsm_req [MEM_MAPPED_REGS-1:0] = '{default: '0}; 
    logic rx_fsmToBack_ack [MEM_MAPPED_REGS-1:0] = '{default: '0}; 
    logic [NI_DATA_SIZE-1:0] rx_BackToFront_data ;
    logic rx_mem_wen [MEM_MAPPED_REGS-1:0];
    logic [NI_MEM_WIDTH-1:0] rx_waddr  [MEM_MAPPED_REGS-1:0];
    RX_CNTRL_t rx_reg_data [MEM_MAPPED_REGS-1:0];
    logic      rx_reg_wen [MEM_MAPPED_REGS-1:0];

    NI_DATA_BUS_t frontToBack_data [MEM_MAPPED_REGS-1:0];
    
    ni_frontend ni_front(
        .clk(clk),
        .rst_n(rst_n),
        .mem_bus(mem_bus),
        .o_tx_req(txfront_to_fsm_req),
        .i_tx_raddr(tx_raddr),
        .o_txdata(tx_mem_data),
        .o_tx_last_word(tx_last_word),
        .o_tx_regs_data(tx_regs_data),
        .i_rx_waddr(rx_waddr),
        .i_rx_mem_wen(rx_mem_wen),
        .i_rx_data(rx_BackToFront_data),
        .i_rx_reg_data(rx_reg_data),
        .i_rx_reg_wen(rx_reg_wen)
    );
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            frontToBack_data <= '{default : '0};
        else begin
            for(int i =0; i < MEM_MAPPED_REGS; i++) begin
                if(tx_mem_ren[i]) begin
                    frontToBack_data[i].ni_data <= tx_mem_data[i];
                    frontToBack_data[i].valid <= 1;
                end
                else begin
                    frontToBack_data[i].ni_data <= '0;
                    frontToBack_data[i].valid <= 0;
                end
            end
        end
            
    end
    
    ni_backend #(.NODE_IDX(NODE_IDX))ni_back(
        .clk(clk),
        .rst_n(rst_n),
        .tx_ni_request(txfsm_to_back_req),
        .tx_router_ack(i_tx_router_ack),
        .tx_ni_data(frontToBack_data),
        .i_tx_regs_data(tx_regs_data),
        .tx_router_request(o_tx_router_request),
        .tx_ni_ack(txback_to_fsm_ack),
        .o_tx_flit(o_flit),
        .rx_router_request(i_rx_router_req),
        .rx_router_ack(o_rx_router_ack),
        .i_flit(i_flit),
        .o_rx_ni_request(rx_backToFsm_req),
        .i_rx_ni_ack(rx_fsmToBack_ack),
        .o_rx_data(rx_BackToFront_data),
        .o_rx_reg_data(rx_reg_data)   
    );

    genvar i;
    generate
        for(i=0; i<MEM_MAPPED_REGS; i++) begin
            ni_fsm #(.INDEX_TAG(i)) tx_fsm (
             .clk(clk),
             .rst_n(rst_n), 
             .i_last_word(tx_last_word[i]),
             .o_tx_raddr(tx_raddr[i]),
             .o_tx_done(tx_done[i]),
             .i_tx_request(txfront_to_fsm_req[i]),
             .o_tx_request(txfsm_to_back_req[i]),
             .i_tx_ack(txback_to_fsm_ack[i]),
             .o_mem_ren(tx_mem_ren[i]));
             
            ni_tx_fsm #(.INDEX_TAG(i)) rx_fsm (
                .clk(clk),
                .rst_n(rst_n),
                .i_rx_request(rx_backToFsm_req[i]),
                .o_rx_ack(rx_fsmToBack_ack[i]),
                .i_reg_data(rx_reg_data[i]),
                .o_rx_waddr(rx_waddr[i]),
                .o_rx_mem_wen(rx_mem_wen[i]),
                .o_rx_reg_wen(rx_reg_wen[i])
            );
        end
    endgenerate
    
    
endmodule
