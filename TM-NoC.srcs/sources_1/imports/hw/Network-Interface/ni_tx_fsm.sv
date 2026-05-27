`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 05:36:45 PM
// Design Name: 
// Module Name: ni_tx_fsm
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

import ni_pkg::*;
module ni_tx_fsm #(parameter INDEX_TAG = 0)(
    input clk,
    input rst_n,
    input logic i_rx_request,
    output logic o_rx_ack,
    input RX_CNTRL_t i_reg_data,
    output logic [NI_MEM_WIDTH-1:0] o_rx_waddr,
    output logic o_rx_mem_wen,
    output logic o_rx_reg_wen
    );
    
    
    ni_tx_state_t curr_state;
    ni_tx_state_t next_state;
    
    logic [NI_MEM_WIDTH-1:0] base_addr =  NI_RXMEM_SECTIONS_BASE + INDEX_TAG * NI_MEM_SECTION_SIZE;
    
    logic [NI_MEM_WIDTH-1:0] rx_waddr;
    logic [NI_MEM_WIDTH-1:0] rx_waddr_ff;
    assign o_rx_waddr = rx_waddr_ff;
    always_comb begin
        unique case(curr_state)
            NI_IDLE :    next_state = i_rx_request  ? NI_SENDING :  NI_IDLE;
            NI_WAITING : ;
            NI_SENDING : next_state = i_reg_data.valid ? NI_DONE: NI_IDLE;
            NI_DONE    : next_state = NI_IDLE;
            default:; 
        endcase
    
    end
    
        
    always_comb begin 
        //tx_raddr = base_addr ;
        o_rx_ack = 0;
        o_rx_waddr = '0;
        o_rx_mem_wen = 0;
        o_rx_reg_wen = 0;
        unique case(curr_state)
            NI_IDLE: begin
                if(i_rx_request) begin
                    o_rx_ack = 1;
                end
            end
            NI_WAITING : begin
               
            end
            NI_SENDING : begin
                o_rx_waddr = rx_waddr_ff;
                o_rx_mem_wen = 1;
            end
            NI_DONE : begin
               o_rx_reg_wen = 1;
                
            end
            
        endcase
    
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            rx_waddr_ff <= base_addr;
        else if(curr_state == NI_SENDING)
            rx_waddr_ff <= rx_waddr_ff + NI_MEM_DATA_BYTES;
        else if(curr_state == NI_DONE ) rx_waddr_ff <= base_addr;
        else    rx_waddr_ff <= rx_waddr_ff;
    end 
    
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            curr_state <= NI_IDLE;
        else begin
            curr_state <= next_state;
        end 
    end
endmodule
     

