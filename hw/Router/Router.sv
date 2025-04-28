`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2025 13:06:31
// Design Name: 
// Module Name: Router
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
import router_pkg::*;

module Router
   #(parameter ROUTER_CONFIG router_conf ='{default:9999}) (
        input clk,
        input reset_n,
        input FLIT_t i_flit[NUM_OF_PORTS],
        input  logic i_upstream_req[NUM_OF_PORTS],
        input  logic i_downstream_ack[NUM_OF_PORTS], 
        output logic o_on_off[NUM_OF_PORTS],
        output logic o_downstream_req[NUM_OF_PORTS],
        output router_pipeline_bus_t o_s2d[NUM_OF_PORTS]
    );
    
    router_pipeline_bus_t s2o[NUM_OF_PORTS];
    IN_PORT_t iport[NUM_OF_PORTS];
    OUT_PORT_t oport[NUM_OF_PORTS];
    router_pipeline_bus_t r2s[NUM_OF_PORTS];
    router_pipeline_bus_t s2d[NUM_OF_PORTS];
    
    logic routing_success[NUM_OF_PORTS];
    logic switch_req[NUM_OF_PORTS];
    logic switch_ack[NUM_OF_PORTS];
    logic [NUM_OF_PORTS-1:0]outport_ack[NUM_OF_PORTS];
    logic [NUM_OF_PORTS-1:0]outport_req[NUM_OF_PORTS];
    
    // instantiate in/out units
    genvar i;
    generate
        for (i = 0; i < NUM_OF_PORTS; i++) begin : gen_ports
            InputUnit  #(.router_conf(router_conf),.in_id(i)) in_inst 
            (
                .clk(clk),
                .reset_n(reset_n),
                .i_flit(i_flit[i]),
                .i_upstream_req(i_upstream_req[i]),
                .i_switch_ack(switch_ack[i]),
                .i_routing_success(routing_success[i]),
                .o_transmit_ack(o_on_off[i]), 
                .o_switch_req(switch_req[i]), 
                .o_vec(iport[i].port_vec),
                .o_port_status(iport[i].port_status),
                .o_r2s(r2s[i]) 
            );
            
            OutputUnit out_inst (
                .clk(clk),
                .reset_n(reset_n),
                .i_s2o(s2o[i]),
                .i_switch_request(outport_req[i]), //ayto
                .i_downstream_ack(i_downstream_ack[i]),
                .o_outport_ack(outport_ack[i]), //ayto
                .o_downstream_req(o_downstream_req[i]),
                .o_vec(oport[i].port_vec),
                .o_port_status(oport[i].port_status),
                .o_o2d(o_s2d[i])
            );
            
            
        end
    endgenerate
    
    // instantiate switch
    Switch #(
    .router_conf(router_conf)
    )switch (
            .clk(clk),
            .rst_n(reset_n),
            .i_r2s(r2s),
            .i_switch_req(switch_req),
            .i_outport_ack(outport_ack),
            .o_outport_req(outport_req), 
            .routing_success(routing_success),
            .o_s2o(s2o) ,
            .i_oport(oport)
        );
endmodule