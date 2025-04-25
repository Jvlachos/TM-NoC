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
    output logic o_transmit,
    input FLIT_t i_flit,
    input  logic i_rec_req, 
    output  logic o_rec_ack
    );
    assign o_rec_ack = 1;
    typedef enum logic [2:0] {
        IDLE = 0,
        HEAD,
        BODY,
        TAIL,
        REQ,
        SEND,
        DONE
    } STATE_t; 
    
    typedef enum logic [1:0] {
        IN_IDLE =0,
        IN_REC,
        IN_DONE
    } IN_STATE_t;
    
    STATE_t curr_state_ff;
    STATE_t next_state;
    
    IN_STATE_t curr_in_state;
    IN_STATE_t next_in_state;
    
     FLIT_t data;
     FLIT_t data_out;
     FLIT_t in_data_out;
    logic  bodyDone;
    logic  [$clog2(BODY_COUNT):0] bodyCount;
    logic  [$clog2(BODY_COUNT):0] bodyCounter;
    logic  fifo_write;
    logic  fifo_read;
    logic  fifo_full;
    logic  fifo_empty;
    
    logic  in_fifo_write;
    logic  in_fifo_read;
    logic  in_fifo_full;
    logic  in_fifo_empty;
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
        //val.head.xaddr = packet_append[15:8];
        //val.head.yaddr = packet_append[7:0];
        val.head.xaddr     = 8'd1;   // x = 0
        val.head.yaddr     = 8'd0;   // y = 0
        
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
        .o_fifo_read_data(data_out),
        .o_fifo_empty(fifo_empty)
    );
    
    
    sfifo #(FLIT_SIZE, $clog2(NUM_OF_FLITS)) inFIFO
    (
        .clk(clk),
        .rst_n(reset_n),
        .i_fifo_write(in_fifo_write),
        .i_fifo_read (in_fifo_read),
        .i_fifo_write_data(i_flit),
        .o_fifo_full(in_fifo_full),
        .o_fifo_read_data(in_data_out),
        .o_fifo_empty(in_fifo_empty)
    );
    
    always_ff@(posedge clk, negedge reset_n) begin
        if(~reset_n)
            o_flit <= '0;
        else begin
            if(fifo_read)
                o_flit <= data_out;
            else
                o_flit <= '0;
        end
    
    end
    
    always_comb begin
        next_in_state = IN_IDLE;
        if( i_start ) begin
            case(curr_in_state)
                IN_IDLE : next_in_state =  IN_REC;
                IN_REC : next_in_state =  IN_IDLE;
                IN_DONE : next_in_state =  IN_IDLE;
            endcase 
        end
    end 
    
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
        data.head.xaddr = '0;
        data.head.yaddr = '0;
        
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
            curr_in_state <= IN_IDLE;
            bodyCount <= '0;
        end
        else begin
            curr_state_ff <= next_state;
            curr_in_state <= next_in_state;
            bodyCount <= bodyCounter;
        end
    end
    
endmodule



