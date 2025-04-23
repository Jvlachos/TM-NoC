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
    
    logic downstream_ack [ROWS][COLUMNS][NUM_OF_PORTS];
    logic downstream_req [ROWS][COLUMNS][NUM_OF_PORTS];
    logic down_to_upstream_req[ROWS][COLUMNS][NUM_OF_PORTS] = '{default:'0};
    logic down_to_upstream_ack[ROWS][COLUMNS][NUM_OF_PORTS] = '{default:'0};
    router_pipeline_bus_t s2d [ROWS][COLUMNS][NUM_OF_PORTS] = '{default:'0}; // switch to downstream
    FLIT_t to_router [ROWS][COLUMNS][NUM_OF_PORTS];
    
    
    always# (`CLK_PERIOD) clk = ~clk;
    
    integer i,j;
    always_comb begin
        to_router          = '{default:'0};
        downstream_req     = '{default:'0};
        downstream_ack     = '{default:'0};
        for (i = 0; i < ROWS; i++) begin
            for (j = 0; j < COLUMNS; j++) begin
                //connect LOCAL cables to traffic gen
                to_router[i][j][LOCAL_PORT] = s2d[i][j][LOCAL_PORT].flit;
                downstream_ack[i][j][LOCAL_PORT] = down_to_upstream_ack[i][j][LOCAL_PORT];
                downstream_req[i][j][LOCAL_PORT] = down_to_upstream_req[i][j][LOCAL_PORT];
                
                // NORTH neighbor
                if (i > 0) begin
                    to_router[i-1][j][SOUTH_PORT] = s2d[i][j][NORTH_PORT].flit;
                    downstream_req[i-1][j][SOUTH_PORT] = down_to_upstream_req[i][j][NORTH_PORT];
                    downstream_ack[i-1][j][SOUTH_PORT] = down_to_upstream_ack[i][j][NORTH_PORT];
                end
    
                // SOUTH neighbor
                if (i < ROWS-1) begin
                    to_router[i+1][j][NORTH_PORT] = s2d[i][j][SOUTH_PORT].flit;
                    downstream_req[i+1][j][NORTH_PORT] = down_to_upstream_req[i][j][SOUTH_PORT];
                    downstream_ack[i+1][j][NORTH_PORT] = down_to_upstream_ack[i][j][SOUTH_PORT];
                end
    
                // WEST neighbor
                if (j > 0) begin
                    to_router[i][j-1][EAST_PORT] = s2d[i][j][WEST_PORT].flit;
                    downstream_req[i][j-1][EAST_PORT] = down_to_upstream_req[i][j][WEST_PORT];
                    downstream_ack[i][j-1][EAST_PORT] = down_to_upstream_ack[i][j][WEST_PORT];
                end
    
                // EAST neighbor
                if (j < COLUMNS-1) begin
                    to_router[i][j+1][WEST_PORT] = s2d[i][j][EAST_PORT].flit;
                    downstream_req[i][j+1][WEST_PORT] = down_to_upstream_req[i][j][EAST_PORT];
                    downstream_ack[i][j+1][WEST_PORT] = down_to_upstream_ack[i][j][EAST_PORT];
                end
            end
        end
    end
    
    genvar k,l;
    generate
        for (k = 0; k < ROWS; k++) begin
            for (l = 0; l < COLUMNS; l++) begin
                 TrafficGenerator  trafficGen (
                    .clk(clk),
                    .reset_n(reset),
                    .i_start(start),
                    .i_send(downstream_ack[k][l][LOCAL_PORT]),
                    .o_flit(s2d[k][l][LOCAL_PORT]),
                    .o_transmit(down_to_upstream_req[k][l][LOCAL_PORT])
                 );
                 
                 Router #(
                .router_conf('{xaddr: k, yaddr: l})
                )router(
                    .clk(clk),
                    .reset_n(reset),
                    .i_flit(to_router[k][l]),
                    .i_upstream_req(downstream_req[k][l]),
                    .i_downstream_ack(downstream_ack[k][l]),
                    .o_on_off(down_to_upstream_ack[k][l]),
                    .o_downstream_req(down_to_upstream_req[k][l]),
                    .o_s2d(s2d[k][l])
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
