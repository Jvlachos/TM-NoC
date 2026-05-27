
module mem_sync_sp_rvdmem #(
  parameter DEPTH       = 4096,
  parameter DATA_WIDTH  = 32,
  parameter ADDR_WIDTH  = DATA_WIDTH,   // address size equals data size
  parameter DATA_BYTES  = DATA_WIDTH/8,
  parameter INIT_ZERO   = 0,
  parameter INIT_FILE   = "codemem.hex",
  parameter INIT_START  = 0,
  parameter INIT_END    = DEPTH-1
) (
  input                           clk,

  input        [ADDR_WIDTH-1:0]   i_addr,
  input        [DATA_WIDTH-1:0]   i_wdata,
  input        [DATA_BYTES-1:0]   i_wen,
  output logic [DATA_WIDTH-1:0]   o_rdata
);

//---------------------------------------------------------------------------//
// CUSTOM CODE FOR RISCV SIMULATION
function sim_control;
input[DATA_WIDTH-1:0] data;
input[ADDR_WIDTH-1:0] addr;
  begin
    if ( addr == 'h40 ) begin
      $write("%c",data[7:0]);
      //$display("cycle : %0d\n",cycle);
      sim_control = 1;
    end
    else if ( addr == 'h50 ) begin
      sim_control = 1;
      $display("Simulation finished at time (%t) with write to halt address (0x%h = %d)!",$time,addr, data);
      $display("main() return value = %d", data);
      $display("CYCLES : %d\n",cycle);
      metric_disp();
      if(data == 0)
        $display("PASS");
      else
        $display("FAIL");

      $finish;
    end
    else begin
      sim_control = 0;
    end
  end
endfunction

logic [DATA_WIDTH-1:0] cycle = 0;
always @(posedge clk) begin
  cycle <= cycle + 1;
end

function [DATA_WIDTH-1:0] sim_cycle;
input[ADDR_WIDTH-1:0] addr;
input rd;
  begin
    sim_cycle = 0;
    if ( rd ) begin
      if ( addr == 'h60 ) begin
        $display("time %t cycle %d",$time,cycle);
        sim_cycle = 1;
      end
    end
  end
endfunction

//---------------------------------------------------------------------------//

localparam ADDR_SIZE = $clog2(DEPTH);
localparam ADDR_LOW  = $clog2(DATA_BYTES);
localparam ADDR_HIGH = ADDR_SIZE + ADDR_LOW - 1;
logic [ADDR_SIZE-1:0] addr;
assign addr = i_addr[ADDR_HIGH : ADDR_LOW];


logic [DATA_WIDTH-1:0] mem [0 : DEPTH-1];

// WRITE_FIRST MODE
always @(posedge clk) begin
  // do not perform writes on sim_control addresses
  if ( (i_wen != 0) && !sim_control(i_wdata, i_addr) ) begin
    for (int i=0 ; i<DATA_BYTES; i++) begin
      if ( i_wen[i] ) begin
        mem[addr][8*i +: 8] = i_wdata[8*i +: 8];
      end
    end
  //$display("WRITE CONFIRM - WRITTING :0x%0h at : 0x%0h ACTUAL : 0x%0h\n",i_wdata,addr,mem[addr]);
  end

  //$display("READING ADDRESS : 0x%0h IADDR : 0x%0h --- DATA: 0x%0h\n",addr,i_addr,mem[addr]);
  o_rdata = mem[addr];
  // override with cycle value when reading from the sim cycle address
  if ( sim_cycle(i_addr, (i_wen==0)) ) begin
    o_rdata = cycle;
  end
end
//assign o_rdata = mem[addr];

// initialize memory from file
initial begin
  if ( !INIT_ZERO ) begin
    $readmemh(INIT_FILE, mem, INIT_START, INIT_END);
  end
  else begin
    for (int i=0 ; i<DEPTH; i++) begin
      mem[i] = 0;
    end
  end
end

endmodule
