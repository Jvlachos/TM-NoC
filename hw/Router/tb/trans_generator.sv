

//import router_pkg::*;


class trans_generator;
    rand transaction trans;
    mailbox gen2driv;
    int repeat_count;
    event ended;
    FLIT_TYPE_t current_type = HEAD_FLIT;
    
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env
    this.gen2driv = gen2driv;
    this.ended    = ended;
  endfunction
    
    task main();

        FLIT_TYPE_t flit_sequence[NUM_OF_FLITS] = '{HEAD_FLIT, BODY_FLIT, BODY_FLIT, TAIL_FLIT};  // desired order
        int rep;  
    
        for (rep = 0; rep < repeat_count; rep++) begin
            foreach(flit_sequence[i]) begin
                transaction trans = new();
    
                trans.flit_type = flit_sequence[i];
                assert(trans.randomize()) else $fatal("Randomization failed");
    
                gen2driv.put(trans);
            end
        end
    
        -> ended;

    endtask
endclass

