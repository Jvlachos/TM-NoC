
module mem_tb;
localparam CLK_PERIOD = 10;
localparam DEPTH = 16;
localparam ADDR_WIDTH = $clog2(DEPTH);
localparam DATA_WIDTH = 64;
localparam DATA_BYTES = DATA_WIDTH/8;

bit clk;
bit [ADDR_WIDTH-1:0] addr;
bit [DATA_WIDTH-1:0] wdata;
bit [DATA_BYTES-1:0] wen;
bit [DATA_WIDTH-1:0] rdata;

always clk = #CLK_PERIOD ~clk;

mem_sync_sp #(
  .DEPTH        (DEPTH),
  .DATA_WIDTH   (DATA_WIDTH),
  .INIT_ZERO    (1)
) mem0 (
  .clk          (clk),
  .i_addr       (addr),
  .i_wdata      (wdata),
  .i_wen        (wen),
  .o_rdata      (rdata)
);

integer i;
bit [7:0] value;
task mem_write_seq;
  for (i=0 ; i<DEPTH ; i++) begin
    value = DEPTH - i;
    @(posedge clk);
    addr = i;
    wdata = {24'hffffff,value};
    wen = 5;
  end
  @(posedge clk);
  addr = 0;
  wdata = 0;
  wen = 0;
endtask

task mem_read_seq;
  for (i=0 ; i<DEPTH ; i++) begin
    addr = i;
    @(posedge clk);
    $display("ADDR[%d] = 0x%x",i,rdata);
  end
  addr = 0;
  @(posedge clk);
endtask



initial begin
  $dumpfile("tb.vcd");
  $dumpvars;

  repeat (100) @(posedge clk);
  $display("\nRead Initial");
  mem_read_seq();

  repeat (100) @(posedge clk);
  $display("\nWrite Values\n");
  mem_write_seq();

  repeat (100) @(posedge clk);
  $display("\nRead Final");
  mem_read_seq();

  repeat (100) @(posedge clk);
  $finish;
end

endmodule
