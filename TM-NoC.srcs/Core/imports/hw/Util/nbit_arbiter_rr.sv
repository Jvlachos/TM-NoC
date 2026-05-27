`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2026 01:30:27
// Design Name: 
// Module Name: nbit_arbiter_rr
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

module nbit_arbiter_rr #(
    parameter N = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant
);

logic [$clog2(N)-1:0] pointer;
int idx;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pointer <= 0;
    else if (|grant)
        pointer <= pointer + 1;
end

always_comb begin
    idx = 0;
    grant = '0;
    
    for (int i = 0; i < N; i++) begin
        idx = (pointer + i) % N;
        if (req[idx]) begin
            grant[idx] = 1;
            break;
        end
    end
end

endmodule