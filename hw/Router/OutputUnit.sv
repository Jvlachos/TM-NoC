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
    input   router_pipeline_bus_t i_r2s,
    input   logic  i_switch_request,
    input   logic  i_downstream_ack,
    output  logic  o_switch_ack,
    output  logic  o_downstream_req,
    output  GI_VEC_t o_vec,
    output  PORT_STATUS_t o_port_status,
    output  router_pipeline_bus_t o_s2d
    );
    
    GI_VEC_t oport_status_vec;
    PORT_STATUS_t oport_status;
     router_pipeline_bus_t s2d;
    logic switch_ack_ff;
    OutputUnitFSM ofsm (
        .clk(clk),
        .reset_n(reset_n),
        .i_flit(i_r2s.flit),
        .i_downstream_ack(i_downstream_ack),
        .i_switch_req(i_switch_request),
        .o_switch_ack(switch_ack),
        .o_downstream_req(o_downstream_req),
        .o_gstate(oport_status_vec.gstate),
        .o_port_status(o_port_status),
        .o_bus_s2d(s2d)
    );
    
    
      always_ff@(posedge clk, negedge reset_n) begin : switch_ack_reg
        if(~reset_n)
            o_switch_ack <= '0;
        else
            o_switch_ack <= switch_ack;
      
    end
    
    always_ff@(posedge clk, negedge reset_n) begin : switch_2_downstream
        if(~reset_n)
            o_s2d.flit <= '0;
        else 
            o_s2d.flit <= s2d;
       
    end
    
endmodule
