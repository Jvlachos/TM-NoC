`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 14:11:27
// Design Name: 
// Module Name: OutputUnitFSM
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


module OutputUnitFSM
    import router_pkg::*;
    (
    input clk,
    input reset_n,
    input logic i_downstream_ack,
    input logic i_switch_req,
    output logic o_switch_ack,
    output logic o_downstream_req,
    output GLOBAL_STATE_t o_gstate,
    output PORT_STATUS_t o_port_status
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    assign o_gstate = GLOBAL_STATE_t'(curr_state);
    logic activate;
    always_comb begin
        next_state = IDLE;
         unique case(curr_state)
                IDLE : next_state    = i_switch_req ? WAITING : IDLE;
                ROUTING : ;
                ACTIVE : next_state  = ACTIVE;
                WAITING : next_state = activate ? ACTIVE : WAITING;
                default : ;
         endcase 
    end
    
       always_comb begin
         activate = 0;
         o_switch_ack = 0;
         case(curr_state)
                IDLE : begin
                    
                end
                ROUTING : begin
                  assert (0) else $error("ROUTING not allowed in output");
                    
                end
                ACTIVE : begin
                
                end
                WAITING : begin 
                    o_downstream_req = 1;
                    if(i_downstream_ack) begin
                        activate = 1;
                        o_switch_ack = 1;
                    end
                    else begin
                        o_switch_ack = 1;
                        activate = 0;
                    end
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
