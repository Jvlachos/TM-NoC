`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2025 13:45:17
// Design Name: 
// Module Name: Router_tb
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

`define CLK_PERIOD 20
module Router_tb
import router_pkg::*;
();
    
    logic clk = 1;
    logic reset = 0;
    logic [FLIT_SIZE-1:0] data_out;
    logic start = 0;
    logic send ;
    logic transmit;
    router_pipeline_bus_t s2d;
    logic downstream_req;
    logic downstream_ack;
    always# (`CLK_PERIOD) clk = ~clk;
    
     TrafficGenerator  trafficGen (
        .clk(clk),
        .reset_n(reset),
        .i_start(start),
        .i_send(send),
        .o_flit(data_out),
        .o_transmit(transmit));
    
    Router router1(
        .clk(clk),
        .reset_n(reset),
        .i_flit(data_out),
        .i_port_addr(0),
        .i_upstream_req(transmit),
        .i_downstream_ack(downstream_ack),
        .o_on_off(send),
        .o_downstream_req(downstream_req),
        .o_s2d(s2d)
    );
    
      Router router2(
        .clk(clk),
        .reset_n(reset),
        .i_flit(s2d.flit),
        .i_port_addr(0),
        .i_upstream_req(downstream_req),
        .o_on_off(downstream_ack)
    );
    
    
    initial begin
      
        @(posedge clk);

        reset = 1;
        start = 1;
        
        repeat (5) begin 
            @(posedge clk);
         end
       // start = 0;
        //send = 1;
         repeat (25) begin 
            @(posedge clk);
         end
         start= 0;
         //send = 0;
        $finish;
    end
endmodule
