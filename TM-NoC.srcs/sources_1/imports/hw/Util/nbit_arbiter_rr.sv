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
int req_idx;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pointer <= '0;
    else if (|req) begin
        // move pointer to next position after grant
        for (int i = 0; i < N; i++) begin
            req_idx = (pointer + i) % N;
            if (req[req_idx]) begin
                pointer <= req_idx + 1;
                break;
            end
        end
    end
end

int idx;

always_comb begin
    grant = '0;

    for (int i = 0; i < N; i++) begin
        idx = pointer + i;
        if (idx >= N)
            idx = idx - N;

        if (req[idx]) begin
            grant[idx] = 1'b1;
            break;
        end
    end
end

endmodule