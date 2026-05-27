`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2026 01:48:00
// Design Name: 
// Module Name: ni_fsm
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
module ni_fsm #(parameter INDEX_TAG = 0)
(
    input clk,
    input rst_n,
    input logic i_last_word,
    output logic [NI_MEM_WIDTH-1:0] o_tx_raddr,
    output logic o_tx_done,
    input logic i_tx_request,
    output logic o_tx_request,
    input logic i_tx_ack,
    output logic o_mem_ren
    );
    
    ni_tx_state_t curr_state;
    ni_tx_state_t next_state;
    
    logic [NI_MEM_WIDTH-1:0] base_addr =  NI_MEM_SECTIONS_BASE + INDEX_TAG * NI_MEM_SECTION_SIZE;
    
    logic [NI_MEM_WIDTH-1:0] tx_raddr;
    logic [NI_MEM_WIDTH-1:0] tx_raddr_ff;
    assign o_tx_raddr = tx_raddr_ff;
    always_comb begin
        unique case(curr_state)
            NI_IDLE :    next_state = i_tx_request  ? NI_WAITING :  NI_IDLE;
            NI_WAITING : next_state = i_tx_ack ?  NI_SENDING : NI_WAITING;
            NI_SENDING : next_state = i_last_word ? NI_DONE: NI_SENDING;
            NI_DONE    : next_state = NI_IDLE;
            default:; 
        endcase
    
    end
    
    always_comb begin 
        //tx_raddr = base_addr ;
        o_mem_ren = 0;
        o_tx_request = 0;
        unique case(curr_state)
            NI_IDLE: begin
            
            end
            NI_WAITING : begin
                o_tx_request = 1;
                //if(i_tx_ack) 
                 //   o_mem_ren=1 ;
            end
            NI_SENDING : begin
                //tx_raddr = tx_raddr_ff + NI_MEM_DATA_BYTES;
                o_tx_request = 1;
                o_mem_ren = 1;
            end
            NI_DONE : begin
                o_tx_request = 1;
                
            end
            
        endcase
    
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            tx_raddr_ff <= '0;
        else if(curr_state == NI_SENDING)
            tx_raddr_ff <= tx_raddr_ff + NI_MEM_DATA_BYTES;
        else
            tx_raddr_ff <= base_addr;
        end 
    
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            curr_state <= NI_IDLE;
        else begin
            curr_state <= next_state;
        end 
    end
endmodule
