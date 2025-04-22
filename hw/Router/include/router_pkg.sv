`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2025 19:30:31
// Design Name: 
// Module Name: router_pkg
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


package router_pkg;
    localparam ROWS = 1;
    localparam COLUMNS = 4;
    localparam NUMBER_OF_ROUTERS = ROWS * COLUMNS;
    
    localparam NUM_OF_PORTS = 5;
    localparam FLIT_SIZE    = 19;
    localparam NUM_OF_FLITS = 4;
    localparam NUM_OF_FLITS_BITS = 2;
    localparam PACKET_SIZE  = NUM_OF_FLITS * FLIT_SIZE;
    localparam NUM_OF_PORTS_BITS = $clog2(NUM_OF_PORTS);
    
    typedef enum logic [1:0] {
        HEAD_FLIT=0,
        TAIL_FLIT=1,
        BODY_FLIT=2,
        NONE_FLIT=3
    }FLIT_TYPE_t;
    
    localparam FLIT_TYPE_BITS = $bits(FLIT_TYPE_t);
    localparam FLIT_CNTRL_BITS = FLIT_TYPE_BITS+1;
    localparam FLIT_DATA_BITS  = FLIT_SIZE-FLIT_CNTRL_BITS;
    
    typedef struct packed {
        logic [(FLIT_DATA_BITS/2)-1:0]        xaddr;
        logic [(FLIT_DATA_BITS/2)-1:0]        yaddr;
    } ROUTER_CONFIG;
    
    typedef enum logic [2:0] {
        LOCAL_PORT  = 3'd0,
        NORTH_PORT  = 3'd1,
        SOUTH_PORT  = 3'd2,
        EAST_PORT   = 3'd3,
        WEST_PORT   = 3'd4,
        NONE_PORT   = 3'd5
    } PORT_t;
    
    typedef enum logic {
        P_IDLE=0,
        P_ACTIVE=1
    } P_STATUS;
    
    typedef struct packed{
        P_STATUS source_port;
        P_STATUS target_port;
    } SW_PORT_STATUS;
    typedef struct packed {
        logic  valid;
        FLIT_TYPE_t   flit_type;
        logic [(FLIT_DATA_BITS/2)-1:0]        xaddr;
        logic [(FLIT_DATA_BITS/2)-1:0]        yaddr;
    } FLIT_HEAD_t;
    
    typedef struct packed {
        logic  valid;
        FLIT_TYPE_t   flit_type;
        logic [FLIT_DATA_BITS-1:0]         data;
    } FLIT_BODY_t;
    
    typedef struct packed {
        logic        valid;
        FLIT_TYPE_t   flit_type;
        logic [FLIT_DATA_BITS-1:0]         reserved;
    } FLIT_TAIL_t;
    
    typedef union packed {
        logic [FLIT_SIZE-1:0] flit;
        FLIT_HEAD_t head;
        FLIT_BODY_t body;
        FLIT_TAIL_t tail;
    } FLIT_t;
    
    typedef struct packed {
        FLIT_t head;
        FLIT_t body1;
        FLIT_t body2;
        FLIT_t tail;
    } PACKET_t;
    
    typedef enum logic [1:0] {
        IDLE = 0,
        ROUTING,
        ACTIVE,
        WAITING
    } GLOBAL_STATE_t;
    
    typedef  logic [NUM_OF_PORTS_BITS:0] ROUTE_t;
    typedef logic [NUM_OF_PORTS_BITS-1:0] PORT_ADDR_t;
    typedef enum logic [1:0] {
        PACKET_SENT = 0,
        PACKET_RECEIVED  = 1,
        PACKET_FILLING =2,
        PACKET_EMPTY    =3
    } BUFFER_STATUS_t;
    
    typedef struct packed {
        GLOBAL_STATE_t gstate;
        ROUTE_t route;
        BUFFER_STATUS_t buffer_status;
        logic [3:0] flit_ptr;
    } GRP_VEC_t;
    
     typedef struct packed {
        GLOBAL_STATE_t gstate;
        PORT_ADDR_t iport;
    } GI_VEC_t;
    
    typedef struct packed {
        FLIT_t flit;
        PORT_t target_port;
    } router_pipeline_bus_t;
//    typedef logic [PACKET_SIZE-1:0] INPUT_BUFFER_t;
    
    typedef enum logic {
        PORT_FREE = 0,
        PORT_OCCUPIED
    } PORT_STATUS_t;
    
    typedef struct packed {
        PORT_STATUS_t port_status;
        PORT_ADDR_t   port_addr;
        GRP_VEC_t     port_vec;
    } IN_PORT_t;
    
     typedef struct packed {
        PORT_STATUS_t port_status;
        PORT_ADDR_t   port_addr;
        GI_VEC_t     port_vec;
    } OUT_PORT_t;
     
    typedef struct packed {
        logic switch_req;
        logic switch_ack;
        logic downstream_req;
        logic downstream_ack;
    } traffic_cntrl_bus_t;
endpackage
