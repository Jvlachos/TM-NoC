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
    logic transmit    [ROWS][COLUMNS][NUM_OF_PORTS];
    logic send        [ROWS][COLUMNS][NUM_OF_PORTS];
    logic downstream_ack [ROWS][COLUMNS][NUM_OF_PORTS];
    logic downstream_req [ROWS][COLUMNS][NUM_OF_PORTS];
    router_pipeline_bus_t s2d [ROWS][COLUMNS][NUM_OF_PORTS];
    FLIT_t to_router [ROWS][COLUMNS][NUM_OF_PORTS];
    
    always #(`CLK_PERIOD) clk = ~clk;
    
    
    genvar i,j;
    generate
        for (i = 0; i < ROWS; i++) begin
            for (j = 0; j < COLUMNS; j++) begin
                TrafficGenerator #(
                .router_conf('{xaddr: j, yaddr: i})
                )trafficGen(
                    .clk(clk),
                    .reset_n(reset),
                    .i_start(start),
                    .i_send(send[i][j][LOCAL_PORT]),
                    .o_flit(data_out[i][j][LOCAL_PORT]),
                    .o_transmit(transmit[i][j][LOCAL_PORT]),
                    .i_flit(s2d[i][j][LOCAL_PORT].flit),
                    .i_rec_req(downstream_req[i][j][LOCAL_PORT]),
                    .o_rec_ack(downstream_ack[i][j][LOCAL_PORT])
                );
    
                 
                 Router #(
                .router_conf('{xaddr: j, yaddr: i})
                )router(
                    .clk(clk),
                    .reset_n(reset),
                    .i_flit(to_router[i][j]),
                    .i_upstream_req(transmit[i][j]),
                    .i_downstream_ack(downstream_ack[i][j]),
                    .o_on_off(send[i][j]),
                    .o_downstream_req(downstream_req[i][j]),
                    .o_s2d(s2d[i][j])
                );
                
                // Connect LOCAL
                assign to_router[i][j][LOCAL_PORT] = data_out[i][j][LOCAL_PORT];
                
                // North port connection
                if (i > 0) begin: north_connect
                    assign to_router[i][j][NORTH_PORT] = s2d[i-1][j][SOUTH_PORT].flit;
                    assign transmit[i][j][NORTH_PORT] = downstream_req[i-1][j][SOUTH_PORT];
                    assign downstream_ack[i-1][j][SOUTH_PORT] = send[i][j][NORTH_PORT];
                end else begin: north_boundary
                    assign to_router[i][j][NORTH_PORT] = '0;
                    assign transmit[i][j][NORTH_PORT] = '0;
                end
                
                // South port connection
                if (i < ROWS-1) begin: south_connect
                    assign to_router[i][j][SOUTH_PORT] = s2d[i+1][j][NORTH_PORT].flit;
                    assign transmit[i][j][SOUTH_PORT] = downstream_req[i+1][j][NORTH_PORT];
                    assign downstream_ack[i+1][j][NORTH_PORT] = send[i][j][SOUTH_PORT];
                end else begin: south_boundary
                    assign to_router[i][j][SOUTH_PORT] = '0;
                    assign transmit[i][j][SOUTH_PORT] = '0;
                end
                
                // West port connection
                if (j > 0) begin: west_connect
                    assign to_router[i][j][WEST_PORT] = s2d[i][j-1][EAST_PORT].flit;
                    assign transmit[i][j][WEST_PORT] = downstream_req[i][j-1][EAST_PORT];
                    assign downstream_ack[i][j-1][EAST_PORT] = send[i][j][WEST_PORT];
                end else begin: west_boundary
                    assign to_router[i][j][WEST_PORT] = '0;
                    assign transmit[i][j][WEST_PORT] = '0;
                end
                
                // East port connection
                if (j < COLUMNS-1) begin: east_connect
                    assign to_router[i][j][EAST_PORT] = s2d[i][j+1][WEST_PORT].flit;
                    assign transmit[i][j][EAST_PORT] = downstream_req[i][j+1][WEST_PORT];
                    assign downstream_ack[i][j+1][WEST_PORT] = send[i][j][EAST_PORT];
                end else begin: east_boundary
                    assign to_router[i][j][EAST_PORT] = '0;
                    assign transmit[i][j][EAST_PORT] = '0;
                end
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
        
        repeat (1000000) begin 
            @(posedge clk);
        end
        
        $finish;
    end
endmodule