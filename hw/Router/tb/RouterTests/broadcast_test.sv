import router_pkg::*;
class broadcast_test;
    environment             env;
    virtual TbBusInt        intf;
    defined_trans_generator hw_gen;
    localparam int SRC_ROW = 1;
    localparam int SRC_COL = 1;
    localparam int NUM_PACKETS = ROWS * COLUMNS - 1;

    function new(virtual TbBusInt tbVif);
        mailbox dummy_mb;
        event   dummy_ev;
        this.intf = tbVif;
        dummy_mb  = new();
        hw_gen    = new(dummy_mb, dummy_ev);
        build_broadcast_transactions();
        hw_gen.lock_repeat_count();
        env = new(intf, hw_gen);
    endfunction

    function void build_broadcast_transactions();
        for (int row = 0; row < ROWS; row++) begin
            for (int col = 0; col < COLUMNS; col++) begin
                transaction t;
                if (row == SRC_ROW && col == SRC_COL) continue;
                t = make_bcast_transaction(.dst_row(row), .dst_col(col));
                hw_gen.register_transaction(t);
            end
        end
        $display("[broadcast_test] Built %0d packets from (%0d,%0d) to all routers",
            NUM_PACKETS, SRC_ROW, SRC_COL);
    endfunction

    function transaction make_bcast_transaction(
        input int dst_row, dst_col
    );
        transaction t = new();
        foreach (t.flits[i])
            t.flits[i] = '0;

        t.flits[0].head.valid     = 1'b1;
        t.flits[0].head.flit_type = HEAD_FLIT;
        t.flits[0].head.xaddr     = dst_row;
        t.flits[0].head.yaddr     = dst_col;

        t.flits[1].body.valid     = 1'b1;
        t.flits[1].body.flit_type = BODY_FLIT;
        t.flits[1].body.data      = {8'h42, 8'h43};  // "BC"

        t.flits[2].body.valid     = 1'b1;
        t.flits[2].body.flit_type = BODY_FLIT;
        t.flits[2].body.data      = {8'h41, 8'h53};  // "AS"

        t.flits[3].tail.valid     = 1'b1;
        t.flits[3].tail.flit_type = TAIL_FLIT;
        t.flits[3].tail.reserved  = {8'h54, 8'h20};  // "T "

        t.xaddr    = dst_row;
        t.yaddr    = dst_col;
        t.tg_xaddr = SRC_ROW;
        t.tg_yaddr = SRC_COL;

        $display("[broadcast_test] (%0d,%0d)->(%0d,%0d) | \"BCAST \"",
            SRC_ROW, SRC_COL, dst_row, dst_col);
        return t;
    endfunction

    task run(output int result);
        env.run(result);
    endtask
endclass