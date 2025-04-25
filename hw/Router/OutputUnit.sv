`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2025 18:17:43
// Design Name: 
// Module Name: OutputUnit
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


module OutputUnit
     import router_pkg::*;
    (
    input   clk,
    input   reset_n,
    input   router_pipeline_bus_t i_s2o,
    input   logic  i_downstream_ack,
    input   logic  [NUM_OF_PORTS-1:0]i_switch_request,
    output  logic  [NUM_OF_PORTS-1:0]o_outport_ack,
    output  logic  o_downstream_req,
    output  GI_VEC_t o_vec,
    output  PORT_STATUS_t o_port_status,
    output  router_pipeline_bus_t o_o2d
    );
    logic  [NUM_OF_PORTS-1:0]switch_ack=0;
    GI_VEC_t oport_status_vec;
    PORT_STATUS_t oport_status;
     router_pipeline_bus_t s2d;
    logic switch_ack_ff;
    OutputUnitFSM ofsm (
        .clk(clk),
        .reset_n(reset_n),
        .i_flit(i_s2o.flit),
        .i_downstream_ack(i_downstream_ack),
        .i_switch_req(i_switch_request),
        .o_outport_ack(switch_ack),
        .o_downstream_req(o_downstream_req),
        .o_gstate(oport_status_vec.gstate),
        .o_port_status(o_port_status),
        .o_bus_s2d(s2d)
    );
    
    
      always_ff@(posedge clk, negedge reset_n) begin : switch_ack_reg
        if(~reset_n)
            o_outport_ack <= '0;
        else
            o_outport_ack <= switch_ack;
      
    end
    
    always_ff@(posedge clk, negedge reset_n) begin : switch_2_downstream
        if(~reset_n) begin
            o_o2d.flit <=  invalid_flit();
            o_o2d.target_port <= NONE_PORT;
        end
        else begin 
            o_o2d.flit <= s2d.flit;
            
        end       
    end
    
endmodule
