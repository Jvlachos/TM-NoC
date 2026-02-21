

//import router_pkg::*;


class trans_generator;
    rand transaction trans;
    mailbox gen2driv;
    int repeat_count;
    event ended;

    
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env
    this.gen2driv = gen2driv;
    this.ended    = ended;
  endfunction
    
    task main();
       repeat(repeat_count) begin 
           trans = new();       
           assert(trans.randomize()) else $fatal("Randomization failed");
//                if(trans.flit_type == HEAD_FLIT)
//                    $display("[Transaction] : Transaction with x:%d, y:%d\n",unsigned'(trans.flit.head.xaddr),unsigned'(trans.flit.head.yaddr));
            gen2driv.put(trans);
           
        end
    
        -> ended;

    endtask
endclass

