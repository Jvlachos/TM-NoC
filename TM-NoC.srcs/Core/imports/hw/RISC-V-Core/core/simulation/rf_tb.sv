
module rf_tb;
localparam CLK_PERIOD = 10;
localparam DEPTH = 32;
localparam ADDR_WIDTH = $clog2(DEPTH);
localparam DATA_WIDTH = 32;
localparam DH = 1;

bit clk;
bit [ADDR_WIDTH-1:0] addrA;
bit [DATA_WIDTH-1:0] rdataA;
bit [ADDR_WIDTH-1:0] addrB;
bit [DATA_WIDTH-1:0] rdataB;

bit [ADDR_WIDTH-1:0] waddr;
bit [DATA_WIDTH-1:0] wdata;
bit wen;

always clk = #CLK_PERIOD ~clk;

regfile_2r1w #(
  .ALEN        (ADDR_WIDTH),
  .DLEN        (DATA_WIDTH)
) rf0 (
  .clk          (clk),

  .i_raddr_a    (addrA),
  .i_raddr_b    (addrB),

  .i_wen        (wen),
  .i_waddr      (waddr),
  .i_wdata      (wdata),

  .o_rdata_a    (rdataA),
  .o_rdata_b    (rdataB)
);

integer i;
bit [7:0] value;
task rf_write_seq;
  for (i=0 ; i<DEPTH ; i++) begin
    value = DEPTH - i;
    @(posedge clk);
    #DH;
    waddr = i;
    wdata = {24'hffffff,value};
    wen = 1;
  end
  @(posedge clk);
  #DH;
  waddr = 0;
  wdata = 0;
  wen = 0;
endtask

task rf_readA_seq;
  for (i=0 ; i<DEPTH ; i++) begin
    addrA = i;
    @(posedge clk);
    $display("ADDR_A[%d] = 0x%x",i,rdataA);
  end
  @(posedge clk);
  addrA = 0;
endtask

task rf_readB_seq;
  for (i=0 ; i<DEPTH ; i++) begin
    addrB = i;
    @(posedge clk);
    $display("ADDR_B[%d] = 0x%x",i,rdataB);
  end
  addrB = 0;
  @(posedge clk);
endtask



initial begin
  $dumpfile("tb.vcd");
  $dumpvars;

  repeat (100) @(posedge clk);
  $display("\nRead Initial A");
  rf_readA_seq();
  $display("\nRead Initial B");
  rf_readB_seq();

  repeat (100) @(posedge clk);
  $display("\nWrite Values \n");
  rf_write_seq();

  repeat (100) @(posedge clk);
  $display("\nRead Final A");
  rf_readA_seq();
  $display("\nRead Final B");
  rf_readB_seq();

  repeat (100) @(posedge clk);
  $finish;
end

endmodule
