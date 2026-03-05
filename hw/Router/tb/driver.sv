


import router_pkg::*;

class driver;
    virtual TbBusInt.DRIVER tbBusVif;
    mailbox gen2driv;
    int no_transactions;
    `define DRIV_IF tbBusVif.driver_cb
    transaction pending_q[$];
    
    function new(virtual TbBusInt tbBusVif, mailbox gen2driv);
        this.tbBusVif = tbBusVif;
        this.gen2driv = gen2driv;
    endfunction
    
    task reset;
        wait(~tbBusVif.reset_n);
        $display("------[DRIVER]: Reset Started ------\n");
        `DRIV_IF.start <= 0;
        `DRIV_IF.flits <= '{default:'0};
        `DRIV_IF.tb_flit_request <= '{default:'0};
        `DRIV_IF.out_addrs  <= '{default:'0};
       wait(tbBusVif.reset_n);
        $display("------[DRIVER]: Reset Ended ------\n");
    endtask;
    
    task request_thread();
        FLIT_TYPE_t flit_type;
        transaction trans;
        int x,y;
        forever begin
             gen2driv.get(trans);
             x = unsigned'(trans.tg_xaddr);
             y = unsigned'(trans.tg_yaddr);
             pending_q.push_back(trans);
             //`DRIV_IF.tb_flit_request[x][y] <= 0;
//             $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
//             foreach(trans.flits[i]) begin
//                flit_type =trans.flits[i].head.flit_type;;
//                case(flit_type)
//                    HEAD_FLIT:
//                        $display("[Driver] Got HEAD to  x=%0d y=%0d\n",
//                                 x,
//                                 y);
                
//                    BODY_FLIT:
//                        $display("[Driver] Got BODY\n");
                
//                    TAIL_FLIT:
//                        $display("[Driver] Got TAIL\n");
//                endcase
//             end
              @(posedge tbBusVif.clk);
             
//             `DRIV_IF.tb_flit_request[x][y] <= 1;
//             `DRIV_IF.out_addrs[x][y].xaddr <= x;
//             `DRIV_IF.out_addrs[x][y].yaddr <= y;
             
             no_transactions ++;
         end
    
    endtask
    
    task drive_packet_thread(transaction trans);
       int x = unsigned'(trans.tg_xaddr);
       int y = unsigned'(trans.tg_yaddr);
       @(posedge tbBusVif.clk);
       foreach(trans.flits[j]) begin
         //$display("driving %h to (%d,%d)",trans.flits[j].flit,x,y);
        `DRIV_IF.flits[y][x] <= trans.flits[j];
         @(posedge tbBusVif.clk);
       end
       `DRIV_IF.flits[y][x] <= '0;
       `DRIV_IF.tb_flit_request[y][x] <= 0;
       `DRIV_IF.out_addrs[y][x].xaddr <= 0;
       `DRIV_IF.out_addrs[y][x].yaddr <= 0;
       
    endtask
    
    
    task ack_thread();
       transaction trans;
       int x,y;                                               
       logic ack_seen[ROWS][COLUMNS];
       forever begin
        @(posedge tbBusVif.clk);
        foreach(pending_q[i]) begin
            trans = pending_q[i];
            x = unsigned'(trans.tg_xaddr);
            y = unsigned'(trans.tg_yaddr);
             
            `DRIV_IF.tb_flit_request[y][x] <= 1;
            `DRIV_IF.out_addrs[y][x].xaddr <= x;
            `DRIV_IF.out_addrs[y][x].yaddr <= y;
            //$display("[Driver] :Pending  x :%d, y :%d\n", x, y);
            if (`DRIV_IF.tb_flit_ack[y][x] && !ack_seen[y][x]) begin
                trans.flit_ack <= 1;
                ack_seen[y][x] = 1;
                //$display("[Driver] :Got ack from x :%d, y :%d\n", x, y);

                pending_q.delete(i);              
                drive_packet_thread(trans);


                
            end
            for(int k= 0; k < ROWS; k++)
            for(int x = 0; x<COLUMNS; x++) begin
                if (!`DRIV_IF.tb_flit_ack[k][x]) begin
                    ack_seen[k][x] = 0;
                    //$display("ACK detected at %0d,%0d", k, x);
                end    
            end
         end
      
        
       end
    endtask
    
    task drive;
      `DRIV_IF.start <= 1;    
       fork
        request_thread();
        ack_thread();
       join_none         
    endtask
    

endclass