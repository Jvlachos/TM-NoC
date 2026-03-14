import router_pkg::*;
class scoreboard;
    mailbox         mon2scb;
    reference_model refmod;
    int             no_transactions;
    int             received_count[ROWS][COLUMNS];

    function new(mailbox mon2scb, reference_model refmod);
        this.mon2scb = mon2scb;
        this.refmod  = refmod;
        foreach (received_count[i,j])
            received_count[i][j] = 0;
    endfunction

    task main;
        transaction trans;
        forever begin
            mon2scb.get(trans);
            begin
                int dst_row = int'(trans.tg_xaddr);
                int dst_col = int'(trans.tg_yaddr);
                received_count[dst_row][dst_col]++;
                no_transactions++;
                //$display("[Scoreboard] Got packet at (%0d,%0d) | head: %0h | total: %0d",
                    //dst_row, dst_col, trans.out_packet.head, no_transactions);
            end
        end
    endtask

    function void check();
        int errors = 0;
        $display("[Scoreboard] ---- Final Check ----");
        for (int dst_r = 0; dst_r < ROWS; dst_r++) begin
            for (int dst_c = 0; dst_c < COLUMNS; dst_c++) begin
                int exp_total = refmod.get_total_expected_at(dst_r, dst_c);
                int got       = received_count[dst_r][dst_c];
                if (exp_total == 0 && got == 0) continue;
                if (exp_total == got) begin
                    $display("[Scoreboard] PASS Router (%0d,%0d) expected %0d got %0d",
                        dst_r, dst_c, exp_total, got);
                end else begin
                    $display("[Scoreboard] FAIL Router (%0d,%0d) expected %0d got %0d",
                        dst_r, dst_c, exp_total, got);
                    errors++;
                end
                // per-source breakdown
                for (int src_r = 0; src_r < ROWS; src_r++)
                    for (int src_c = 0; src_c < COLUMNS; src_c++)
                        if (refmod.expected_count[dst_r][dst_c][src_r][src_c] > 0)
                            $display("[Scoreboard]   from (%0d,%0d): expected %0d",
                                src_r, src_c,
                                refmod.expected_count[dst_r][dst_c][src_r][src_c]);
            end
        end
        if (errors == 0)
            $display("[Scoreboard] ALL PASS - %0d/%0d packets correct",
                no_transactions, refmod.total_expected);
        else
            $display("[Scoreboard] FAILED - %0d router(s) had wrong packet count", errors);
    endfunction
endclass