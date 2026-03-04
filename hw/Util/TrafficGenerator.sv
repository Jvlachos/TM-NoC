`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 16:57:30
// Design Name: 
// Module Name: TrafficGenerator
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


module TrafficGenerator
    import router_pkg::*;
  #(parameter BODY_COUNT=2,
  parameter ROUTER_CONFIG router_conf ='{default:9999}  )
   (
    input  logic clk,
    input  logic reset_n,
    input  logic i_start,
    input FLIT_t i_flit_from_tb,
    input logic  i_tb_flit_request,
    output logic o_tb_flit_ack,
    input  logic i_send,
    output  FLIT_t o_flit,
    output logic o_transmit,
    input FLIT_t i_flit_from_router,
    input  logic i_rec_req, 
    output  logic o_rec_ack,
    output  PACKET_t o_packet_to_tb,
    output  logic    o_packet_done
    );
    
    typedef enum logic [2:0] {
        OUT_IDLE = 0,
        OUT_RECEIVING,
        OUT_REQUESTING,
        OUT_SENDING
    } STATE_t; 
    
    typedef enum logic [1:0] {
        IN_IDLE =0,
        IN_REC,
        IN_READ
    } IN_STATE_t;
    
    STATE_t curr_out_state;
    STATE_t next_out_state;
    
    IN_STATE_t curr_in_state;
    IN_STATE_t next_in_state;
    
     FLIT_t data;
     FLIT_t data_out;
     FLIT_t in_data_out;

    logic  fifo_write;
    logic  fifo_read;
    logic  fifo_full;
    logic  fifo_empty;
    
    logic  in_fifo_write;
    logic  in_fifo_read;
    logic  in_fifo_full;
    logic  in_fifo_empty;
    logic pass_en;
    int packet_idx;
    int packet_idx_mod;
    
    assign packet_idx_mod = packet_idx % NUM_OF_FLITS;
    sfifo #(FLIT_SIZE, $clog2(NUM_OF_FLITS)) outFIFO
    (
        .clk(clk),
        .rst_n(reset_n),
        .i_fifo_write(fifo_write),
        .i_fifo_read (fifo_read),
        .i_fifo_write_data(i_flit_from_tb),
        .o_fifo_full(fifo_full),
        .o_fifo_read_data(data_out),
        .o_fifo_empty(fifo_empty)
    );
    
    
    sfifo #(FLIT_SIZE, $clog2(NUM_OF_FLITS)) inFIFO
    (
        .clk(clk),
        .rst_n(reset_n),
        .i_fifo_write(in_fifo_write),
        .i_fifo_read (in_fifo_read),
        .i_fifo_write_data(i_flit_from_router),
        .o_fifo_full(in_fifo_full),
        .o_fifo_read_data(in_data_out),
        .o_fifo_empty(in_fifo_empty)
    );
    
    always_ff@(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            o_flit <= '0;
            o_packet_to_tb <= '0;
            packet_idx <= 0;
            o_packet_done  <= 0;
        end
        else begin
            if(fifo_read) o_flit <= data_out;
            else          o_flit <= '0;
            
            if(in_fifo_read) begin
                unique case(packet_idx_mod)
                    0 : begin
                        o_packet_to_tb.head <= in_data_out;
                        o_packet_to_tb.body1 <= '0;
                        o_packet_to_tb.body2 <= '0;
                        o_packet_to_tb.tail  <= '0;
                        o_packet_done <= 0;
                    end
                    1 : begin
                        o_packet_to_tb.head <= o_packet_to_tb.head;
                        o_packet_to_tb.body1 <= in_data_out;
                        o_packet_to_tb.body2 <= '0;
                        o_packet_to_tb.tail  <= '0;
                        o_packet_done <= 0;
                    end
                    2 : begin
                        o_packet_to_tb.head <= o_packet_to_tb.head;
                        o_packet_to_tb.body1 <= o_packet_to_tb.body1;
                        o_packet_to_tb.body2 <= in_data_out;
                        o_packet_to_tb.tail  <= '0;
                        o_packet_done <= 0;
                    end
                    
                    3 : begin
                        o_packet_to_tb.head <= o_packet_to_tb.head;
                        o_packet_to_tb.body1 <= o_packet_to_tb.body1;
                        o_packet_to_tb.body2 <= o_packet_to_tb.body2;
                        o_packet_to_tb.tail  <= in_data_out;
                        o_packet_done <= 1;
                    end
                endcase
                packet_idx <= packet_idx + 1;
                //o_flit <= data_out;
                
            end
            else begin
                //o_flit <= '0;
                packet_idx <= 0;
                o_packet_to_tb <= '0;
                o_packet_done <= 0;
            end
       end
    
    end
    
    always_comb begin
        next_in_state = IN_IDLE;
        if( i_start ) begin
            case(curr_in_state)
                IN_IDLE : next_in_state = i_rec_req && in_fifo_empty  ? IN_REC : IN_IDLE;
                IN_REC : next_in_state =  ~in_fifo_full ? IN_REC  : IN_READ;
                IN_READ : next_in_state = ~in_fifo_empty ? IN_READ : IN_IDLE;
            endcase 
        end
    end 
    
    always_comb begin
        next_out_state = OUT_IDLE;
        if(i_start) begin
            unique case(curr_out_state)
                OUT_IDLE : next_out_state = i_tb_flit_request && fifo_empty ? OUT_RECEIVING : OUT_IDLE;
                OUT_RECEIVING:  next_out_state = fifo_full ? OUT_REQUESTING : OUT_RECEIVING;
                OUT_REQUESTING : next_out_state = i_send ? OUT_SENDING : OUT_REQUESTING;
                OUT_SENDING:   next_out_state = fifo_empty ? OUT_IDLE : OUT_SENDING;
            endcase 
        end
    end
    
    
    
    integer received;
    always_ff @(posedge clk,negedge reset_n) begin
        if(~reset_n) received <= 0;
        else begin
            if(i_flit_from_router.flit[FLIT_SIZE-1] && i_flit_from_router.tail.flit_type == TAIL_FLIT) begin
                received <= received + 1;
                ///$display("received : %d",received);
                 
              end
             else received <= received;
        end
    
    end
    
    
    always_comb begin
        o_rec_ack = 0;
       
        in_fifo_write = 0;
        in_fifo_read = 0;
        pass_en=0;
        if(i_start) begin 
            case(curr_in_state)
                IN_IDLE : if(i_rec_req && in_fifo_empty) o_rec_ack = 1;
                IN_REC  : begin
                 //o_rec_ack = 1;
                 if(i_flit_from_router.flit[FLIT_SIZE-1]) begin
                    if(i_flit_from_router.tail.flit_type == TAIL_FLIT) begin
                        
                        // $display("Id Received at (%d,%d) : x:%d, y:%d",router_conf.xaddr,router_conf.yaddr,i_flit_from_router.head.xaddr,i_flit_from_router.head.yaddr);
                    end
                    in_fifo_write = 1;
                   
                   end
                end
                IN_READ : begin
                   in_fifo_read = 1;
                end
            
            endcase
        end    
    end 
   
    
    always_comb begin
       fifo_read = 0;
       fifo_write =0;
       o_transmit =0; 
       o_tb_flit_ack = 0;
       unique case(curr_out_state)
        OUT_IDLE: begin
//            if(i_tb_flit_request && in_fifo_empty)
//                o_tb_flit_ack = 1;
        end
        OUT_RECEIVING : begin
        
        o_tb_flit_ack = 1;
            if(~fifo_full && i_flit_from_tb.flit[FLIT_SIZE-1]) begin
                fifo_write = 1;
                
            end
        end
        OUT_REQUESTING : begin
            o_transmit = 1;
        end
        OUT_SENDING : begin
            if( ~fifo_empty)
                fifo_read = 1;
        end
       endcase
    end
    
    always_ff@(posedge clk, negedge reset_n) begin 
        if(~reset_n) begin
            curr_out_state <= OUT_IDLE;
            curr_in_state <= IN_IDLE;
     
        end
        else begin
            curr_out_state <= next_out_state;
            curr_in_state <= next_in_state;
        end
    end
    
endmodule



