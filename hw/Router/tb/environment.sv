
`include "transaction.sv"
`include "trans_generator.sv"
`include "driver.sv"
class environment;
   
    driver    driv;
    trans_generator gen;
    mailbox gen2driv;
    event gen_ended;
    
    virtual TbBusInt tbBusVif;
    
    function new(virtual TbBusInt tbBusVif);
        this.tbBusVif = tbBusVif;
        this.gen2driv = new();
        this.gen = new(gen2driv, gen_ended);
        this.driv = new(tbBusVif, gen2driv);
    endfunction
    
    task pre_test();
        driv.reset();
    endtask
    
    task test();
        fork
            gen.main();
            driv.drive();
        join_any
    endtask
    
    task post_test();
        wait(gen_ended.triggered);
        wait(gen.repeat_count == driv.no_transactions);
        wait(driv.pending_q.size()==0);
    endtask 
    
    task run();
        pre_test();
        test();
        post_test();
        $finish;
    endtask
endclass