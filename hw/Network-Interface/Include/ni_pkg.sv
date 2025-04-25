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


module ni_pkg();

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
endmodule
