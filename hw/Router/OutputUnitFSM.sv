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
    input FLIT_t i_flit,
    input logic i_downstream_ack,
    input logic [NUM_OF_PORTS-1:0]i_switch_req,
    output logic [NUM_OF_PORTS-1:0]o_outport_ack,
    output logic o_downstream_req,
    output GLOBAL_STATE_t o_gstate,
    output PORT_STATUS_t o_port_status,
    output  router_pipeline_bus_t o_bus_s2d
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    assign o_gstate = GLOBAL_STATE_t'(curr_state);
    logic activate;
    logic send_done;
    logic [$clog2(NUM_OF_PORTS)-1:0] requesting_port;
    logic found_port;
    
    always_comb begin
        next_state = IDLE;
        found_port = 0;
        requesting_port = '0;
        for (int i = 0; i < NUM_OF_PORTS; i++) begin
            if (i_switch_req[i] && curr_state == IDLE) begin
                requesting_port = i;
                found_port = 1;
                break;
            end
        end
         unique case(curr_state)
                IDLE : next_state    = found_port ? WAITING : IDLE;
                ROUTING : ;
                ACTIVE : next_state  = send_done ? IDLE : ACTIVE;
                WAITING : next_state = activate ? ACTIVE : WAITING;
                default : ;
         endcase 
    end
    
       always_comb begin
         activate = 0;
         o_outport_ack = 0;
         o_port_status = PORT_STATUS_t'(PORT_FREE);
          o_downstream_req = 0;
         send_done = 0;
         o_bus_s2d = '0;
         case(curr_state)
                IDLE : begin
                    o_port_status = PORT_STATUS_t'(PORT_FREE);
                end
                ROUTING : begin
                  assert (0) else $error("ROUTING not allowed in output");
                    
                end
                ACTIVE : begin
                    o_port_status = PORT_STATUS_t'(PORT_OCCUPIED);
                   o_bus_s2d.flit = i_flit;
                    if(i_flit.tail.valid && i_flit.tail.flit_type == FLIT_TYPE_t'(TAIL_FLIT))
                        send_done = 1;
                end
                WAITING : begin 
                    o_port_status = PORT_STATUS_t'(PORT_OCCUPIED);
                    o_downstream_req = 1;
                    if(i_downstream_ack) begin
                        activate = 1;
                        o_outport_ack[requesting_port] = 1;
                    end
                    else begin
                        o_outport_ack[requesting_port] = 0;
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
