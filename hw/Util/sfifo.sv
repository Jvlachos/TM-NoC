module sfifo
#(parameter FIFO_WIDTH=5,
parameter FIFO_DEPTH = 4)
(input logic clk ,
input  logic rst_n,
input  logic i_fifo_write,
input  logic i_fifo_read,
input  logic [FIFO_WIDTH-1:0] i_fifo_write_data,
output logic o_fifo_full,
output logic [FIFO_WIDTH-1:0] o_fifo_read_data,
output logic o_fifo_empty,
output logic [FIFO_DEPTH:0] o_rd_out,
output logic [FIFO_DEPTH:0] o_wr_out);


    logic [FIFO_WIDTH-1:0] mem [(2**FIFO_DEPTH)-1:0];
    logic [FIFO_DEPTH:0] wr_ptr;
    logic [FIFO_DEPTH:0] rd_ptr;

    logic [FIFO_DEPTH:0] wr_ptr_ff ;
    logic [FIFO_DEPTH:0] rd_ptr_ff ;


    
    assign o_rd_out = rd_ptr_ff;
    assign o_wr_out = wr_ptr_ff;

     
  //bonus
//`define BONUS
`ifdef BONUS
    always_ff @( posedge clk , negedge rst_n ) begin
        if(!rst_n)
            o_fifo_empty <= 1;
        else
            o_fifo_empty <= wr_ptr[FIFO_DEPTH:0] == rd_ptr[FIFO_DEPTH:0];

    end


    always_ff @( posedge clk , negedge rst_n ) begin
        if(!rst_n)
            o_fifo_full <=0 ;
        else
            o_fifo_full <=(wr_ptr[FIFO_DEPTH-1:0] == rd_ptr[FIFO_DEPTH-1:0] &
                        wr_ptr[FIFO_DEPTH] != rd_ptr[FIFO_DEPTH]); 

    end
`else
//combinatorial implementation of empty & full signals

assign  o_fifo_empty = (wr_ptr_ff[FIFO_DEPTH:0] == rd_ptr_ff[FIFO_DEPTH:0]);
assign o_fifo_full = (wr_ptr_ff[FIFO_DEPTH-1:0] == rd_ptr_ff[FIFO_DEPTH-1:0] &
                        wr_ptr_ff[FIFO_DEPTH] != rd_ptr_ff[FIFO_DEPTH]); 
`endif
    always_comb begin : incr_rd
        if(~o_fifo_empty & i_fifo_read)
            rd_ptr=rd_ptr_ff+1;
        else
            rd_ptr = rd_ptr_ff;

    end


    always_comb begin : incr_wr
        
        if(~o_fifo_full & i_fifo_write)
            wr_ptr = wr_ptr_ff +1 ;
        else
            wr_ptr = wr_ptr_ff;
        


    end

    always_ff @( posedge clk , negedge rst_n ) begin : read_ff
        if(!rst_n)
            rd_ptr_ff <= 0;
        else if(i_fifo_read)
            rd_ptr_ff <= rd_ptr;
        else
            rd_ptr_ff <= rd_ptr_ff;
        
    end


    always_ff @( posedge clk , negedge rst_n ) begin : write_ff
        if(!rst_n)
            wr_ptr_ff <= 0;
        else if(i_fifo_write)
            wr_ptr_ff <= wr_ptr;
        else
            wr_ptr_ff <= wr_ptr_ff;
        
    end

    always_comb begin : read_mem
        if(~o_fifo_empty & i_fifo_read) begin 
//            $display("Reading from mem[%0d] : 0x%0h\n",rd_ptr_ff[FIFO_DEPTH-1:0],mem[rd_ptr_ff[FIFO_DEPTH-1:0]]);
            o_fifo_read_data = mem[rd_ptr_ff[FIFO_DEPTH-1:0]];
        end
//       else 
//            o_fifo_read_data = {FIFO_WIDTH{1'bx}};
    end

//    always_ff@(posedge clk, negedge rst_n) begin : read_mem
//        if(!rst_n) 
//            o_fifo_read_data <= '0;
//        else if(~o_fifo_empty & i_fifo_read) begin 
//            $display("Reading from mem[%0d] : 0x%0h\n",rd_ptr_ff[FIFO_DEPTH-1:0],mem[rd_ptr_ff[FIFO_DEPTH-1:0]]);
//            o_fifo_read_data <= mem[rd_ptr_ff[FIFO_DEPTH-1:0]];
//        end
//       // else 
//          //  o_fifo_read_data = {FIFO_WIDTH{1'bx}};
//    end


    always_ff @(posedge clk ,negedge rst_n ) begin : write_mem
       
        if(!rst_n)
            mem[wr_ptr_ff[FIFO_DEPTH-1:0]] <= 'x;
        else if(i_fifo_write & ~o_fifo_full) begin
            //$display("Writing at mem[%0d] : 0x%0h ,time %0t\n",wr_ptr_ff[FIFO_DEPTH-1:0],i_fifo_write_data,$time);
            mem[wr_ptr_ff[FIFO_DEPTH-1:0]] <= i_fifo_write_data;
        end
        else if(i_fifo_read & ~o_fifo_empty)
            mem[rd_ptr_ff[FIFO_DEPTH-1:0]] <= {FIFO_WIDTH{1'bx}}; //deq
        else
            mem[wr_ptr_ff[FIFO_DEPTH-1:0]] <= mem[wr_ptr_ff[FIFO_DEPTH-1:0]];
        
    end


endmodule