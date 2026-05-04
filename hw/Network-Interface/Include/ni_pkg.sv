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
import router_pkg::*;
    localparam NI_MEM_DEPTH = 4096;
    localparam NI_MEM_BASE  = 32'h00080000;
    
    localparam NI_MEM_WIDTH = 32;
    localparam NI_DATA_SIZE = 32;
    localparam NI_MEM_ADDR_WIDTH = NI_MEM_WIDTH;
    localparam NI_MEM_DATA_BYTES = NI_MEM_WIDTH/8;
    localparam REG1_ADDR = NI_MEM_BASE;
    localparam MEM_MAPPED_REGS = router_pkg::ROWS * router_pkg::COLUMNS;
    localparam MEM_MAPPED_REGS_END = NI_MEM_BASE + MEM_MAPPED_REGS * NI_MEM_DATA_BYTES - 1;
    localparam NI_MEM_END = MEM_MAPPED_REGS_END + NI_MEM_DEPTH * NI_MEM_DATA_BYTES - 1;
    localparam LOCAL_DATA_SIZE = 30;
    
    typedef struct packed {
        logic [LOCAL_DATA_SIZE-1:0] data_size;
        logic bit_start;
        logic bit_sent;     
    } TX_CNTRL_t;
    
    typedef struct packed{
        logic [NI_MEM_DATA_BYTES-1:0] write_en;
        logic [31:0] addr;
        logic [31:0] r_data;
        logic [31:0] w_data;
    } ni_memory_bus_t;
    
    typedef struct packed {
        logic [4:0] target;
        logic [NI_MEM_WIDTH-1:0] data;
        logic [LOCAL_DATA_SIZE-1:0] data_size;
        logic control;
       
    } ni_bus_t;
    
    typedef struct packed {
        logic request;
        logic ack;
    } ni_req_prot_t;
    
    typedef struct packed {
       ni_req_prot_t tx_prot;
       ni_req_prot_t rx_prot;
    } ni_req_bus_t;
    
    typedef enum {
        NI_IDLE=0,
        NI_WAITING=1,
        NI_SENDING=2
    } ni_tx_state_t;
    
endpackage
