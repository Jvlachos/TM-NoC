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
        output router_pipeline_bus_t o_s2o[NUM_OF_PORTS],
        input OUT_PORT_t i_oport[NUM_OF_PORTS]
    );
    integer i,j,k,x;
    SW_PORT_STATUS  [NUM_OF_PORTS-1:0] port_status= '{default: P_IDLE};
    SW_PORT_STATUS [NUM_OF_PORTS-1:0] port_status_ff;



   logic [4:0] grant;
   logic [4:0] request_en;
   integer y;
   always_comb begin
    request_en = '0;
    for(k=0; k<NUM_OF_PORTS; k=k+1) begin
        if(i_switch_req[k]) begin
            if(i_r2s[k].target_port != NONE_PORT) begin
                request_en[k] = i_oport[i_r2s[k].target_port].port_status == PORT_FREE ? i_switch_req[k] : 0;
            end
        end
        
     end
   end
   
   arbiter arb (
    .clk(clk),
    .rst_n(rst_n),
    .req(request_en),
    .grant(grant)
   );
    
   always_comb begin
    o_outport_req = '{default: 0};
    routing_success = '{default: 0};
    port_status = port_status_ff;
 
    for(i=0; i<NUM_OF_PORTS; i=i+1) begin 
         o_outport_req[i_r2s[i].target_port][i] = (request_en[i] && grant[i]) ? 1  :'0;
    end

    for(x=0; x<NUM_OF_PORTS; x=x+1) begin
          
          if (i_outport_ack[i_r2s[x].target_port][x] && port_status[i_r2s[x].target_port].target_port == P_IDLE ) begin
            routing_success[x] = 1'b1;    
           // port_status[x].source_port = P_ACTIVE; 
            port_status[i_r2s[x].target_port].target_port = P_ACTIVE;
            port_status[i_r2s[x].target_port].pair = x;
          end 
    end
   end
    integer y,l;
  
  always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        o_s2o <= '{default: 0};
         for(y=0; y<NUM_OF_PORTS; y=y+1) begin
            port_status_ff[y].target_port <=  P_IDLE;
            port_status_ff[y].pair <= NONE_PORT;
         end
       
    end
    else    begin 
        port_status_ff <= port_status;
     
        for(l=0; l<NUM_OF_PORTS; l=l+1) begin
         if(i_r2s[l].flit.tail.flit_type == TAIL_FLIT) begin
            port_status_ff[i_r2s[l].target_port].target_port <= P_IDLE;
           // port_status_ff[l].source_port <= P_IDLE; 
            port_status_ff[i_r2s[l].target_port].pair = NONE_PORT;
          end
          
          if(port_status[l].target_port == P_ACTIVE) begin
            o_s2o[l] <= i_r2s[port_status[l].pair];
          end
          else o_s2o[l] = invalid_flit();
        end
  end
endmodule
