



class driver;
    virtual TbBusInt  tbBusVif;
    mailbox gen2driv;
    int no_transactions;
    `define DRIV_IF tbBusVif.DRIVER.driver_cb
    int unsigned x,y;
    transaction trans;
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
    
    task drive;
        `DRIV_IF.start <= 1;  
        
         forever begin
         gen2driv.get(trans);
         x = unsigned'(trans.out_addr.xaddr);
         y = unsigned'(trans.out_addr.yaddr);
         `DRIV_IF.tb_flit_request[unsigned'(trans.out_addr.xaddr)][unsigned'(trans.out_addr.yaddr)] <= 0;
         $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
         @(posedge tbBusVif.DRIVER.clk);
         if(trans.flit_request) begin
            `DRIV_IF.tb_flit_request[x][y] <= trans.flit_request;
             @(posedge tbBusVif.DRIVER.clk);
             `DRIV_IF.out_addrs[x][y] <= trans.out_addr;
         end
             
         if(`DRIV_IF.tb_flit_ack[x][y]) begin
             trans.flit_ack <= 1;
             @(posedge tbBusVif.DRIVER.clk);
             `DRIV_IF.flits[x][y] <= trans.flit;
          end
             
          no_transactions ++;
         end
    endtask
    

endclass