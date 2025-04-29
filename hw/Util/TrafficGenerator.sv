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
    input  logic i_send,
    output  FLIT_t o_flit,
    output logic o_transmit,
    input FLIT_t i_flit,
    input  logic i_rec_req, 
    output  logic o_rec_ack
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
    
    typedef enum logic [1:0] {
        IN_IDLE =0,
        IN_REC,
        IN_READ,
        IN_SENDING
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
    logic  is_master;
    logic pass_en;
    integer repetitions = 1000;
    integer rep;
    integer rep_ff;
    integer cycle;
    assign is_master = $unsigned(router_conf.xaddr) == 0 && $unsigned(router_conf.yaddr) == 0 ;
    
    always_ff@(posedge clk,negedge reset_n) begin
        if(~reset_n)
            packet_append <= '0;
        else 
            packet_append <= $unsigned(packet_append) +1 ;
    end
    

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
                IN_IDLE : next_in_state = i_rec_req && in_fifo_empty  ? IN_REC : IN_IDLE;
                IN_REC : next_in_state =  ~in_fifo_full ? IN_REC  : IN_READ;
                IN_READ : next_in_state = ~in_fifo_empty ? IN_READ : IN_SENDING;
                IN_SENDING : next_in_state = ~fifo_empty ? IN_SENDING : IN_IDLE;
            endcase 
        end
    end 
    
    
    
    always_comb begin
        o_rec_ack = 1;
       
        in_fifo_write = 0;
        pass_en = 0;
        if(i_start) begin 
            case(curr_in_state)
                IN_IDLE : ;
                IN_REC  : begin
                 o_rec_ack = 1;
                 if(i_flit.flit[FLIT_SIZE-1]) begin
                    in_fifo_write = 1;
                    print_in_info(0,cycle,"Packet received at:",router_conf);
                   end
                end
                IN_READ : begin
                    pass_en = 1;
                    //in_fifo_read = 1;
                end
                IN_SENDING : pass_en = 1;
            
            endcase
        end    
    end 
    logic is_target = $unsigned(router_conf.xaddr) == 3 && $unsigned(router_conf.yaddr) == 3 ;
    always_comb begin
        next_state = IDLE;
        rep = rep_ff;
        if(rep < repetitions) begin
        if( (i_start ) )begin
            case(curr_state_ff)
                IDLE : next_state =  HEAD;
                HEAD : next_state = BODY;
                BODY : next_state = bodyDone ? TAIL : BODY;
                TAIL : next_state = REQ;
                REQ  : next_state = i_send ? SEND : REQ;
                SEND : next_state = ~fifo_empty ? SEND : DONE;
                DONE : begin next_state = IDLE;
                    rep = rep_ff + 1;
                end
            endcase 
        end
        end
    end 
    
    integer xall,yall;
    integer xall_ff,yall_ff;
    
    always_comb begin 
        bodyDone   = 1'b0;
        bodyCounter = '0;
        fifo_read = 0;
        fifo_write =0;
        in_fifo_read = 1;
        data.head.valid = 0;
        data.head.flit_type = FLIT_TYPE_t'(NONE_FLIT);
        data.head.xaddr = '0;
        data.head.yaddr = '0;
        xall = xall_ff;
        yall = yall_ff;
        o_transmit = 0;
        if( i_start ) begin
            if(xall == 4) begin
                xall = 0;
                yall = yall_ff +1;
            end
            if(yall == 4) yall = 0;
            case(curr_state_ff)
                IDLE : begin
                    fifo_read = 0;
                    fifo_write =0;
                end
                HEAD : begin
                   
                    if(pass_en) begin
                        in_fifo_read = 1;
                       // data = gen_traversal_head(in_data_out,router_conf);
                       //   data = roundtrip(in_data_out);
                    end
                    else begin
                        
                        data = gen_head2addr( $unsigned(xall), $unsigned(yall));
                         xall = xall_ff + 1;
                    end
                       // data = toAll(router_conf,c);
                    if(~fifo_full)
                        fifo_write =1;
                end
                BODY : begin
                    
                    if(pass_en) begin 
                        //data = gen_pass_body(in_data_out,router_conf);
                        in_fifo_read = 1; 
                    end
                    else data = gen_body(router_conf);
                    
                    bodyCounter = $unsigned(bodyCount) + 1;
                    if($unsigned(bodyCounter) == BODY_COUNT) begin
                        bodyDone = 1'b1;
                    end
                    if(~fifo_full)
                        fifo_write =1;
                   
                end
                TAIL : begin 
                   
                    if(pass_en) begin
                        in_fifo_read = 1;
                       // data = in_data_out;
                    end
                    else  data = gen_tail(packet_append);
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
            rep_ff <= 0;
            cycle <= 0;
            xall_ff<=0;
            yall_ff <=0;
        end
        else begin
            curr_state_ff <= next_state;
            curr_in_state <= next_in_state;
            bodyCount <= bodyCounter;
            rep_ff <= rep;
            cycle <= cycle +  1;
            xall_ff <= xall;
            yall_ff <= yall;
        end
    end
    
endmodule



