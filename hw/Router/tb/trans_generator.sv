virtual class trans_generator;
    int repeat_count;
    mailbox gen2driv;
    event ended;
    pure virtual task main();
endclass

class rand_trans_generator extends trans_generator;
    rand transaction trans;
    
    function new(mailbox gen2driv, event ended);
        this.gen2driv = gen2driv;
        this.ended    = ended;
    endfunction
    
    virtual task main();
        repeat(repeat_count) begin 
            trans = new();       
            assert(trans.randomize()) else $fatal(0, "Randomization failed");
            gen2driv.put(trans);           
        end
        -> ended;
    endtask
endclass

class defined_trans_generator extends trans_generator;
    transaction transaction_list[$];
    
    function new(mailbox gen2driv, event ended);
        this.gen2driv = gen2driv;
        this.ended    = ended;
    endfunction
    
    function void register_transaction(transaction trans);
        transaction_list.push_back(trans);
    endfunction
    
    function void lock_repeat_count();
        assert(transaction_list.size() > 0)
            else $fatal(0, "[defined_trans_generator] No transactions registered before lock_repeat_count()");
        repeat_count = transaction_list.size();
    endfunction
    
    virtual task main();
        assert(repeat_count == transaction_list.size())
            else $fatal(0, "[defined_trans_generator] repeat_count (%0d) != transaction_list.size() (%0d). Call lock_repeat_count() first.",
                        repeat_count, transaction_list.size());
        $display("[defined_trans_generator] Sending %0d transactions", repeat_count);
        foreach(transaction_list[i]) begin
            gen2driv.put(transaction_list[i]);
            $display("[defined_trans_generator] Sent transaction %0d / %0d", i+1, repeat_count);
        end
        -> ended;
    endtask
endclass