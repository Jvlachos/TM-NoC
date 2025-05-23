`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2025 19:28:59
// Design Name: 
// Module Name: InputUnit
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


module InputUnit
    import router_pkg::*;
    #(parameter ROUTER_CONFIG router_conf ='{default:9999},
      parameter integer in_id = 0)
    (
     input   clk,
    input   reset_n,
    input   FLIT_t i_flit,
    input   logic i_upstream_req,
    input   logic i_switch_ack,
    input   logic i_routing_success,
    output  logic o_transmit_ack,
    output  logic o_switch_req,
    output  GRP_VEC_t o_vec,
    output  PORT_STATUS_t o_port_status,
    output router_pipeline_bus_t o_r2s
    );
    
    logic [FLIT_SIZE-1:0] buffer_odata;
    router_pipeline_bus_t fetch2route;
    logic buffer_full;
    logic buffer_empty;
    logic buffer_write;
    logic fetch_en;
    logic buffer_read;
    logic sent;
    GRP_VEC_t status_vec; 
    PORT_STATUS_t  port_status;
    PORT_t  target_port;
    assign o_port_status = port_status;
    assign o_vec = status_vec;
    integer cycle;
    
 
    
    sfifo #(FLIT_SIZE,$clog2(NUM_OF_FLITS)) INPUT_BUFFER 
    (
      .clk(clk),
      .rst_n(reset_n),
      .i_fifo_write(buffer_write && i_flit[FLIT_SIZE-1] == 1),
      .i_fifo_read( fetch_en),
      .i_fifo_write_data(i_flit),
      .o_fifo_full(buffer_full),
      .o_fifo_read_data(buffer_odata),  
      .o_fifo_empty(buffer_empty)
    );
    
    
    InputUnitFSM #(
    .router_conf(router_conf)) fsm  
     (
        .clk(clk),
        .reset_n(reset_n),
        .i_flit(fetch2route.flit),
        .i_switch_ack(i_switch_ack),
        .routing_success(i_routing_success),
        .o_gstate(status_vec.gstate),
        .o_switch_req(o_switch_req),
        .o_packet_done(sent),
        .o_next_port(target_port)
    );
    
 
     always_ff@(posedge clk, negedge reset_n) begin : bufferStatus
          if(~reset_n) begin
            status_vec.buffer_status <= PACKET_EMPTY;
          end
          else begin
              if(i_flit.tail.flit_type == TAIL_FLIT ) begin
                status_vec.buffer_status <= PACKET_RECEIVED;
                 

                end
              else if(buffer_empty )
                status_vec.buffer_status <= PACKET_EMPTY;
              else if(!buffer_empty && !buffer_full && status_vec.gstate == IDLE)
                status_vec.buffer_status <= PACKET_FILLING;
              else
                status_vec.buffer_status <= status_vec.buffer_status;
          end
    end
    
    
    always_comb begin : fetch_enable
        fetch_en = 0;
        if(status_vec.gstate != ROUTING
            && status_vec.buffer_status == PACKET_RECEIVED)
            fetch_en = 1;
    end

   
    always_ff @(posedge clk, negedge reset_n) begin : port_status_ff
        if(~reset_n) begin
            port_status <= PORT_STATUS_t'(PORT_FREE);
            o_transmit_ack <= 0;
            buffer_write <= 0;
        end
        else begin
            unique case(port_status) 
             PORT_FREE : begin
                if(i_upstream_req) begin
                    o_transmit_ack <= 1;
                    buffer_write   <= 1;
                    port_status <= PORT_STATUS_t'(PORT_OCCUPIED);
                end
                else begin
                    o_transmit_ack <= 0;
                    buffer_write   <= 0;
                    port_status  <= port_status;
                end
             end
              PORT_OCCUPIED:  begin
                if(sent) begin
                    if(i_upstream_req) begin
                        port_status <= PORT_STATUS_t'(PORT_OCCUPIED);
                        buffer_write <= 1;
                        o_transmit_ack <= 1;
                    end
                    else begin
                        port_status <= PORT_STATUS_t'(PORT_FREE);
                        buffer_write <= 0;
                        o_transmit_ack <= 0;
                    end
                end
                else begin
                    o_transmit_ack <= 0;
                    port_status  <= port_status;
                    if(status_vec.buffer_status == PACKET_RECEIVED) begin
                        buffer_write <= 0;
                       
                    end 
                    else
                        buffer_write <= buffer_write;    
                    end
                end
               default : assert (0) else $error("[port_status_ff] : ERROR Port status");
              endcase       
        end
        
    end

    always_ff @(posedge clk, negedge reset_n) begin : cycle_count
        if(~reset_n) cycle = 0;
        else cycle = cycle + 1;
    end

   
    always_ff @(posedge clk, negedge reset_n) begin : f2r
        if(~reset_n) begin
            fetch2route.flit.head.flit_type = NONE_FLIT;
         end   
        else if(fetch_en) begin
            fetch2route.flit <= buffer_odata;
        end
        else begin
            fetch2route.flit <= fetch2route.flit;
        end
    end
    assign o_r2s.target_port = target_port ;
    assign o_r2s.flit = target_port != NONE_PORT ? fetch2route.flit : invalid_flit();
    
   
endmodule
