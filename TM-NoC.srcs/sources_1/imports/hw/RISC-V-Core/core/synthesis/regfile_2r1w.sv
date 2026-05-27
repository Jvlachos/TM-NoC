module regfile_2r1w #(
  parameter DLEN          = 32,
  parameter ALEN          = 5
) (
  input  wire                   clk,

  // Data Access Interface
  input  logic [ALEN-1:0]       i_raddr_a,
  input  logic [ALEN-1:0]       i_raddr_b,

  input  logic                  i_wen,
  input  logic [ALEN-1:0]       i_waddr,
  input  logic [DLEN-1:0]       i_wdata,

  output logic [DLEN-1:0]       o_rdata_a,
  output logic [DLEN-1:0]       o_rdata_b
);

localparam DH = 1;
localparam RF_WORDS = 1 << ALEN;

//logic [DLEN-1:0] rf [1 : RF_WORDS-1];
logic [DLEN-1:0] rf [0 : RF_WORDS-1];
logic wen;

assign wen = i_wen & ~(i_waddr == 0);

always @(posedge clk) begin
 //     for(int i = 0; i <32; i++) begin
   //     $display("REG %0d\n DATA %0d\n",i,rf[i]);
     // end
      if ( wen ) begin
        assert(i_waddr != '0) else begin
          $display("WRITE TO X0!\n");
          $finish;
        end
       rf[i_waddr] <= i_wdata;
    end
end

assign #DH o_rdata_a = rf[i_raddr_a];
assign #DH o_rdata_b = rf[i_raddr_b];
// alternative #1
//assign #DH o_rdata_a = (i_raddr_a == 0) ? 0 : rf[i_raddr_a];
//assign #DH o_rdata_b = (i_raddr_b == 0) ? 0 : rf[i_raddr_b];
/*
// alternative #2
always_comb begin
  o_rdata_a = 0;
  o_rdata_b = 0;
  if ( i_raddr_a != 0 ) o_rdata_a = rf[i_raddr_a];
  if ( i_raddr_b != 0 ) o_rdata_b = rf[i_raddr_b];


//if      ( i_raddr_a == 0 )            o_rdata_a = 0;
//else if ( i_raddr_a == i_waddr )      o_rdata_a = i_wdata;
//else                                  o_rdata_a = rf[i_raddr_a];
//
//if      ( i_raddr_b == 0 )            o_rdata_b = 0;
//else if ( i_raddr_b == i_waddr )      o_rdata_b = i_wdata;
//else                                  o_rdata_b = rf[i_raddr_b];

end
*/

// not needed for alternatives
initial begin
 for (int i=0 ; i<RF_WORDS; i++) begin
   rf[i] = 0;
 end
end

endmodule
