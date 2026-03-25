`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 01:49:25 PM
// Design Name: 
// Module Name: mem_mapped_reg
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


module mem_mapped_reg#(
    parameter REG_NAME = "MEM_MAPPED_REG",
    parameter REG_ADDR = 0,
    parameter DATA_SIZE = 32,
    parameter ADDR_SIZE = 32,
    parameter DATA_BYTES = DATA_SIZE/8
 )(
    input clk,
    input rst_n,
    input  [ADDR_SIZE-1:0] i_per_addr,
    input  [DATA_BYTES-1:0] i_per_we,
    input  [DATA_SIZE-1:0] i_per_din,
    output [DATA_SIZE-1:0] o_per_dout
 );
    
    logic [DATA_SIZE-1:0] _reg;
    logic [DATA_SIZE-1:0] _reg_next;
    
    always_comb begin 
        _reg_next = '0;
        if(i_per_we != 0) begin
           for (int i=0 ; i<DATA_BYTES; i++) begin
             if ( i_per_we[i] ) begin
               _reg_next[8*i +: 8] = i_per_din[8*i +: 8];
             end
           end
        end 
        else 
            _reg_next = _reg;      
    end
    
    assign o_per_dout = _reg;
    
    always @(posedge clk, negedge rst_n) begin
        if(~rst_n)
            _reg <= '0;
         else begin
            _reg <= _reg_next;
         end
    end
    
       
endmodule
