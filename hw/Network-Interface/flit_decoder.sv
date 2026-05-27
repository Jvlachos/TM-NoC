`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 09:06:07 PM
// Design Name: 
// Module Name: flit_decoder
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
import ni_pkg::*;
import router_pkg::*;

module flit_decoder(
    input FLIT_t i_flit,
    output logic [31:0] o_target,
    output logic [FLIT_DATA_BITS-1:0] o_data_raw,
    output logic [10:0] o_packet_size,
    output logic o_last_flit
    );

    logic [FLIT_DATA_BITS-1:0] data;
    assign o_data_raw = data;

    always_comb begin
        data = '0;
        o_last_flit = 0;
        o_packet_size = '0;
        o_target = '0;
        case (i_flit.head.flit_type)
            HEAD_FLIT : begin
              // o_target = i_flit.head.yaddr * COLUMNS + i_flit.head.xaddr; 
            end
            BODY_FLIT : begin
                data = i_flit.body.data;
            end
            TAIL_FLIT : begin
                 if(i_flit.tail.last_packet) begin
                    o_last_flit = 1;
                    o_packet_size = i_flit.tail.data_size;
                    o_target = i_flit.tail.source_node;
                 end       
                 else o_target = i_flit.tail.source_node;
            end
        
        endcase
    
    end
endmodule