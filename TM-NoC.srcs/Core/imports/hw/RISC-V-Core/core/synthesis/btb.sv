
module btb_cntrl
import core::*;

(
  input  wire                   clk,

  // Data Access Interface
  input logic [core::ADDR_WIDTH-1:0] read_addr_i,
  input  core::br_cntrl_bus_t   br_cntrl_i,
  output core::btb_entry_t      entry_o,
  input  bit is_branch_i   
 
);

localparam DH = 1;
localparam BTB_WORDS =  core::BTB_SIZE;

//logic [DLEN-1:0] rf [1 : RF_WORDS-1];
core::btb_entry_t btb [0 : BTB_WORDS-1];
logic wen;
logic rm;
logic [core::ADDR_WIDTH-1:0] i_waddr;
assign i_waddr = br_cntrl_i.i_addr[core::ADDR_WIDTH+1:2];

assign wen = br_cntrl_i.is_taken;
assign rm  = ~wen;

always @(posedge clk) begin
 //     for(int i = 0; i <32; i++) begin
   //     $display("REG %0d\n DATA %0d\n",i,rf[i]);
     // end
    if(is_branch_i & wen) begin
       btb[i_waddr].i_addr <= br_cntrl_i.i_addr;
       btb[i_waddr].target_addr <= br_cntrl_i.branch_target;
     //  $display("PC : %x TARGET : %x\n",br_cntrl_i.i_addr,br_cntrl_i.branch_target);
    end
    else if (rm) 
        btb[i_waddr] <= '0;
  
end

assign #DH entry_o = btb[read_addr_i];



// not needed for alternatives
initial begin
 for (int i=0 ; i<BTB_WORDS; i++) begin
   btb[i] = '0;
 end
end

endmodule
