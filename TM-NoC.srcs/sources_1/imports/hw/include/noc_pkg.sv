`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2026 05:46:16 PM
// Design Name: 
// Module Name: noc_pkg
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


package noc_pkg;
    localparam NOC_ROWS = 4;
    localparam NOC_COLS = 4;
    localparam NOC_MEM_DEPTH = 4096;
    localparam NOC_MEM_BASE  = 32'h00080000;
    localparam NOC_MEM_WIDTH = 32;
    localparam NOC_DATA_SIZE = 32;
    localparam NOC_MEM_ADDR_WIDTH = NOC_MEM_WIDTH;
    localparam NOC_MEM_DATA_BYTES = NOC_MEM_WIDTH/8; 

endpackage
