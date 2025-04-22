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
module Router_tb
import router_pkg::*;
();
    
    logic clk = 1;
    logic reset = 0;
    logic start = 0;
    
    FLIT_t data_out   [ROWS][COLUMNS][NUM_OF_PORTS];
    //logic transmit    [ROWS][COLUMNS][NUM_OF_PORTS];
    //logic send        [ROWS][COLUMNS][NUM_OF_PORTS];
    logic downstream_ack [ROWS][COLUMNS][NUM_OF_PORTS];
    logic downstream_req [ROWS][COLUMNS][NUM_OF_PORTS];
    router_pipeline_bus_t s2d [ROWS][COLUMNS][NUM_OF_PORTS]; // switch to downstream
    FLIT_t to_router [ROWS][COLUMNS][NUM_OF_PORTS];
    logic down_to_upstream_req[ROWS][COLUMNS][NUM_OF_PORTS];
    logic down_to_upstream_ack[ROWS][COLUMNS][NUM_OF_PORTS];
    
    always# (`CLK_PERIOD) clk = ~clk;
    genvar i,j;
    
generate
    for (i = 0; i < ROWS; i++) begin
        for (j = 0; j < COLUMNS; j++) begin
            // NORTH neighbor
            if (i > 0) begin
                assign to_router[i][j][NORTH_PORT] = s2d[i-1][j][SOUTH_PORT].flit;
                assign  down_to_upstream_req[i][j][NORTH_PORT] = downstream_req[i-1][j][SOUTH_PORT];
                assign  down_to_upstream_ack[i][j][NORTH_PORT] = downstream_ack[i-1][j][SOUTH_PORT];
            end

            // SOUTH neighbor
            if (i < ROWS-1) begin
                assign to_router[i][j][SOUTH_PORT] = s2d[i+1][j][NORTH_PORT].flit;
                assign down_to_upstream_req[i][j][SOUTH_PORT] = downstream_req[i+1][j][NORTH_PORT];
                assign down_to_upstream_ack[i][j][SOUTH_PORT] = downstream_ack[i+1][j][NORTH_PORT];
            end

            // WEST neighbor
            if (j > 0) begin
                assign to_router[i][j][WEST_PORT] = s2d[i][j-1][EAST_PORT].flit;
                assign  down_to_upstream_req[i][j][WEST_PORT] = downstream_req[i][j-1][EAST_PORT];
                assign  down_to_upstream_ack[i][j][WEST_PORT] = downstream_ack[i][j-1][EAST_PORT];
            end

            // EAST neighbor
            if (j < COLUMNS-1) begin
                assign to_router[i][j][EAST_PORT] = s2d[i][j+1][WEST_PORT].flit;
                assign  down_to_upstream_req[i][j][EAST_PORT] = downstream_req[i][j+1][WEST_PORT];
                assign  down_to_upstream_ack[i][j][EAST_PORT] = downstream_ack[i][j+1][WEST_PORT];
            end
        end
    end
endgenerate

generate
    for (i = 0; i < ROWS; i++) begin
        for (j = 0; j < COLUMNS; j++) begin
             TrafficGenerator  trafficGen (
                .clk(clk),
                .reset_n(reset),
                .i_start(start),
                .i_send(downstream_ack[i][j][LOCAL_PORT]),
                .o_flit(to_router[i][j][LOCAL_PORT]),
                .o_transmit(down_to_upstream_req[i][j][LOCAL_PORT])
             );
             
             Router #(
            .router_conf('{xaddr: i, yaddr: j})
            )router(
                .clk(clk),
                .reset_n(reset),
                .i_flit(to_router[i][j]),
                .i_upstream_req(down_to_upstream_req[i][j]),
                .i_downstream_ack(down_to_upstream_ack[i][j]),
                .o_on_off(downstream_ack[i][j]),
                .o_downstream_req(downstream_req[i][j]),
                .o_s2d(s2d[i][j])
            );
             
        end
    end
endgenerate 
    
    initial begin
      
        @(posedge clk);

        reset = 1;
        start = 1;
        
        repeat (5) begin 
            @(posedge clk);
         end
       // start = 0;
        //send = 1;
         repeat (50) begin 
            @(posedge clk);
         end
        // start= 0;
         //send = 0;
        $finish;
    end
endmodule
