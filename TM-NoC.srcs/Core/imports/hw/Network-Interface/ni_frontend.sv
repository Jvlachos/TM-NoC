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
    input logic [NI_MEM_WIDTH-1:0] i_tx_raddr [MEM_MAPPED_REGS-1:0],
    output logic [NI_DATA_SIZE-1:0] o_txdata [MEM_MAPPED_REGS-1:0],
    output logic  o_tx_last_word [MEM_MAPPED_REGS-1:0],
    output logic  o_tx_req [MEM_MAPPED_REGS-1:0],
    mem_bus_if mem_bus
    
    
);
    logic [DATA_WIDTH-1:0] regs_write_en [0:MEM_MAPPED_REGS-1];
    logic [DATA_WIDTH-1:0] mem_write_en;
    localparam REGS_ADDR_SIZE = $clog2(MEM_MAPPED_REGS);
    localparam REGS_ADDR_LOW = $clog2(DATA_BYTES);
    localparam REGS_ADDR_HIGH = REGS_ADDR_SIZE + REGS_ADDR_LOW-1;
    logic [REGS_ADDR_SIZE-1:0] addr;
    logic [DATA_WIDTH-1:0] txregs_data [0:MEM_MAPPED_REGS-1];
    TX_CNTRL_t tx_regs [0:MEM_MAPPED_REGS-1];
    logic [DATA_WIDTH-1:0] mem_odata;
    
    logic tx_request [MEM_MAPPED_REGS-1:0] =  '{default: 1'b0};
    logic [MEM_MAPPED_REGS-1:0] tx_grant;
    logic  tx_last_word [MEM_MAPPED_REGS-1:0] =  '{default: 1'b0} ;
    logic [31:0] local_addr;
    int tx_index;
    
    assign local_addr = mem_bus.addr - NI_MEM_BASE;
    assign addr = local_addr[REGS_ADDR_HIGH : REGS_ADDR_LOW];
    
    assign tx_regs = txregs_data;
    
    assign o_tx_req = tx_grant;
  
always_ff@(posedge clk, negedge rst_n) begin
    if(~rst_n)
        tx_request <= '{default : 1'b0};
    else 
        for(int i =0; i < MEM_MAPPED_REGS; i++)
         tx_request[i] <= tx_regs[i].bit_start && ~tx_regs[i].bit_sent;   
end  
 
always_comb begin
    logic [31:0] reg_base_addr;
    logic [31:0] last_addr;
    for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
        

        reg_base_addr = NI_MEM_BASE + i * NI_MEM_DATA_BYTES;

        last_addr = reg_base_addr + tx_regs[i].data_size - NI_MEM_DATA_BYTES;

        if (tx_regs[i].data_size >= NI_MEM_DATA_BYTES)
            tx_last_word[i] = (i_tx_raddr[tx_index] == last_addr);
        else
            tx_last_word[i] = 1'b0;
    end
end
always_comb begin
    tx_index = 0;
    for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
        if (tx_grant[i])
            tx_index = i;
    end
end
    
    always_comb begin
        regs_write_en = '{default: '0};
        mem_bus.r_data = '0;
        mem_write_en  = '0;
        if(mem_bus.addr <= MEM_MAPPED_REGS_END) begin
            regs_write_en[addr] = mem_bus.write_en; 
            mem_bus.r_data = tx_regs[addr];
        end
        else begin
            mem_write_en = mem_bus.write_en;
            //mem_bus.r_data = mem_odata;
        end
    end
    
    mem_sync_sp_rvdmem_ni #
    (.DATA_WIDTH(DATA_WIDTH))
    ni_memory (
        .clk(clk),
        .i_waddr(mem_bus.addr),
        .i_raddr(i_tx_raddr[tx_index]),
        .i_wdata(mem_bus.w_data),
        .i_wen(mem_write_en),
        .o_rdata(o_txdata[tx_index])
    );
    
    nbit_arbiter_rr #(.N(MEM_MAPPED_REGS))
    arb (.clk(clk), .rst_n(rst_n), .req(tx_request), .grant(tx_grant));
    
    genvar i;
    generate
    for(i=0; i < MEM_MAPPED_REGS ; i++) begin
        mem_mapped_reg #
        (
      .REG_NAME("TX_REG"),
      .REG_ADDR(REG1_ADDR)
        ) memmapped_reg(
        .clk(clk),
        .rst_n(rst_n),
        .i_per_addr(mem_bus.addr),
        .i_per_we(regs_write_en[i]),
        .i_per_din(mem_bus.w_data),
        .o_per_dout(txregs_data[i])
        );
    end
    endgenerate
    

endmodule
