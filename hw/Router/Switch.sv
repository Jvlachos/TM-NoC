`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 03:31:49 PM
// Design Name: 
// Module Name: Switch
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
import router_pkg::*;

module Switch
    #(parameter ROUTER_CONFIG router_conf ='{default:9999}) (
        input  router_pipeline_bus_t i_r2s[NUM_OF_PORTS],
        input  logic i_switch_req[NUM_OF_PORTS],
        input  logic [NUM_OF_PORTS-1:0]i_outport_ack[NUM_OF_PORTS],
        output logic [NUM_OF_PORTS-1:0]o_outport_req[NUM_OF_PORTS],
        output logic routing_success[NUM_OF_PORTS],
        output router_pipeline_bus_t o_s2o[NUM_OF_PORTS]
    );
    integer i;
    integer xaddr, yaddr;
    PORT_T next_port;
    
    always_comb begin
       for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
          o_outport_req[i] = '0;
          routing_success[i] = 0;
          next_port = NONE;
          if(i_switch_req[i] == 1) begin
            xaddr = i_r2s[i].flit.head.xaddr;
            yaddr = i_r2s[i].flit.head.yaddr;
            if (xaddr == router_conf.xaddr && yaddr == router_conf.yaddr)
                next_port = LOCAL;
            else if (xaddr > router_conf.xaddr)
                next_port = EAST;
            else if (xaddr < router_conf.xaddr)
                next_port = WEST;
            else if (yaddr > router_conf.yaddr)
                next_port = NORTH;
            else if (yaddr < router_conf.yaddr)
                next_port = SOUTH;
            else
                next_port = NONE;
          if (next_port != NONE) begin
              o_outport_req[next_port][i] = 1'b1;
              if (i_outport_ack[next_port][i] == 1'b1) begin
                o_s2o[next_port] = i_r2s[i];
                routing_success[i] = 1;
              end
          end
       end
    end
  end  
endmodule
