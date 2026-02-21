


import router_pkg::*;

class driver;
    virtual TbBusInt  tbBusVif;
    mailbox gen2driv;
    int no_transactions;
    `define DRIV_IF tbBusVif.DRIVER.driver_cb
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
             @(posedge tbBusVif.DRIVER.clk);
             
             `DRIV_IF.tb_flit_request[x][y] <= 1;
             `DRIV_IF.out_addrs[x][y].xaddr <= x;
             `DRIV_IF.out_addrs[x][y].yaddr <= y;
             
             no_transactions ++;
         end
    
    endtask
    
    task drive_packet_thread(transaction trans);
       int x = unsigned'(trans.tg_xaddr);
       int y = unsigned'(trans.tg_yaddr);
       @(posedge tbBusVif.DRIVER.clk);
       foreach(trans.flits[j]) begin
        `DRIV_IF.flits[x][y] <= trans.flits[j];
         @(posedge tbBusVif.DRIVER.clk);
       end
    endtask
    
    
    task ack_thread();
       transaction trans;
       int x,y;                                               
       logic ack_seen[ROWS][COLUMNS];
       forever begin
        @(posedge tbBusVif.DRIVER.clk);
        

        
        foreach(pending_q[i]) begin
            trans = pending_q[i];
            x = unsigned'(trans.tg_xaddr);
            y = unsigned'(trans.tg_yaddr);
            //$display("[Driver] :Pending  x :%d, y :%d\n", x, y);
            if (tbBusVif.tb_flit_ack[x][y] && !ack_seen[x][y]) begin
                trans.flit_ack <= 1;
                ack_seen[x][y] = 1;
                $display("[Driver] :Got ack from x :%d, y :%d\n", x, y);
                pending_q.delete(i);

                fork  
                    drive_packet_thread(trans);
                join_none
            end
        end
           for(int k= 0; k < ROWS; k++)
            for(int x = 0; x<COLUMNS; x++) begin
                if (!tbBusVif.tb_flit_ack[k][x]) begin
                    ack_seen[k][x] = 0;
                    //$display("ACK detected at %0d,%0d", k, x);
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