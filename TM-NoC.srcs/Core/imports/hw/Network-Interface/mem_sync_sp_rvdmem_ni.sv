`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 08:15:52 PM
// Design Name: 
// Module Name: mem_sync_sp_rvdmem_ni
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_sync_sp_rvdmem_ni#(
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

  input        [ADDR_WIDTH-1:0]   i_waddr,
  input        [ADDR_WIDTH-1:0]   i_raddr,
  input        [DATA_WIDTH-1:0]   i_wdata,
  input        [DATA_BYTES-1:0]   i_wen,
  output logic [DATA_WIDTH-1:0]   o_rdata
);

localparam ADDR_SIZE = $clog2(DEPTH);
localparam ADDR_LOW  = $clog2(DATA_BYTES);
localparam ADDR_HIGH = ADDR_SIZE + ADDR_LOW - 1;
logic [ADDR_SIZE-1:0] waddr;
logic [ADDR_SIZE-1:0] raddr;
assign waddr = i_waddr[ADDR_HIGH : ADDR_LOW];
assign raddr = i_raddr[ADDR_HIGH : ADDR_LOW];

logic [DATA_WIDTH-1:0] mem [0 : DEPTH-1] = '{default: '0};;

// WRITE_FIRST MODE
always @(posedge clk) begin
  // do not perform writes on sim_control addresses
  if ( (i_wen != 0) ) begin
    for (int i=0 ; i<DATA_BYTES; i++) begin
      if ( i_wen[i] ) begin
        mem[waddr][8*i +: 8] = i_wdata[8*i +: 8];
      end
    end
  //$display("WRITE CONFIRM - WRITTING :0x%0h at : 0x%0h ACTUAL : 0x%0h\n",i_wdata,addr,mem[addr]);
  end

  //$display("READING ADDRESS : 0x%0h IADDR : 0x%0h --- DATA: 0x%0h\n",addr,i_addr,mem[addr]);
  o_rdata = mem[raddr];
  // override with cycle value when reading from the sim cycle address

end
endmodule
