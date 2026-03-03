`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 01:01:09 AM
// Design Name: 
// Module Name: monitor
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

import router_pkg::*;

class monitor;
    virtual TbBusInt.MONITOR vif;
    mailbox mon2scb;
    `define MON_IF vif.monitor_cb
    function new(virtual TbBusInt vif,mailbox mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction
    
    
    task main;
        int i,j;
        transaction trans;
        logic ack_seen[ROWS][COLUMNS];
        forever begin
            #1;
            for(j = 0; j < ROWS; j++) begin
                for(i = 0; i < COLUMNS; i++) begin
                    if(`MON_IF.out_packet_done[j][i] && !ack_seen[j][i]) begin
                        trans = new();
                        trans.out_packet = `MON_IF.out_packets[j][i];
                        trans.tg_xaddr = i;
                        trans.tg_yaddr = j;
                       // $display("[Monitor] Got packet from (%d, %d)",i,j);
                        //@(posedge vif.clk);
                        mon2scb.put(trans);
                        ack_seen[j][i] = 1;
                    end
                end
            end
             for(int k= 0; k < ROWS; k++)
            for(int x = 0; x<COLUMNS; x++) begin
                if (!`MON_IF.out_packet_done[k][x]) begin
                    ack_seen[k][x] = 0;
                    //$display("ACK detected at %0d,%0d", k, x);
                end    
            end
        end
    endtask
endclass
