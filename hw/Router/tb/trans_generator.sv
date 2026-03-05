

//import router_pkg::*;


virtual class trans_generator;
    int repeat_count;
    mailbox gen2driv;
    event ended;
    pure virtual task main();

endclass


class rand_trans_generator extends trans_generator;
    rand transaction trans;
    
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env
    this.gen2driv = gen2driv;
    this.ended    = ended;
  endfunction
    
    
  virtual task main();
       repeat(repeat_count) begin 
           trans = new();       
           assert(trans.randomize()) else $fatal("Randomization failed");
           gen2driv.put(trans);           
        end
        -> ended;
    endtask
endclass


class defined_trans_generator extends trans_generator;
    transaction transaction_list[$];
    
    function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env
        this.gen2driv = gen2driv;
        this.ended    = ended;
    endfunction
    
    function register_transaction(transaction trans);
        transaction_list.push_back(trans);
    endfunction
    
    virtual task main();
        repeat(repeat_count) begin
            foreach(transaction_list[i]) begin
                gen2driv.put(transaction_list[i]);
            end
        end
        -> ended;
    endtask

endclass
