
`include "transaction.sv"
`include "trans_generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
   
    driver    driv;
    trans_generator gen;
    monitor    mon;
    scoreboard scb;
    
    mailbox gen2driv;
    mailbox mon2scb;
   

    event gen_ended;
    
    virtual TbBusInt tbBusVif;
    

    
    function new(virtual TbBusInt tbBusVif, trans_generator gen = null);
        rand_trans_generator rand_gen;
        this.tbBusVif = tbBusVif;
        this.gen2driv = new();
        this.mon2scb  = new();
        if(gen == null) begin //default is random
            rand_gen = new(gen2driv, gen_ended);
            this.gen = rand_gen;
        end
         else 
            this.gen = gen;
        this.driv = new(tbBusVif, gen2driv);
        this.mon  = new(tbBusVif, mon2scb);
        this.scb  = new(mon2scb);
    endfunction
    
    task pre_test();
        driv.reset();
    endtask
    
    task test();
        fork
            gen.main();
            driv.drive();
            mon.main();
            scb.main();
        join_any
    endtask
    
    task post_test();
        wait(gen_ended.triggered);
        wait(gen.repeat_count == driv.no_transactions);
        wait(driv.pending_q.size()==0);
        wait(gen.repeat_count == scb.no_transactions);
    endtask 
    
    task run();
        pre_test();
        test();
        post_test();
        $finish;
    endtask
endclass