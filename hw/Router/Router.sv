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


module Router
    import router_pkg::*;
    (
    input clk,
    input reset_n,
    input   FLIT_t i_flit,
    input  PORT_ADDR_t i_port_addr,
    input  logic i_transmit_req,
    input  logic i_downstream_ack, 
    output logic o_on_off,
    output logic o_downstream_req
    );
    
    IN_PORT_t iport1;
    OUT_PORT_t oport1;
    router_pipeline_bus_t r2s;
    logic switch_req;
    logic switch_ack;
    
    
    InputUnit in1 (
        .clk(clk),
        .reset_n(reset_n),
        .i_flit(i_flit),
        .i_transmit_req(i_transmit_req),
        .i_switch_ack(switch_ack),
        .o_transmit_ack(o_on_off),
        .o_switch_req(switch_req),
        .o_vec(iport1.port_vec),
        .o_port_status(iport1.port_status),
        .o_r2s(r2s)
    );
    
    OutputUnit out1 (
        .clk(clk),
        .reset_n(reset_n),
        .i_r2s(r2s),
        .i_switch_request(switch_req),
        .i_downstream_ack(i_downstream_ack),
        .o_switch_ack(switch_ack),
        .o_downstream_req(o_downstream_req),
        .o_vec(oport1.port_vec),
        .o_port_status(oport1.port_status)  
    );
   
//   assign o_on_off = write;
//    always_comb begin : on_off 
//        write = 0;
//        if(port1.port_vec.buffer_status == PACKET_EMPTY
//             || port1.port_vec.buffer_status == PACKET_FILLING
//             && port1.port_vec.gstate == IDLE)
//            write = 1;     
//    end 
    
    
    
endmodule
