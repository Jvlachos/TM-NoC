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
    integer i,j,k,x;
    integer xaddr, yaddr;
    SW_PORT_STATUS  [NUM_OF_PORTS-1:0] port_status= '{default: P_IDLE};
    SW_PORT_STATUS [NUM_OF_PORTS-1:0] port_status_ff;
    router_pipeline_bus_t s2o[NUM_OF_PORTS];

   logic [4:0] grant;
   logic [4:0] req;

   always_comb begin
    req = '0;
    for(k=0; k<NUM_OF_PORTS; k=k+1) begin
        if(i_switch_req[k]) begin
            if(i_r2s[k].target_port != NONE_PORT) 
                req[k] = port_status[i_r2s[k].target_port].target_port == P_IDLE ? i_switch_req[k] : 0;
        end
        
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
    for(i=0; i<NUM_OF_PORTS; i=i+1) begin
         o_outport_req[i_r2s[i].target_port] = req[i] ? grant : '0;
    end

    for(x=0; x<NUM_OF_PORTS; x=x+1) begin
          if (i_outport_ack[i_r2s[x].target_port]) begin
            for(j=0; j<NUM_OF_PORTS; j=j+1) 
                 routing_success[j] = i_outport_ack[i_r2s[x].target_port][j];
                 
            port_status[i_r2s[x].target_port].target_port = P_ACTIVE;
            port_status[x].source_port = P_ACTIVE; 
          end 
          if(o_s2o[x].flit.tail.flit_type == TAIL_FLIT) begin
             port_status[o_s2o[x].target_port].target_port = P_IDLE;
             port_status[x].source_port = P_IDLE; 
          end
     
    end
   end

  
  always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        o_s2o <= '{default: 0};
        port_status_ff <=  '{default: P_IDLE};
    end
    else    begin 
        port_status_ff <= port_status;
        if(port_status[0].target_port == P_ACTIVE) begin
            if(port_status[0].source_port == P_ACTIVE)      o_s2o[0] <= i_r2s[0];
            else if(port_status[1].source_port == P_ACTIVE) o_s2o[0] <= i_r2s[1];
            else if(port_status[2].source_port == P_ACTIVE) o_s2o[0] <= i_r2s[2];
            else if(port_status[3].source_port == P_ACTIVE) o_s2o[0] <= i_r2s[3];
            else if(port_status[4].source_port == P_ACTIVE) o_s2o[0] <= i_r2s[4];
            else o_s2o[0] <= o_s2o[0];
            
        end else o_s2o[0] <= '0;
        if(port_status[1].target_port == P_ACTIVE) begin
           if(port_status[0].source_port == P_ACTIVE)       o_s2o[1] <= i_r2s[0];
            else if(port_status[1].source_port == P_ACTIVE) o_s2o[1] <= i_r2s[1];
            else if(port_status[2].source_port == P_ACTIVE) o_s2o[1] <= i_r2s[2];
            else if(port_status[3].source_port == P_ACTIVE) o_s2o[1] <= i_r2s[3];
            else if(port_status[4].source_port == P_ACTIVE) o_s2o[1] <= i_r2s[4];
            else o_s2o[1] <= o_s2o[1];
        end else o_s2o[1] <= '0;
        if(port_status[2].target_port == P_ACTIVE) begin
            if(port_status[0].source_port == P_ACTIVE)      o_s2o[2] <= i_r2s[0];
            else if(port_status[1].source_port == P_ACTIVE) o_s2o[2] <= i_r2s[1];
            else if(port_status[2].source_port == P_ACTIVE) o_s2o[2] <= i_r2s[2];
            else if(port_status[3].source_port == P_ACTIVE) o_s2o[2] <= i_r2s[3];
            else if(port_status[4].source_port == P_ACTIVE) o_s2o[2] <= i_r2s[4];
            else o_s2o[2] <= o_s2o[2];
        end else o_s2o[2] <= '0;
        if(port_status[3].target_port == P_ACTIVE) begin
              if(port_status[0].source_port == P_ACTIVE)    o_s2o[3] <= i_r2s[0];
            else if(port_status[1].source_port == P_ACTIVE) o_s2o[3] <= i_r2s[1];
            else if(port_status[2].source_port == P_ACTIVE) o_s2o[3] <= i_r2s[2];
            else if(port_status[3].source_port == P_ACTIVE) o_s2o[3] <= i_r2s[3];
            else if(port_status[4].source_port == P_ACTIVE) o_s2o[3] <= i_r2s[4];
            else o_s2o[3] <= o_s2o[3];
        end else o_s2o[3] <= '0;
        if(port_status[4].target_port == P_ACTIVE) begin
           if(port_status[0].source_port == P_ACTIVE)       o_s2o[4] <= i_r2s[0];
            else if(port_status[1].source_port == P_ACTIVE) o_s2o[4] <= i_r2s[1];
            else if(port_status[2].source_port == P_ACTIVE) o_s2o[4] <= i_r2s[2];
            else if(port_status[3].source_port == P_ACTIVE) o_s2o[4] <= i_r2s[3];
            else if(port_status[4].source_port == P_ACTIVE) o_s2o[4] <= i_r2s[4];
            else o_s2o[4] <= o_s2o[4];
        end else o_s2o[4] <= '0;
        
    end
    //else o_s2o <= o_s2o;
  end
endmodule
