`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2026 02:08:55 PM
// Design Name: 
// Module Name: ni_backend
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
import ni_pkg::*;
import router_pkg::*;
module ni_backend  #(parameter NODE_IDX = 0)( 
    input clk,
    input rst_n,
    input  logic tx_ni_request [MEM_MAPPED_REGS-1:0],
    input  logic tx_router_ack ,
    input  NI_DATA_BUS_t tx_ni_data [MEM_MAPPED_REGS-1:0],
    input TX_CNTRL_t i_tx_regs_data [MEM_MAPPED_REGS-1:0],
    output logic tx_router_request,
    output logic tx_ni_ack [MEM_MAPPED_REGS-1:0],
    output FLIT_t o_tx_flit,
    input logic rx_router_request,
    output logic rx_router_ack,
    input FLIT_t i_flit,
    output logic o_rx_ni_request [MEM_MAPPED_REGS-1:0],
    input  logic i_rx_ni_ack [MEM_MAPPED_REGS-1:0],
    output logic [NI_DATA_SIZE-1:0] o_rx_data,
    output  RX_CNTRL_t o_rx_reg_data [MEM_MAPPED_REGS-1:0]
    );
    
    ni_tx_state_t current_tx_status;
    ni_tx_state_t next_tx_status;
    
    ni_tx_state_t current_rx_status;
    ni_tx_state_t next_rx_status;
    
    
    FLIT_TYPE_t encode_flit_type;
    FLIT_t encoded_flit;
    logic encode_done;
    
    logic [31:0] tx_idx;
    logic [31:0] tx_idx_ff;
    //tx fifo
    logic tx_fifo_write;
    logic tx_fifo_read;
    logic [NI_DATA_SIZE-1:0] tx_fifo_write_data;
    logic [NI_DATA_SIZE-1:0] tx_fifo_read_data;
    logic tx_fifo_full;
    logic tx_fifo_empty;
    
    logic [31:0] tx_flit_cnt;
    FLIT_t tx_flit_to_router;
    logic [NI_DATA_SIZE-1:0] tx_fifo_read_data_ff;
    logic [NI_DATA_SIZE-1:0] tx_to_encode;
    assign o_tx_flit = tx_flit_to_router;
    //tx fifo end    
    //--------------------///
    //rx fifo 
    logic rx_fifo_write;
    logic rx_fifo_read;
    logic [NI_DATA_SIZE-1:0] rx_fifo_write_data;
    logic [NI_DATA_SIZE-1:0] rx_fifo_read_data;
    logic rx_fifo_full;
    logic rx_fifo_empty;
    
    
    //rx fifo end
    logic [31:0] rx_target;
    logic [31:0] rx_target_ff;
    logic [FLIT_DATA_BITS-1:0] rx_data;
    logic [NI_DATA_SIZE-1:0] rx_data_ff;
    logic [10:0] rx_packet_size;
    logic rx_last_flit;
    logic [1:0] rx_body_count;
    logic [1:0] rx_body_count_ff;
    
    flit_decoder decoder(
        .i_flit(i_flit),
        .o_target(rx_target),
        .o_data_raw(rx_data),
        .o_packet_size(rx_packet_size),
        .o_last_flit(rx_last_flit)
    );
    
    
    flit_encoder _encoder(
        .i_data_raw(tx_to_encode),
        .i_target(tx_idx_ff),
        .i_done(encode_done),
        .o_tx_flit(encoded_flit),
        .i_flit_type(encode_flit_type));
    
    sfifo #(.FIFO_WIDTH(NI_DATA_SIZE), .FIFO_DEPTH($clog2(NUM_OF_FLITS/2)))
    rx_buffer (.clk(clk),
               .rst_n(rst_n),
               .i_fifo_write(rx_fifo_write),
               .i_fifo_read(rx_fifo_read),
               .i_fifo_write_data(rx_fifo_write_data),
               .o_fifo_full(rx_fifo_full),
               .o_fifo_read_data(rx_fifo_read_data),
               .o_fifo_empty(rx_fifo_empty)); 
    
    sfifo #(.FIFO_WIDTH(NI_DATA_SIZE), .FIFO_DEPTH($clog2(NI_MEM_DEPTH/MEM_MAPPED_REGS)))
    tx_buffer (.clk(clk),
               .rst_n(rst_n),
               .i_fifo_write(tx_fifo_write),
               .i_fifo_read(tx_fifo_read),
               .i_fifo_write_data(tx_fifo_write_data),
               .o_fifo_full(tx_fifo_full),
               .o_fifo_read_data(tx_fifo_read_data),
               .o_fifo_empty(tx_fifo_empty));
    
    
    
    always_comb begin
        tx_idx = 0;
        for (int i = 0; i < MEM_MAPPED_REGS; i++) begin
            if(tx_ni_request[i]) 
                tx_idx = i;
        end
    
    end
    
    always_comb begin
        tx_ni_ack = '{default:'0};
        tx_fifo_write = 0;
        tx_fifo_read = 0;
        tx_to_encode = '0;
        tx_router_request = 0;
        tx_fifo_write_data = tx_ni_data[tx_idx].ni_data;
        case(current_tx_status) 
            NI_IDLE : begin
                if(tx_idx >= 0 && tx_ni_request[tx_idx]) begin
                     tx_ni_ack[tx_idx] = 1;
                    next_tx_status = NI_WAITING;
                end 
                else next_tx_status = NI_IDLE;
            end
            
            NI_WAITING : begin
               
                if(tx_ni_data[tx_idx].valid) begin
                    tx_fifo_write = 1;
                    next_tx_status = NI_RECEIVING;
                end
                else begin
                    tx_fifo_write = 0;
                    next_tx_status = NI_WAITING;                    
                end
            end
            NI_RECEIVING : begin 
                 if(tx_ni_data[tx_idx].valid) begin
                    tx_fifo_write = 1;
                    next_tx_status = NI_RECEIVING;
                end
                else begin
                    tx_fifo_write = 0;
                    next_tx_status = NI_REQUESTING;                    
                end
            end
            NI_REQUESTING : begin
                tx_router_request = 1;
                if(tx_router_ack)
                    next_tx_status = NI_SENDING;
               else
                    next_tx_status = NI_REQUESTING;
            end
            NI_SENDING : begin
//                  tx_router_request = 1;
//                  if(tx_router_ack) begin 
                      if(tx_flit_cnt % 4== 0) begin
                        encode_flit_type = HEAD_FLIT;
                        next_tx_status = NI_SENDING;
                      end
                      else if(tx_flit_cnt %4 == 1 ) begin
                        tx_fifo_read = 1;
                        next_tx_status = NI_SENDING;
                        encode_flit_type = BODY_FLIT; 
                        tx_to_encode = {tx_fifo_read_data_ff[31:16],16'b0};
                      end 
                      else if(tx_flit_cnt % 4 == 2) begin 
                        
                        next_tx_status = NI_SENDING;
                        encode_flit_type = BODY_FLIT; 
                        tx_to_encode = {tx_fifo_read_data_ff[15:0],16'b0};
                      end
                      else if(tx_flit_cnt % 4 == 3) begin
                         next_tx_status = NI_REQUESTING;
                         encode_flit_type = TAIL_FLIT; 
                         tx_to_encode = {NODE_IDX[3:0], i_tx_regs_data[tx_idx_ff].data_size[10:0], 1'b0, 16'b0};
                      end
                    
                    if(tx_fifo_empty) begin
                       
                        next_tx_status = NI_DONE; 
                        encode_flit_type = BODY_FLIT; 
                        tx_to_encode =  {tx_fifo_read_data_ff[15:0],16'b0};
                    end
//                end
//                else next_tx_status = NI_SENDING;
            end
           NI_DONE : begin
            tx_router_request = 1;
            encode_flit_type = TAIL_FLIT; 
            tx_to_encode =  {NODE_IDX[3:0], i_tx_regs_data[tx_idx_ff].data_size[10:0], 1'b1, 16'b0};
            next_tx_status = NI_IDLE;
           end
        endcase
        
    end
    
    RX_CNTRL_t rx_reg_data [MEM_MAPPED_REGS-1:0];
    RX_CNTRL_t rx_reg_data_ff [MEM_MAPPED_REGS-1:0];
    always_comb begin 
        next_rx_status = NI_IDLE;
        rx_body_count = '0;
        rx_fifo_read = 0;
        rx_fifo_write = 0;
        rx_fifo_write_data = '0;
        o_rx_ni_request = '{default : '0};
        rx_reg_data = '{default : '0};
        rx_router_ack = 0;
        case(current_rx_status) 
            NI_IDLE: begin
                next_rx_status = NI_IDLE;
                if(rx_router_request) begin
                    rx_router_ack = 1;
                    next_rx_status = NI_RECEIVING;
                end
            end
            NI_RECEIVING : begin
                next_rx_status = NI_RECEIVING;
                if(i_flit.head.valid == 1) begin
                    if(i_flit.head.flit_type == BODY_FLIT) begin
                        rx_body_count = 1;
                        next_rx_status = NI_RECEIVING;
                    end
                    if(rx_body_count_ff == 1) begin
                        //rx_fifo_write = 1;
                        rx_fifo_write_data = rx_data_ff;
                        next_rx_status = NI_RECEIVING;
                        rx_body_count =2 ;
                    end
                    if(i_flit.head.flit_type == TAIL_FLIT) begin
                        next_rx_status = NI_REQUESTING;
                        rx_reg_data[rx_target].data_size = i_flit.tail.data_size;
                        rx_reg_data[rx_target].valid = i_flit.tail.last_packet;
                    end
                end 
                
            end
            NI_REQUESTING : begin
                o_rx_ni_request[rx_target_ff] = 1;
                next_rx_status = NI_REQUESTING;
                if(i_rx_ni_ack[rx_target_ff]) begin
                    next_rx_status = NI_IDLE;
                end
                
            end
            NI_SENDING : begin
            
            end
        endcase
    end
    
    
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            current_rx_status <= NI_IDLE;
            rx_data_ff <= '0;
            rx_body_count_ff <= '0;
            rx_target_ff <= -1;
            rx_reg_data_ff <= '{default : '0};
        end
        else begin
            current_rx_status <= next_rx_status;
            rx_body_count_ff <= rx_body_count;
            if(current_rx_status == NI_IDLE) begin
                rx_target_ff <= -1;
                //rx_reg_data_ff <= '{default : '0};
            end
            else if(current_rx_status == NI_RECEIVING && ( i_flit.head.flit_type == TAIL_FLIT)) begin
                rx_target_ff <= rx_target;
                rx_reg_data_ff <= rx_reg_data;
            end
            else begin 
                rx_target_ff <= rx_target_ff;
                rx_reg_data_ff <= rx_reg_data_ff;
            end
            if(current_rx_status == NI_RECEIVING) begin
               
                if(rx_body_count_ff == 0) begin
                    rx_data_ff[31:16] <= rx_data;
                end
                else if(rx_body_count_ff == 1) rx_data_ff[15:0] <= rx_data;
               
                else rx_data_ff <= rx_data_ff;
            end
            else begin
                rx_data_ff <= rx_data_ff;
            end
        end  
    
    end
    assign o_rx_data = rx_data_ff;
    assign o_rx_reg_data = rx_reg_data_ff;
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            current_tx_status <= NI_IDLE;
            tx_flit_cnt <= '0;
            tx_flit_to_router.head.valid <= 0;
            tx_flit_to_router.head.flit_type <= NONE_FLIT;
            tx_flit_to_router.body.data <= '0;
            tx_fifo_read_data_ff <='0;
            tx_idx_ff <= 0;
        end
        else begin 
            tx_fifo_read_data_ff <= tx_fifo_read_data;
            if(current_tx_status == NI_IDLE) begin
                tx_idx_ff <= tx_idx;
            end
            else tx_idx_ff <= tx_idx_ff;
            if((current_tx_status == NI_SENDING || current_tx_status == NI_DONE) ) begin
                tx_flit_to_router <= encoded_flit;
                tx_flit_cnt <= tx_flit_cnt + 1;
            end
            else begin 
                tx_flit_cnt <= 0;
                tx_flit_to_router.head.valid <= 0;
                tx_flit_to_router.head.flit_type <= NONE_FLIT;
                tx_flit_to_router.body.data <= '0;
            end
            current_tx_status <= next_tx_status;
        end
    end
    
    
endmodule
