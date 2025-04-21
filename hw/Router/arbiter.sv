`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 04:08:13 AM
// Design Name: 
// Module Name: arbiter
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


module arbiter(
    input clk,
    input rst_n,
    input logic [4:0] req,
    output logic [4:0] grant
    );
    logic [2:0] pointer_req, next_pointer_req;
  
  always @(posedge clk,negedge rst_n) begin
    if (~rst_n) pointer_req <= '0;
    else     pointer_req <= next_pointer_req;
    
  end
  
  always_comb begin
    next_pointer_req = 3'b000;
    case (grant)
      5'b00001: next_pointer_req =  3'b001 ;
      5'b00010: next_pointer_req =  3'b010 ;
      5'b00100: next_pointer_req =  3'b011 ;
      5'b01000: next_pointer_req =  3'b100 ;
      5'b10000: next_pointer_req =  3'b000 ;
    endcase
  end 
    
    always_comb begin
	case (pointer_req)
		3'b000 :
			if (req[0]) grant = 5'b00001;
			else if (req[1]) grant = 5'b00010;
			else if (req[2]) grant = 5'b00100;
			else if (req[3]) grant = 5'b01000;
			else if (req[4]) grant = 5'b10000;
			else grant = 5'b00000;
		3'b001 :
			if (req[1]) grant = 5'b00010;
			else if (req[2]) grant = 5'b00100;
			else if (req[3]) grant = 5'b01000;
			else if (req[4]) grant = 5'b10000;
			else if (req[0]) grant = 5'b00001;
			else grant = 5'b00000;
        3'b010 :
			if (req[2]) grant = 5'b00100;
			else if (req[3]) grant = 5'b01000;
			else if (req[4]) grant = 5'b10000;
			else if (req[0]) grant = 5'b00001;
			else if (req[1]) grant = 5'b00010;
			else grant = 5'b00000;
		3'b011 :
			if (req[3]) grant = 5'b01000;
			else if (req[4]) grant = 5'b10000;
			else if (req[0]) grant = 5'b00001;
			else if (req[1]) grant = 5'b00010;
			else if (req[2]) grant = 5'b00100;
			else grant = 5'b00000;
	   3'b100 :
			if (req[4]) grant = 5'b10000;			
			else if (req[0]) grant = 5'b00001;
			else if (req[1]) grant = 5'b00010;
			else if (req[2]) grant = 5'b00100;
			else if (req[3]) grant = 5'b01000;
			else grant = 5'b00000;
	endcase // case(req)
end
endmodule
