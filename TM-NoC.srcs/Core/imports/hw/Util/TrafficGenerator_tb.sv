`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 16:22:33
// Design Name: 
// Module Name: TrafficGenerator_tb
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
module TrafficGenerator_tb
    import router_pkg::*;
(

    );
    
    logic clk = 1;
    logic reset = 0;
    logic [FLIT_SIZE-1:0] data_out;
    logic start = 0;
    logic send  = 0;
    logic done;
    always# (`CLK_PERIOD) clk = ~clk;
    
   TrafficGenerator  trafficGen (
        .clk(clk),
        .reset_n(reset),
        .i_start(start),
        .i_send(send),
        .o_flit(data_out),
        .o_done(done));
    
    initial begin
      
        @(posedge clk);

        reset = 1;
        start = 1;
        
        repeat (5) begin 
            @(posedge clk);
         end
       // start = 0;
        send = 1;
         repeat (5) begin 
            @(posedge clk);
         end
         start= 0;
         send = 0;
        $finish;
    end
endmodule
