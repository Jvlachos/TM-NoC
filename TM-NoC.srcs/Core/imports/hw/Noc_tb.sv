`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 04:07:43 PM
// Design Name: 
// Module Name: Noc_tb
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

`define CLK_PERIOD 20
module Noc_tb(

    );
    logic clk =0;
    logic rst =1;
    always# (`CLK_PERIOD) clk = ~clk;
    
//    mem_bus_if mem_bus();
//    core_top core(.clk(clk), .rst(rst),.ext_mem_bus(mem_bus));
//    ni_top ni (.clk(clk), .rst_n(rst), .mem_bus(mem_bus));
     NoC_top noc(.clk(clk), .reset_n(rst));
     initial begin       
        rst= 0;   
        @(posedge clk);
        rst = 1;
        while(1) begin
            @(posedge clk);
        end
        $finish;
    end
endmodule
