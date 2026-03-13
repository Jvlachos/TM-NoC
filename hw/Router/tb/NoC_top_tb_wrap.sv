`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 08:24:45 PM
// Design Name: 
// Module Name: NoC_top_tb_wrap
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


module NoC_top_tb_wrap
import router_pkg::*;
(
    TbBusInt tbBus
);
    NoC_top dut (
        .clk             (tbBus.clk),
        .reset_n         (tbBus.reset_n),
        .start           (tbBus.start),
        .flits           (tbBus.flits),
        .tb_flit_request (tbBus.tb_flit_request),
        .tb_flit_ack     (tbBus.tb_flit_ack),
        .out_packets     (tbBus.out_packets),
        .out_packet_done (tbBus.out_packet_done)
    );
endmodule
