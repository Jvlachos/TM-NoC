`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2025 03:20:02 PM
// Design Name: 
// Module Name: ni_pkg
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


package ni_pkg;

    localparam NI_MEM_DEPTH = 4096;
    localparam NI_MEM_BASE  = 32'h00080000;
    localparam NI_MEM_END   = NI_MEM_BASE + NI_MEM_DEPTH;
    localparam NI_MEM_WIDTH = 32;
    localparam NI_MEM_ADDR_WIDTH = NI_MEM_WIDTH;
    localparam NI_MEM_DATA_BYTES = NI_MEM_WIDTH/8;
    localparam REG1_ADDR = NI_MEM_BASE;
    localparam MEM_MAPPED_REGS = 1;
    typedef enum logic {
        READ =0,
        WRITE=1
    } REQ_TYPE_t;
    
    typedef logic [7:0] TAG_t;
    
    typedef struct packed {
        REQ_TYPE_t req_type;
        TAG_t      req_tag;
        logic [31:0] req_addr;
        logic [31:0] req_data;
    } REQ_REG_t;
    
    typedef struct packed {
        REQ_TYPE_t rep_type;
        TAG_t      rep_tag;
        logic [31:0] rep_data;
    } REP_REG_t;
    
    
    typedef struct packed{
        logic [NI_MEM_DATA_BYTES-1:0] write_en;
        logic [31:0] addr;
        logic [31:0] r_data;
        logic [31:0] w_data;
    } ni_memory_bus_t;
endpackage
