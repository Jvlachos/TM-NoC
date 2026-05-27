import router_pkg::*;
class transaction;
   FLIT_t flits[NUM_OF_FLITS];
   
   PACKET_t out_packet;
   rand logic[$clog2(ROWS)-1 :0] xaddr;
   rand logic[$clog2(COLUMNS)-1 :0] yaddr;
   
   rand logic[$clog2(ROWS)-1 :0] tg_xaddr;
   rand logic[$clog2(COLUMNS)-1 :0] tg_yaddr;
   logic flit_request = 1;
   logic flit_ack;
   
   constraint addr_limits {
        xaddr < ROWS;
        yaddr < COLUMNS;
        tg_xaddr < ROWS;
        tg_yaddr < COLUMNS;
   }
   
   constraint valid_addr {
        xaddr != tg_xaddr;
        yaddr != tg_yaddr;
   }
   
   function void pre_randomize();
       foreach(flits[i])
        flits[i] = '0;
    
   endfunction
   
   function void post_randomize();
        flits[0].head.xaddr = xaddr;
        flits[0].head.yaddr  = yaddr;
        
        flits[0].head.valid =1;
        flits[0].head.flit_type = HEAD_FLIT;
        
        flits[1].body.valid = 1;
        flits[1].body.flit_type = BODY_FLIT;
        flits[2].body.valid = 1;
        flits[2].body.flit_type = BODY_FLIT;
        
        flits[3].tail.valid = 1;
        flits[3].tail.flit_type = TAIL_FLIT;
        //$display("[Transaction]: target x:%0d,y:%0d head: (%d,%d)",tg_xaddr,tg_yaddr,flits[0].head.xaddr,flits[0].head.yaddr); 
   endfunction
   
endclass


