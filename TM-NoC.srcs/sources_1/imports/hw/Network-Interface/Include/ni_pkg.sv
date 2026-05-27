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

import noc_pkg::*;
    localparam NI_MEM_DEPTH = NOC_MEM_DEPTH;
    localparam NI_MEM_BASE  = NOC_MEM_BASE;
    
    localparam NI_MEM_WIDTH = NOC_MEM_WIDTH;
    localparam NI_DATA_SIZE = NOC_DATA_SIZE;
    localparam NI_MEM_ADDR_WIDTH = NOC_MEM_ADDR_WIDTH;
    localparam NI_MEM_DATA_BYTES = NOC_MEM_DATA_BYTES;
    localparam ID_REG_BASE = NI_MEM_BASE;
    localparam NI_MAPPED_REGS_BASE = ID_REG_BASE + NI_MEM_DATA_BYTES; 
    localparam MEM_MAPPED_REGS = NOC_ROWS * NOC_COLS;
    localparam MEM_MAPPED_REGS_END = NI_MAPPED_REGS_BASE + MEM_MAPPED_REGS * NI_MEM_DATA_BYTES - 1;
    localparam TX_MEM_END = MEM_MAPPED_REGS_END + 1 + NI_MEM_DEPTH * NI_MEM_DATA_BYTES - 1;
    // 16 extra registers after the existing memory
    localparam RX_REGS_BASE    = TX_MEM_END + 1;
    localparam RX_REGS_COUNT   = MEM_MAPPED_REGS;
    localparam RX_REGS_END     = RX_REGS_BASE + RX_REGS_COUNT * NI_MEM_DATA_BYTES - 1;
    
    // second memory after the extra registers
    localparam NI_RXMEM_BASE     = RX_REGS_END + 1;
    localparam NI_RXMEM_DEPTH    = NI_MEM_DEPTH;  // or whatever depth you need
    localparam NI_RXMEM_END      = NI_RXMEM_BASE + NI_RXMEM_DEPTH * NI_MEM_DATA_BYTES - 1;
    
    
    
    localparam NI_MEM_END = NI_RXMEM_END;
    localparam LOCAL_DATA_SIZE = 30;
    
    localparam NI_MEM_SECTION_SIZE  = (NI_MEM_DEPTH/MEM_MAPPED_REGS) * NI_MEM_DATA_BYTES;  
    localparam NI_MEM_SECTIONS_BASE = NI_MAPPED_REGS_BASE + MEM_MAPPED_REGS * NI_MEM_DATA_BYTES;
   
    localparam NI_RXMEM_SECTIONS_BASE = RX_REGS_BASE + RX_REGS_COUNT * NI_MEM_DATA_BYTES;
    
    typedef struct packed {
        logic [15:0] data_size;
        logic [7:0] reserved;
        logic [5:0] reserved2;
        logic bit_start;
        logic bit_sent;     
    } TX_CNTRL_t;
    
    
    typedef struct packed {
        logic [15:0] data_size;
        logic [7:0] reserved;
        logic [6:0] reserved2;
        logic valid;
    } RX_CNTRL_t;
    
    typedef struct packed {
        logic [NI_DATA_SIZE-1:0] ni_data;
        logic valid;
    } NI_DATA_BUS_t;
    
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
        NI_RECEIVING = 1,
        NI_WAITING=2,
        NI_SENDING=3,
        NI_REQUESTING =4,
        NI_DONE = 5
    } ni_tx_state_t;
    
    
    typedef enum {
        TX_BE_IDLE = 0,
        TX_BE_WAITING = 1,
        TX_BE_RECEIVING = 2,
        TX_BE_FILLING = 3,
        TX_BE_SENDING = 4
    
    } backend_tx_state_t;
    
    
endpackage
