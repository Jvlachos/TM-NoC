`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 18:35:45
// Design Name: 
// Module Name: InputUnitFSM
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


module InputUnitFSM
    import router_pkg::*;
    (
    input clk,
    input reset_n,
    input FLIT_t i_flit,
    input logic i_switch_ack,
    input GLOBAL_STATE_t  i_outstate,
    input logic routing_success,
    output GLOBAL_STATE_t o_gstate,
    output logic o_switch_req,
    output ROUTE_t o_route,
    output logic o_packet_done
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    assign o_gstate = GLOBAL_STATE_t'(next_state);
    logic send_done;
    
    always_comb begin
        next_state = IDLE;
         unique case(curr_state)
                IDLE : next_state = i_flit.flit[FLIT_SIZE-1] && i_flit.head.flit_type == FLIT_TYPE_t'(HEAD_FLIT) ? ROUTING : IDLE;
                ROUTING : next_state = routing_success ? ACTIVE : ROUTING;
                ACTIVE : next_state = send_done ? IDLE : ACTIVE;
                WAITING : next_state = routing_success ? ROUTING : WAITING;
                default : ;
         endcase 
    end
    
    assign o_packet_done = send_done;
    
    always_comb begin
        o_route = {1'b1,{NUM_OF_PORTS_BITS-1{1'b0}}}; //invalid  1msb 0000lsbs
        send_done = 0;
         case(curr_state)
                IDLE : begin
                
                end
                ROUTING : begin
                   
                end
                ACTIVE : begin
                    if(i_flit.tail.valid && i_flit.tail.flit_type == FLIT_TYPE_t'(TAIL_FLIT))
                        send_done = 1;
                end
                WAITING : begin 
                
                end
         endcase
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
        
    end
endmodule
