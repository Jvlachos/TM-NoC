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
    localparam ROWS = 4;
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
     
    function automatic FLIT_t invalid_flit();
        FLIT_t inval = '0;;
        inval.head.flit_type = NONE_FLIT;
        return inval;
    endfunction
    
      function automatic FLIT_t gen_traversal_head(FLIT_t data,ROUTER_CONFIG router_conf);
        FLIT_t val;
        
        val = data;
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
        if($unsigned(router_conf.xaddr) == COLUMNS-1 ) begin
         if($unsigned(router_conf.yaddr) % 2 == 0) begin
                val.head.xaddr =$unsigned(router_conf.xaddr);
                val.head.yaddr =$unsigned(router_conf.yaddr) + 1;
            end
            else begin
                val.head.xaddr =$unsigned(router_conf.xaddr)-1;
                val.head.yaddr =$unsigned(router_conf.yaddr);
            end
            
        end
        
        else if($unsigned(router_conf.xaddr) == 0) begin
             if($unsigned(router_conf.yaddr) % 2 == 0) begin
                val.head.xaddr =$unsigned(router_conf.xaddr) +1;
                val.head.yaddr =$unsigned(router_conf.yaddr);
            end
            else begin
                val.head.xaddr =$unsigned(router_conf.xaddr);
                val.head.yaddr =$unsigned(router_conf.yaddr) +1;
            end
        end
        else begin
            if($unsigned(router_conf.yaddr) % 2 == 0) begin
                 val.head.xaddr =$unsigned(router_conf.xaddr) +1;
                 val.head.yaddr =$unsigned(router_conf.yaddr);
            end
            else begin
                val.head.xaddr =$unsigned(router_conf.xaddr) -1;
                 val.head.yaddr =$unsigned(router_conf.yaddr);
            end
//            val.head.xaddr =$unsigned(val.head.xaddr) + 1;
//            val.head.yaddr = 8'b0;
        end
        if($unsigned(router_conf.xaddr) == 0 && $unsigned(router_conf.yaddr)  == 3) begin
            val.head.xaddr = 8'b0;
            val.head.yaddr = $unsigned(3);
        end
        return val;
    endfunction
    
        
      function automatic FLIT_t gen_head();
        FLIT_t val;
        
        val.head.valid =1;
        val.head.flit_type = FLIT_TYPE_t'(HEAD_FLIT);
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
     
         val.head.xaddr     = 8'd1;   // x = 0
         val.head.yaddr     = 8'd0;   // y = 0
       
        return val;
    endfunction
    
     function automatic FLIT_t gen_pass_body(FLIT_t data,ROUTER_CONFIG router_conf);
        FLIT_t val;
        val = data;
        val.body.data[15:8] = $unsigned(router_conf.xaddr) + $unsigned(data[15:8]);
        val.body.data[7:0] = $unsigned(router_conf.yaddr) + $unsigned(data[7:0]);
        return val;
    endfunction
    
   function automatic FLIT_t gen_body(ROUTER_CONFIG router_conf);
        FLIT_t val;
        val.body.valid =1;
        val.body.flit_type = FLIT_TYPE_t'(BODY_FLIT);
        val.body.data[15:8] = $unsigned(router_conf.xaddr) ;
        val.body.data[7:0] = $unsigned(router_conf.yaddr) ;
        return val;
    endfunction
    
    function automatic FLIT_t gen_head2addr(integer x,integer y);
         FLIT_t val;
        
        val.head.valid =1;
        val.head.flit_type = FLIT_TYPE_t'(HEAD_FLIT);
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
     
         val.head.xaddr     =  x;   // x = 0
         val.head.yaddr     =  y;   // y = 0
       
        return val;
    endfunction
     function automatic FLIT_t gen_tail(logic [15:0] packet_append);
            FLIT_t val;
         val.tail.valid =1;
         val.tail.flit_type = FLIT_TYPE_t'(TAIL_FLIT);
         val.tail.reserved = packet_append;
        return val;
    endfunction
    
    function print_in_info(integer in_id,integer cycle,string msg,ROUTER_CONFIG router_conf);
        //if($unsigned(router_conf.xaddr) == 3 && $unsigned(router_conf.yaddr) ==3) begin
        case (in_id)
            0: $display("%s {x:%d y:%d} %s cycle : %d",msg,$unsigned(router_conf.xaddr),$unsigned(router_conf.yaddr),"LOCAL",cycle);
            1: $display("%s {x:%d y:%d} %s cycle : %d",msg,$unsigned(router_conf.xaddr),$unsigned(router_conf.yaddr),"NORTH",cycle);
            2: $display("%s {x:%d y:%d} %s cycle : %d",msg,$unsigned(router_conf.xaddr),$unsigned(router_conf.yaddr),"SOUTH",cycle);
            3: $display("%s {x:%d y:%d} %s cycle : %d",msg,$unsigned(router_conf.xaddr),$unsigned(router_conf.yaddr),"EAST",cycle);
            4: $display("%s {x:%d y:%d} %s cycle : %d",msg,$unsigned(router_conf.xaddr),$unsigned(router_conf.yaddr),"WEST",cycle);
            
        endcase
       // end
    endfunction
    
     function automatic FLIT_t toAll(ROUTER_CONFIG router_conf,integer x,integer y);
        FLIT_t val;
      
        val.head.valid =1;
        val.head.flit_type = FLIT_TYPE_t'(HEAD_FLIT);
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
          
         val.head.xaddr     = x ;   // x = 0
         val.head.yaddr     =   y;   // y = 0
        return val;
    endfunction
    
    
    function automatic FLIT_t roundtrip(FLIT_t data);
        FLIT_t val;
        
        val.head.valid =1;
        val.head.flit_type = FLIT_TYPE_t'(HEAD_FLIT);
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
     
         val.head.xaddr     = $unsigned(data.head.xaddr) -1 ;   // x = 0
         val.head.yaddr     = 8'd0;   // y = 0
        return val;
    endfunction
endpackage
