`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 01:10:17 AM
// Design Name: 
// Module Name: scoreboard
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


class scoreboard;
    mailbox mon2scb;
    int no_transactions;
    function new(mailbox mon2scb);
    //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction
    
    task main;
        transaction trans;
        forever begin
            mon2scb.get(trans);
            $display("[Scoreboard] Got transaction from [%d, %d] Packet head : %0h",trans.tg_xaddr,trans.tg_yaddr,trans.out_packet.head);
//            if((trans.a+trans.b) == trans.c)
//                $display("Result is as Expected");
//            else
//                $error("Wrong Result.\n\tExpeced: %0d Actual: %0d",(trans.a+trans.b),trans.c);
            no_transactions++;
           // $display("no : %d", no_transactions);
        end
     endtask
     
     
endclass
