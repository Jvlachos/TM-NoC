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
    P_STATUS port_status[NUM_OF_PORTS]= '{default: P_IDLE};
    PORT_T next_port[NUM_OF_PORTS]='{default: NONE};
    always_comb begin
      routing_success = '{default: 0};
      o_outport_req = '{default: 0};
      next_port = '{default: NONE};
      o_s2o = '{default: 0};
      xaddr=0;
      yaddr=0;
      
      
       for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
          if(i_switch_req[i] == 1 && port_status[i] == P_IDLE) begin
            xaddr = i_r2s[i].flit.head.xaddr;
            yaddr = i_r2s[i].flit.head.yaddr;
            $display("Cycle %0t: Input Port %0d requested. Dest=(%0d,%0d), Router=(%0d,%0d)", 
                 $time, i, xaddr, yaddr, router_conf.xaddr, router_conf.yaddr);
            if (xaddr == router_conf.xaddr && yaddr == router_conf.yaddr)
                next_port[i] = LOCAL;
            else if (xaddr > router_conf.xaddr)
                next_port[i] = EAST;
            else if (xaddr < router_conf.xaddr)
                next_port[i] = WEST;
            else if (yaddr > router_conf.yaddr)
                next_port[i] = NORTH;
            else if (yaddr < router_conf.yaddr)
                next_port[i] = SOUTH;
            else
                next_port[i] = NONE;
          $display("Cycle %0t: Computed next port for input %0d is %s", 
                 $time, i, next_port[i].name());
          if (next_port[i] != NONE) begin
              o_outport_req[next_port[i]][i] = 1'b1;
              if (i_outport_ack[next_port[i]][i] == 1'b1) begin
              $display("Cycle %0t: got ACK from %s for input %0d", 
                         $time, next_port[i].name(), i);
                o_s2o[next_port[i]] = i_r2s[i];
                routing_success[i] = 1;
                port_status[i] = P_ACTIVE;
              end else begin
                $display("Cycle %0t: NO ACK from %s for input %0d", 
                         $time, next_port[i].name(), i);
              end
          end
       end else if(i_switch_req[i] == 1 && port_status[i] == P_ACTIVE) begin
        $display("Cycle %0t: input %0d is still transmiting in switch", 
                 $time, i, next_port[i].name());
        o_s2o[next_port[i]] = i_r2s[i];
        routing_success[i] = 1;
        port_status[i] = P_ACTIVE;
       end
       if (o_s2o[i].flit.head.flit_type == TAIL_FLIT) begin 
        $display("Cycle %0t: input %0d transmits tail FLIT", 
             $time, i, next_port[i].name());
        port_status[i] = P_IDLE;
        next_port[i]= NONE;
        o_s2o[i] = 0;
        routing_success[i] = 0;
       end
    end
  end  
endmodule
