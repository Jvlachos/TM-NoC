import router_pkg::*;
class reference_model;
    int expected_count[ROWS][COLUMNS][ROWS][COLUMNS];
    int total_expected;

    function new();
        foreach (expected_count[i,j,k,l])
            expected_count[i][j][k][l] = 0;
        total_expected = 0;
    endfunction

    function void register_transaction(transaction t);
        int dst_row = int'(t.xaddr);
        int dst_col = int'(t.yaddr);
        int src_row = int'(t.tg_xaddr);
        int src_col = int'(t.tg_yaddr);
        expected_count[dst_row][dst_col][src_row][src_col]++;
        total_expected++;
    endfunction

    function void print_expected();
        $display("[RefModel] ---- Expected Transaction Table ----");
        for (int dst_r = 0; dst_r < ROWS; dst_r++)
            for (int dst_c = 0; dst_c < COLUMNS; dst_c++)
                for (int src_r = 0; src_r < ROWS; src_r++)
                    for (int src_c = 0; src_c < COLUMNS; src_c++)
                        if (expected_count[dst_r][dst_c][src_r][src_c] > 0)
                            $display("[RefModel]   Router (%0d,%0d) expects %0d packet(s) from (%0d,%0d)",
                                dst_r, dst_c,
                                expected_count[dst_r][dst_c][src_r][src_c],
                                src_r, src_c);
        $display("[RefModel] Total expected: %0d", total_expected);
    endfunction

    function int get_total_expected_at(int dst_row, int dst_col);
        int total = 0;
        for (int src_r = 0; src_r < ROWS; src_r++)
            for (int src_c = 0; src_c < COLUMNS; src_c++)
                total += expected_count[dst_row][dst_col][src_r][src_c];
        return total;
    endfunction
endclass