`define CLK_PERIOD 20
import router_pkg::*;
module Router_tb();
    logic clk = 1;
    logic reset = 0;
    logic start = 0;
    always #(`CLK_PERIOD) clk = ~clk;

    TbBusInt tbBus(clk, reset);

    hello_world    t1 = new(tbBus);
    broadcast_test t3 = new(tbBus);

    NoC_top_tb_wrap dut(tbBus);

    int result1, result2;

    initial begin
        reset = 0;
        #5 reset = 1;
        t1.run(result1);

        reset = 0;
        reset = 1;
        #10;

        t3.run(result2);
        

        // ---- Test Summary ----
        $display("");
        $display("==========================================");
        $display("           TEST SUMMARY                   ");
        $display("==========================================");
        $display(" hello_world    : %s", result1 ? "PASS" : "FAIL");
        $display(" broadcast_test : %s", result2 ? "PASS" : "FAIL");
        $display("------------------------------------------");
        $display(" Overall        : %s",
            (result1 && result2) ? "ALL PASS" : "SOME TESTS FAILED");
        $display("==========================================");

        $finish;
    end
endmodule