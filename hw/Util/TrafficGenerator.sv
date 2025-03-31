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
  #(parameter BODY_COUNT=2  )
   (
    input  logic clk,
    input  logic reset_n,
    input  logic i_start,
    input  logic i_send,
    output  FLIT_t o_flit,
    output logic o_transmit
    );
    
    typedef enum logic [2:0] {
        IDLE = 0,
        HEAD,
        BODY,
        TAIL,
        REQ,
        SEND,
        DONE
    } STATE_t; 
    
    STATE_t curr_state_ff;
    STATE_t next_state;
     FLIT_t data;
    logic  bodyDone;
    logic  [$clog2(BODY_COUNT):0] bodyCount;
    logic  [$clog2(BODY_COUNT):0] bodyCounter;
    logic  fifo_write;
    logic  fifo_read;
    logic  fifo_full;
    logic  fifo_empty;
    logic  [15:0] packet_append;
    
    always_ff@(posedge clk,negedge reset_n) begin
        if(~reset_n)
            packet_append <= '0;
        else 
            packet_append <= $unsigned(packet_append) +1 ;
    end
    
    function automatic FLIT_t gen_head();
        FLIT_t val;
        
        val.head.valid =1;
        val.head.flit_type = FLIT_TYPE_t'(HEAD_FLIT);
        val.head.address = packet_append;
        
        return val;
    endfunction
    
     function automatic FLIT_t gen_body();
        FLIT_t val;
        val.body.valid =1;
        val.body.flit_type = FLIT_TYPE_t'(BODY_FLIT);
        val.body.data = packet_append;
        return val;
    endfunction
    
     function automatic FLIT_t gen_tail();
            FLIT_t val;
         val.tail.valid =1;
         val.tail.flit_type = FLIT_TYPE_t'(TAIL_FLIT);
         val.tail.reserved = packet_append;
        return val;
    endfunction
    
    sfifo #(FLIT_SIZE, $clog2(NUM_OF_FLITS)) outFIFO
    (
        .clk(clk),
        .rst_n(reset_n),
        .i_fifo_write(fifo_write),
        .i_fifo_read (fifo_read),
        .i_fifo_write_data(data),
        .o_fifo_full(fifo_full),
        .o_fifo_read_data(o_flit),
        .o_fifo_empty(fifo_empty)
    );
    
    
    always_comb begin
        next_state = IDLE;
        if( i_start ) begin
            case(curr_state_ff)
                IDLE : next_state =  HEAD;
                HEAD : next_state = BODY;
                BODY : next_state = bodyDone ? TAIL : BODY;
                TAIL : next_state = REQ;
                REQ  : next_state = i_send ? SEND : REQ;
                SEND : next_state = ~fifo_empty ? SEND : DONE;
                DONE : next_state = IDLE;
            endcase 
        end
    end 
    
    always_comb begin 
        bodyDone   = 1'b0;
        bodyCounter = '0;
        fifo_read = 0;
        fifo_write =0;
        data.head.valid = 0;
        data.head.flit_type = FLIT_TYPE_t'(NONE_FLIT);
        data.head.address = '0;
        o_transmit = 0;
        if( i_start ) begin
            case(curr_state_ff)
                IDLE : begin
                    fifo_read = 0;
                    fifo_write =0;
                end
                HEAD : begin
                    data = gen_head();
                    if(~fifo_full)
                        fifo_write =1;
                end
                BODY : begin
                    data = gen_body();
                    bodyCounter = $unsigned(bodyCount) + 1;
                    if($unsigned(bodyCounter) == BODY_COUNT) begin
                        bodyDone = 1'b1;
                    end
                    if(~fifo_full)
                        fifo_write =1;
                   
                end
                TAIL : begin 
                    data = gen_tail();
                    if(~fifo_full)
                        fifo_write =1;
                end
                REQ : begin 
                    o_transmit = 1;
                end                
                SEND: begin
                    fifo_write = 0;
                    if(~fifo_empty)
                        fifo_read = 1;
                        
                end
                DONE : begin 
                    //o_done = 1'b1;
                    fifo_write = 0;
                    fifo_read = 0;
                end
            endcase 
        end
    end
    
    //assign o_flit = data;
    
    always_ff@(posedge clk, negedge reset_n) begin 
        if(~reset_n) begin
            curr_state_ff <= IDLE;
            bodyCount <= '0;
        end
        else begin
            curr_state_ff <= next_state;
            bodyCount <= bodyCounter;
        end
    end
    
endmodule



