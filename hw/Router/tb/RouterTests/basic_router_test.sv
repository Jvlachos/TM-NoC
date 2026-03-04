
`include "../environment.sv"
class basic_router_test;
    environment env;
    virtual TbBusInt intf;
    function new(virtual TbBusInt tbVif);
        this.intf = tbVif;
        env = new (intf);
        env.gen.repeat_count = 1000;
    endfunction
    
    task run;
        env.run();
    endtask

endclass
