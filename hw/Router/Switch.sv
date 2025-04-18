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
        input clk,
        input rst_n,
        input  router_pipeline_bus_t i_r2s[NUM_OF_PORTS],
        input  logic i_switch_req[NUM_OF_PORTS],
        input  logic [NUM_OF_PORTS-1:0]i_outport_ack[NUM_OF_PORTS],
        output logic [NUM_OF_PORTS-1:0]o_outport_req[NUM_OF_PORTS],
        output logic routing_success[NUM_OF_PORTS],
        output router_pipeline_bus_t o_s2o[NUM_OF_PORTS]
    );
    integer i,j;
    integer xaddr, yaddr;
    P_STATUS port_status[NUM_OF_PORTS]= '{default: P_IDLE};
        P_STATUS port_status_ff[NUM_OF_PORTS];
    router_pipeline_bus_t s2o[NUM_OF_PORTS];
    logic out_en;
   // PORT_T next_port[NUM_OF_PORTS]='{default: NONE};
   logic [4:0] grant;
   logic [4:0] req;
   
   always_comb begin
   
    for(i=0; i<NUM_OF_PORTS; i=i+1) begin 
        if(port_status_ff[i] == P_IDLE) req[i] = i_switch_req[i];
        else req[i] = 0;
    end
   end
   arbiter arb (
    .clk(clk),
    .rst_n(rst_n),
    .req(req),
    .grant(grant)
   );
    
   always_comb begin
    o_outport_req = '{default: 0};
    routing_success = '{default: 0};
    port_status = port_status_ff;
    case(req)
        5'b00000:
            ;
        5'b00001:
            o_outport_req[i_r2s[0].target_port] = grant;
            //if (i_outport_ack[i_r2s[0].target_port][i] 
        5'b00010:
            o_outport_req[i_r2s[1].target_port] = grant;
        5'b00100:
            o_outport_req[i_r2s[2].target_port] = grant;
        5'b01000:
            o_outport_req[i_r2s[3].target_port] = grant;
        5'b10000:
            o_outport_req[i_r2s[4].target_port] = grant;
    endcase
    case(grant)
        5'b00000:
            ;
        5'b00001:
            if (i_outport_ack[i_r2s[0].target_port]) begin
            for(j=0; j<NUM_OF_PORTS; j=j+1)  routing_success[j] = i_outport_ack[i_r2s[0].target_port][j];
            port_status[i_r2s[0].target_port] = P_ACTIVE; 
            end 
        5'b00010:
             if (i_outport_ack[i_r2s[1].target_port]) begin
                 for(j=0; j<NUM_OF_PORTS; j=j+1)  routing_success[j] = i_outport_ack[i_r2s[1].target_port][j];
                  port_status[i_r2s[1].target_port] = P_ACTIVE; 
            end 
        5'b00100:
             if (i_outport_ack[i_r2s[2].target_port]) begin
                 for(j=0; j<NUM_OF_PORTS; j=j+1)  routing_success[j] = i_outport_ack[i_r2s[2].target_port][j];
                  port_status[i_r2s[2].target_port] = P_ACTIVE; 
            end 
        5'b01000:
            if (i_outport_ack[i_r2s[3].target_port]) begin
                 for(j=0; j<NUM_OF_PORTS; j=j+1)  routing_success[j] = i_outport_ack[i_r2s[3].target_port][j];
                  port_status[i_r2s[3].target_port] = P_ACTIVE; 
            end 
        5'b10000:
             if (i_outport_ack[i_r2s[4].target_port]) begin
                 for(j=0; j<NUM_OF_PORTS; j=j+1)  routing_success[j] = i_outport_ack[i_r2s[4].target_port][j];
                  port_status[i_r2s[4].target_port] = P_ACTIVE; 
            end 
    endcase
    end
//    assign s2o = i_r2s;
//    always_comb begin
//      routing_success = '{default: 0};
//      o_outport_req = '{default: 0};
//     // next_port = '{default: NONE};
//     // s2o ='{default: 0};
//      xaddr=0;
//      yaddr=0;
//      out_en  = 0;
//      port_status = port_status_ff;
//       for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
//          //s2o[i] = o_s2o[i];
//           $display("Cycle %0t: flit : %0b %0d", 
//                         $time, s2o[i].flit, i);
          
//          if(i_switch_req[i] == 1 && port_status_ff[i] == P_IDLE) begin
////     
//          $display("Cycle %0t: Computed next port for input %0d is %s", 
//                 $time, i, i_r2s[i].target_port.name());
//          if (i_r2s[i].target_port != NONE_PORT) begin
//              o_outport_req[i_r2s[i].target_port][i] = 1'b1;
//              if (i_outport_ack[i_r2s[i].target_port][i] == 1'b1) begin
//              $display("Cycle %0t: got ACK from %s for input %0d", 
//                         $time, i_r2s[i].target_port.name(), i);
//                //s2o[i_r2s[i].target_port] = i_r2s[i];
//                routing_success[i] = 1;
//                port_status[i] = P_ACTIVE;
//                out_en = 1;
//              end else begin
//                $display("Cycle %0t: NO ACK from %s for input %0d", 
//                         $time, i_r2s[i].target_port.name(), i);
//                  //  s2o[i_r2s[i].target_port] = o_s2o[i];     
//              end
//          end
//       end else if(i_switch_req[i] == 1 && port_status_ff[i] == P_ACTIVE) begin
//        $display("Cycle %0t: input %0d is still transmiting in switch", 
//                 $time, i, i_r2s[i].target_port.name());
//        //s2o[i_r2s[i].target_port] = i_r2s[i];
//        routing_success[i] = 1;
//        port_status[i] = P_ACTIVE;
//        out_en = 1;
//       end
//       if (o_s2o[i].flit.head.flit_type == TAIL_FLIT) begin 
//        $display("Cycle %0t: input %0d transmits tail FLIT", 
//             $time, i,i_r2s[i].target_port.name());
//        port_status[i] = P_IDLE;
////        next_port[i]= NONE;
//       // s2o[i].flit = '0;
//       // s2o[i].target_port = NONE_PORT;
//       // s2o[i].flit.head.flit_type = NONE_FLIT;
//        routing_success[i] = 0;
//        out_en = 1;
//       end
//    end
    

//  end
  
  always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        o_s2o <= '{default: 0};
        port_status_ff <=  '{default: P_IDLE};
    end
    else    begin 
        port_status_ff <= port_status;
        o_s2o <= s2o;
    end
    //else o_s2o <= o_s2o;
  end
endmodule
