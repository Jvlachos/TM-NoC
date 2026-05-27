`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2026 05:22:45 PM
// Design Name: 
// Module Name: flit_encoder
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
module flit_encoder(
    input logic [NI_DATA_SIZE-1:0] i_data_raw,
    input FLIT_TYPE_t i_flit_type,
    input logic [31:0] i_target,
    input logic        i_done,
    output FLIT_t      o_tx_flit
    );
    
    FLIT_t flit;
    assign o_tx_flit = flit;
    always_comb begin
        flit.head.flit_type = NONE_FLIT;
        flit.head.valid = 0;
        flit.body.data = '0;
        
        case (i_flit_type)
            HEAD_FLIT  : begin
                flit.head.valid = 1;
                flit.head.flit_type = HEAD_FLIT;
                flit.head.xaddr = i_target % COLUMNS;
                flit.head.yaddr = i_target / COLUMNS;
            end
            BODY_FLIT : begin
                flit.body.valid = 1;
                flit.body.flit_type = BODY_FLIT;
                flit.body.data = i_data_raw[31:16];
            end
            TAIL_FLIT : begin
                flit.tail.valid = 1;
                flit.tail.flit_type = TAIL_FLIT;
                flit.tail.source_node = i_data_raw[31:28];
                flit.tail.data_size   = i_data_raw[27:17];
                flit.tail.last_packet = i_data_raw[16];
            end 
          
        endcase
        
    end
endmodule
