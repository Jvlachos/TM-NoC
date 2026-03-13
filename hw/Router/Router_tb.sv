`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2025 13:45:17
// Design Name: 
// Module Name: Router_tb
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
import router_pkg::*;

module Router_tb

();
    
    logic clk = 1;
    logic reset = 0;
    logic start = 0;

 always #(`CLK_PERIOD) clk = ~clk;
    
    TbBusInt tbBus(clk, reset);
   
    //basic_router_test t1 = new(tbBus);
    hello_world t1 = new(tbBus);
    broadcast_test t3 = new(tbBus);
    
    NoC_top_tb_wrap dut (tbBus);
    
    initial begin
    reset = 0;   
    #5 reset = 1;
    t1.run();

    reset = 0;
    #5 reset = 1;
    
    t3.run();
    $finish;
end
endmodule