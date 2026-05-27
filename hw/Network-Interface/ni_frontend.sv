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
    output logic   o_tx_req [MEM_MAPPED_REGS-1:0],
    output TX_CNTRL_t o_tx_regs_data [MEM_MAPPED_REGS-1:0],
    input  [NI_MEM_WIDTH-1:0] i_rx_waddr [MEM_MAPPED_REGS-1:0],
    input  logic i_rx_mem_wen [MEM_MAPPED_REGS-1:0],
    input logic [NI_DATA_SIZE-1:0] i_rx_data,
    input RX_CNTRL_t i_rx_reg_data [MEM_MAPPED_REGS-1:0],
    input logic      i_rx_reg_wen [MEM_MAPPED_REGS-1:0],
    mem_bus_if mem_bus
    
    
);
    logic [NI_MEM_DATA_BYTES-1:0] tx_regs_write_en [0:MEM_MAPPED_REGS-1];
    logic [NI_MEM_DATA_BYTES-1:0] mem_write_en [MEM_MAPPED_REGS-1:0];
    localparam REGS_ADDR_SIZE = $clog2(MEM_MAPPED_REGS);
    localparam REGS_ADDR_LOW = $clog2(DATA_BYTES);
    localparam REGS_ADDR_HIGH = REGS_ADDR_SIZE + REGS_ADDR_LOW-1;
    logic [REGS_ADDR_SIZE-1:0] addr;
    logic [DATA_WIDTH-1:0] txregs_data [MEM_MAPPED_REGS-1:0];
    TX_CNTRL_t tx_regs [MEM_MAPPED_REGS-1:0] ;
    
    
    logic [MEM_MAPPED_REGS-1:0] tx_request ;
    logic [MEM_MAPPED_REGS-1:0] tx_grant;
    logic  tx_last_word [MEM_MAPPED_REGS-1:0] =  '{default: 1'b0} ;
    assign o_tx_last_word = tx_last_word;
    logic [31:0] local_addr;
    
    logic [DATA_WIDTH-1:0] tx_regs_data_in [MEM_MAPPED_REGS-1:0];

    int tx_index;
    
    assign local_addr = mem_bus.addr - NI_MAPPED_REGS_BASE;
    assign addr = local_addr[REGS_ADDR_HIGH : REGS_ADDR_LOW];
    
    assign tx_regs = txregs_data;
    assign o_tx_regs_data = tx_regs;
    
  //-----------RX---------------------//
  logic [NI_MEM_DATA_BYTES-1:0] rx_regs_write_en [0:MEM_MAPPED_REGS-1];
  logic [DATA_WIDTH-1:0] rx_regs_data_in [0:MEM_MAPPED_REGS-1];
  logic [DATA_WIDTH-1:0] rxregs_data [MEM_MAPPED_REGS-1:0];
  logic [NI_MEM_DATA_BYTES-1:0] rxmem_write_en [MEM_MAPPED_REGS-1:0];
  logic [NI_DATA_SIZE-1:0] mem_rxdata [MEM_MAPPED_REGS-1:0];
  
  always_comb begin
    rxmem_write_en = '{default : '0};
    rx_regs_write_en = '{default : '0};
    rx_regs_data_in = '{default : '0};
    for(int i = 0; i <MEM_MAPPED_REGS; i++) begin
        rxmem_write_en[i] = i_rx_mem_wen[i] ? 4'hF : 4'h0;
         if((mem_bus.addr >= NI_RXMEM_SECTIONS_BASE + i * NI_MEM_SECTION_SIZE) &&
                   (mem_bus.addr <=  NI_RXMEM_SECTIONS_BASE + (i+1) * NI_MEM_SECTION_SIZE)) begin
            rx_regs_write_en[i] = 4'hF;
            rx_regs_data_in[i] = '0;
        end
        else begin 
            rx_regs_write_en[i] = i_rx_reg_wen[i] ? 4'hF : 4'h0;
            rx_regs_data_in[i] = i_rx_reg_data[i];
        end
    end
  end
  //----------------------------------//
  
  
  
  
    always_ff@(posedge clk, negedge rst_n) begin
        if(~rst_n)
            tx_request <= '{default : 1'b0};
        else 
            for(int i =0; i < MEM_MAPPED_REGS; i++)
             tx_request[i] <= (tx_regs[i].bit_start === 1'b1);
              //&&( tx_last_word[tx_index] === 1'b0);
    end  
   
    logic [31:0] last_addr;
    logic [31:0] base_addr;   
    
    always_comb begin
        last_addr = '0;
        base_addr = '0;
       
        
        for (int i = 0; i < MEM_MAPPED_REGS; i++) begin          
            o_tx_req[i] = tx_grant[i];
       end
       base_addr = NI_MEM_SECTIONS_BASE + tx_index * NI_MEM_SECTION_SIZE;
    
       last_addr = base_addr + tx_regs[tx_index].data_size*NI_MEM_DATA_BYTES - NI_MEM_DATA_BYTES;
    
       if (tx_regs[tx_index].data_size > 0 )
            tx_last_word[tx_index] = (i_tx_raddr[tx_index] == last_addr);
       else
            tx_last_word[tx_index] = 1'b0;
        
    end

    always_comb begin
        tx_index = 0;
        for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
            if (tx_grant[i])
                tx_index = i;
        end
    end


    integer rx_regs_addr;
    logic [31:0] dbg_addr;
    always_comb begin
        tx_regs_write_en = '{default: '0};
        mem_bus.r_data = '0;
        mem_write_en  = '{default: '0};  // now an array
        tx_regs_data_in = '{default: '0};
        rx_regs_addr = 0;
        dbg_addr = '0;
        if(tx_last_word[tx_index]) begin
            tx_regs_write_en[tx_index] = '1;
            tx_regs_data_in[tx_index] = {tx_regs[tx_index][DATA_WIDTH-1:2],2'b01}; //set sent to 1 and start to 0
        end
        if(mem_bus.addr <= MEM_MAPPED_REGS_END ) begin//&& addr != tx_index) begin
            tx_regs_write_en[addr] = mem_bus.write_en; 
            mem_bus.r_data = tx_regs[addr];
            tx_regs_data_in[addr] = mem_bus.w_data;
        end
        
        else if(mem_bus.addr <= TX_MEM_END) begin
            // calculate which section this address belongs to
            for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
                if((mem_bus.addr >= NI_MEM_SECTIONS_BASE + i * NI_MEM_SECTION_SIZE) &&
                   (mem_bus.addr <  NI_MEM_SECTIONS_BASE + (i+1) * NI_MEM_SECTION_SIZE)) begin
                    mem_write_en[i] = mem_bus.write_en;
                    //$display("base : %0h\n",NI_MEM_SECTIONS_BASE);
                    dbg_addr = mem_bus.addr - (NI_MEM_SECTIONS_BASE + i * NI_MEM_SECTION_SIZE);
                end
            end
        end
        else if(mem_bus.addr <= RX_REGS_END) begin
            //$display("RX REGS END %0h rx base : %0h\n",RX_REGS_END,NI_RXMEM_SECTIONS_BASE);
            rx_regs_addr = (mem_bus.addr - RX_REGS_BASE) / NI_MEM_DATA_BYTES;
            mem_bus.r_data = rxregs_data[rx_regs_addr];
        end
        else begin
             for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
                if((mem_bus.addr >= NI_RXMEM_SECTIONS_BASE + i * NI_MEM_SECTION_SIZE) &&
                   (mem_bus.addr <  NI_RXMEM_SECTIONS_BASE + (i+1) * NI_MEM_SECTION_SIZE)) begin
                    mem_bus.r_data = mem_rxdata[i];
                    
                end
            end
        end
    end

    genvar g;
    generate
        for (g = 0; g < MEM_MAPPED_REGS; g++) begin : gen_mem
            mem_sync_sp_rvdmem_ni #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(NI_MEM_DEPTH / MEM_MAPPED_REGS)) tx_memory (
            .clk(clk),
            .i_waddr(mem_bus.addr - (NI_MEM_SECTIONS_BASE + g * NI_MEM_SECTION_SIZE)),
            .i_raddr(i_tx_raddr[g]- (NI_MEM_SECTIONS_BASE + g * NI_MEM_SECTION_SIZE)),
            .i_wdata(mem_bus.w_data),
            .i_wen(mem_write_en[g]),
            .o_rdata(o_txdata[g])
            );
            
             mem_sync_sp_rvdmem_ni #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(NI_MEM_DEPTH / MEM_MAPPED_REGS)) rx_memory (
            .clk(clk),
            .i_waddr(i_rx_waddr[g] -  (NI_RXMEM_SECTIONS_BASE + g * NI_MEM_SECTION_SIZE)),
            .i_raddr(mem_bus.addr - (NI_RXMEM_SECTIONS_BASE + g * NI_MEM_SECTION_SIZE)),
            .i_wdata(i_rx_data),
            .i_wen(rxmem_write_en[g]),
            .o_rdata(mem_rxdata[g])
            );
            
        end
    endgenerate
    
    nbit_arbiter_rr #(.N(MEM_MAPPED_REGS))
    arb (.clk(clk), .rst_n(rst_n), .req(tx_request), .grant(tx_grant));
    
    genvar i;
    generate
    for(i=0; i < MEM_MAPPED_REGS ; i++) begin
        mem_mapped_reg #
        (
      .REG_NAME("TX_REG")
        ) memmapped_reg(
        .clk(clk),
        .rst_n(rst_n),
        .i_per_we(tx_regs_write_en[i]),
        .i_per_din(tx_regs_data_in[i]),
        .o_per_dout(txregs_data[i])
        );
        
        mem_mapped_reg #
        (
      .REG_NAME("RX_REG")
        ) rxmemmapped_reg(
        .clk(clk),
        .rst_n(rst_n),
        .i_per_we(rx_regs_write_en[i]),
        .i_per_din(rx_regs_data_in[i]),
        .o_per_dout(rxregs_data[i])
        );
    end
    endgenerate
    

endmodule
