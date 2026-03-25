`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2025 03:23:42 PM
// Design Name: 
// Module Name: ni_frontend
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

import ni_pkg::*;
module ni_frontend#(
  parameter DEPTH       = 4096,
  parameter DATA_WIDTH  = 32,
  parameter ADDR_WIDTH  = DATA_WIDTH,   // address size equals data size
  parameter DATA_BYTES  = DATA_WIDTH/8



)(
    input clk,
    input rst_n,
    mem_bus_if mem_bus
    
);
    logic [DATA_WIDTH-1:0] regs_write_en [0:MEM_MAPPED_REGS-1];
    logic [DATA_WIDTH-1:0] mem_write_en;
    localparam ADDR_LOW = $clog2(DATA_BYTES);
    localparam ADDR_HIGH = ADDR_WIDTH-1;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] regs_odata [0:MEM_MAPPED_REGS-1];
    logic [DATA_WIDTH-1:0] mem_odata;
    assign addr = mem_bus.addr[ADDR_HIGH : ADDR_LOW];
    
    always_comb begin
        regs_write_en = '{default: '0};
        mem_bus.r_data = '0;
        mem_write_en  = '0;
        if(REG1_ADDR[ADDR_HIGH:ADDR_LOW] == addr) begin
            regs_write_en[0] = mem_bus.write_en; 
            mem_bus.r_data = regs_odata[0];
        end
        else begin
            mem_write_en = mem_bus.write_en;
            mem_bus.r_data = mem_odata;
        end
    end
    
    mem_sync_sp_rvdmem_ni #
    (.DATA_WIDTH(DATA_WIDTH))
    ni_memory (
        .clk(clk),
        .i_addr(mem_bus.addr),
        .i_wdata(mem_bus.w_data),
        .i_wen(mem_write_en),
        .o_rdata(mem_odata)
    );
    
    mem_mapped_reg #
    (
      .REG_NAME("REG1"),
      .REG_ADDR(REG1_ADDR)
    ) reg1(
        .clk(clk),
        .rst_n(rst_n),
        .i_per_addr(mem_bus.addr),
        .i_per_we(regs_write_en[0]),
        .i_per_din(mem_bus.w_data),
        .o_per_dout(regs_odata[0])
    );
endmodule
