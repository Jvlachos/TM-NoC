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
    logic start = 0;
    
    FLIT_t data_out   [NUM_OF_PORTS];
    logic transmit    [NUM_OF_PORTS];
    logic send        [NUM_OF_PORTS];
    logic downstream_ack [NUM_OF_PORTS];
    logic downstream_req [NUM_OF_PORTS];
    router_pipeline_bus_t s2d [NUM_OF_PORTS];
    
    always# (`CLK_PERIOD) clk = ~clk;
    
     TrafficGenerator  trafficGen (
        .clk(clk),
        .reset_n(reset),
        .i_start(start),
        .i_send(send[LOCAL]),
        .o_flit(data_out[LOCAL]),
        .o_transmit(transmit[LOCAL])
    );
    
    Router #(
    .router_conf('{xaddr: 0, yaddr: 0})
    )router1(
        .clk(clk),
        .reset_n(reset),
        .i_flit(data_out),
        .i_upstream_req(transmit),
        .i_downstream_ack(downstream_ack),
        .o_on_off(send),
        .o_downstream_req(downstream_req),
        .o_s2d(s2d)
    );
    
     Router #(
    .router_conf('{xaddr: 1, yaddr: 0})
    )router2(
        .clk(clk),
        .reset_n(reset),
        .i_flit(s2d),
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
         repeat (50) begin 
            @(posedge clk);
         end
        // start= 0;
         //send = 0;
        $finish;
    end
endmodule
