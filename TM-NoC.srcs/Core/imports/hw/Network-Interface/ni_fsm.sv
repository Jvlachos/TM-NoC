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
module ni_fsm
(
    input clk,
    input rst_n,
    logic i_last_word,
    logic [NI_MEM_WIDTH-1:0] o_tx_raddr,
    logic o_tx_done,
    logic i_tx_request,
    logic o_tx_request,
    logic i_tx_ack
    );
    
    ni_tx_state_t curr_state;
    ni_tx_state_t next_state;
    
    logic [NI_MEM_WIDTH-1:0] tx_raddr;
    
    always_comb begin
        unique case(curr_state)
            NI_IDLE :    next_state = i_req.request  ? NI_WAITING :  NI_IDLE;
            NI_WAITING : next_state = i_req.ack ? NI_SENDING : NI_WAITING;
            NI_SENDING : next_state = i_last_word ? NI_IDLE : NI_SENDING;
            default:; 
        endcase
    
    end
    
    always_comb begin 
        unique case(curr_state)
            NI_IDLE: begin
            
            end
            NI_WAITING : begin
            
            end
            NI_SENDING : begin
            
            end
            
        endcase
    
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            curr_state <= NI_IDLE;
        else begin
            curr_state <= next_state;
        end 
    end
endmodule
