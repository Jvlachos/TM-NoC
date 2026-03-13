import router_pkg::*;
class hello_world;
    environment             env;
    virtual TbBusInt        intf;
    defined_trans_generator hw_gen;
    localparam int NUM_ROUTERS = ROWS * COLUMNS;
    localparam int NUM_HOPS    = NUM_ROUTERS - 1;

    function new(virtual TbBusInt tbVif);
        mailbox dummy_mb;
        event   dummy_ev;
        this.intf = tbVif;
        dummy_mb  = new();
        hw_gen    = new(dummy_mb, dummy_ev);
        build_hello_world_transactions();
        hw_gen.lock_repeat_count();
        env = new(intf, hw_gen);
    endfunction

    function void build_hello_world_transactions();
        for (int row = 0; row < ROWS; row++) begin
            for (int col = 0; col < COLUMNS-1; col++) begin
                transaction t;
                t = make_hop_transaction(.src_row(row), .src_col(col),
                                         .dst_row(row), .dst_col(col+1));
                hw_gen.register_transaction(t);
            end
            if (row < ROWS-1) begin
                transaction t;
                t = make_hop_transaction(.src_row(row),   .src_col(COLUMNS-1),
                                         .dst_row(row+1), .dst_col(0));
                hw_gen.register_transaction(t);
            end
        end
        $display("[hello_world] Built %0d transactions across %0dx%0d NoC", NUM_HOPS, ROWS, COLUMNS);
    endfunction

    function transaction make_hop_transaction(
        input int src_row, src_col,
        input int dst_row, dst_col
    );
        // xaddr = row (< ROWS), yaddr = col (< COLUMNS)
        // payload encodes hop as: body1="<src_row><src_col>" body2="><dst_row>" tail="<dst_col> "
        // e.g. (row=0,col=0)->(row=0,col=1): body1="00" body2=">0" tail="1 "
        byte unsigned c_src_row, c_src_col, c_dst_row, c_dst_col;
        transaction t = new();

        c_src_row = 8'h30 + src_row;
        c_src_col = 8'h30 + src_col;
        c_dst_row = 8'h30 + dst_row;
        c_dst_col = 8'h30 + dst_col;

        foreach (t.flits[i])
            t.flits[i] = '0;

        t.flits[0].head.valid     = 1'b1;
        t.flits[0].head.flit_type = HEAD_FLIT;
        t.flits[0].head.xaddr     = dst_row;
        t.flits[0].head.yaddr     = dst_col;

        t.flits[1].body.valid     = 1'b1;
        t.flits[1].body.flit_type = BODY_FLIT;
        t.flits[1].body.data      = {c_src_row, c_src_col};

        t.flits[2].body.valid     = 1'b1;
        t.flits[2].body.flit_type = BODY_FLIT;
        t.flits[2].body.data      = {8'h3E, c_dst_row};

        t.flits[3].tail.valid     = 1'b1;
        t.flits[3].tail.flit_type = TAIL_FLIT;
        t.flits[3].tail.reserved  = {c_dst_col, 8'h20};

        t.xaddr    = dst_row;
        t.yaddr    = dst_col;
        t.tg_xaddr = src_row;
        t.tg_yaddr = src_col;

        $display("[hello_world] (%0d,%0d)->(%0d,%0d) | body1:\"%c%c\" body2:\">%c\" tail:\"%c \"",
            src_row, src_col, dst_row, dst_col,
            c_src_row, c_src_col, c_dst_row, c_dst_col);
        return t;
    endfunction

    task run();
        env.run();
    endtask
endclass