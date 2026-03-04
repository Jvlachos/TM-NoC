
import router_pkg::*;

interface TbBusInt (input clk, input reset_n);
        FLIT_t flits [0:ROWS-1][0:COLUMNS-1] ;
        PACKET_t out_packets [0:ROWS-1][0:COLUMNS-1];
        logic    out_packet_done [0:ROWS-1][0:COLUMNS-1];
        logic tb_flit_request [0:ROWS-1][0:COLUMNS-1];
        logic tb_flit_ack     [0:ROWS-1][0:COLUMNS-1];
        logic start;
        ROUTER_CONFIG out_addrs [0:ROWS-1][0:COLUMNS-1];
        ROUTER_CONFIG in_addrs [0:ROWS-1][0:COLUMNS-1];
        modport TB (input flits, input start,input clk,input  reset_n);
        
        modport DUT(input clk, reset_n, flits, start, tb_flit_request,output tb_flit_ack, out_packets, out_packet_done);
        
        
        clocking driver_cb @(posedge clk);
            default input #1 output #1;
            output flits;
            output tb_flit_request;
            output out_addrs;
            input  in_addrs;
            input  tb_flit_ack;
            output  #1step start;
        endclocking
        
        clocking monitor_cb @(posedge clk);
            default input #1 output #1;
            input flits;
            input out_packets;
            input out_packet_done;
            input tb_flit_request;
            input tb_flit_ack;
            input out_addrs;
            input in_addrs;
        endclocking
        
        modport DRIVER(clocking driver_cb, input clk, reset_n);
        
        modport MONITOR(clocking monitor_cb, input clk, reset_n);
       
endinterface
