

import router_pkg::*;
class transaction;
   rand FLIT_t flit;
   rand FLIT_TYPE_t flit_type;
   ROUTER_CONFIG out_addr;
   ROUTER_CONFIG in_addr;
   logic flit_request;
   logic flit_ack;
    
   constraint flit_valid { flit[0] == 1;}
    
    constraint flit_format {
        flit_type == HEAD_FLIT -> flit[2:1] == 2'b00;
        flit_type == BODY_FLIT -> flit[2:1] == 2'b10;
        flit_type == TAIL_FLIT -> flit[2:1] == 2'b01;
    }
   
   
endclass


