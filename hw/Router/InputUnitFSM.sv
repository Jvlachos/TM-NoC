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
    #(parameter ROUTER_CONFIG router_conf ='{default:9999})
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
    output logic o_packet_done,
    output PORT_t o_next_port
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
    PORT_t next_port;
    PORT_t next_port_ff;
   
    assign o_packet_done = send_done;
    integer xaddr, yaddr;
    always_comb begin
        o_route = {1'b1,{NUM_OF_PORTS_BITS-1{1'b0}}}; //invalid  1msb 0000lsbs
        send_done = 0;
        xaddr=0;
        yaddr=0;
        next_port = NONE_PORT;
       
         case(curr_state)
                IDLE : begin
                    o_switch_req = 0;
                    
                end
                ROUTING : begin
                   o_switch_req = 1;
                     xaddr = i_flit.head.xaddr;
                    yaddr = i_flit.head.yaddr;
          
                    if (xaddr == router_conf.xaddr && yaddr == router_conf.yaddr)
                        next_port = LOCAL;
                    else if (xaddr > router_conf.xaddr)
                        next_port = EAST;
                    else if (xaddr < router_conf.xaddr)
                        next_port = WEST;
                    else if (yaddr > router_conf.yaddr)
                        next_port = NORTH;
                    else if (yaddr < router_conf.yaddr)
                        next_port = SOUTH;
                    else
                        next_port = NONE_PORT;
                end
                ACTIVE : begin
                    o_switch_req = 0;
                    next_port = next_port_ff;
                    if(i_flit.tail.valid && i_flit.tail.flit_type == FLIT_TYPE_t'(TAIL_FLIT))
                        send_done = 1;
                end
                WAITING : begin 
                    o_switch_req = 0;
                end
         endcase
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
        
    end
    
      always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n)
            next_port_ff <= NONE_PORT;
        else
            next_port_ff <= next_port;
        
    end
    assign o_next_port = next_port_ff;
endmodule
