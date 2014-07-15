`timescale 1ns / 1ps
//
// CSE141L Lab 3
// University of California, San Diego
//
// Written by Donghwan Jeon, 4/10/2007
// Updated by Sat Garcia, 4/8/2008
// Updated by MBT, 4/4/2011
// Updated by Sat Garcia, 8/13/2011

// 4 input Mux
//
// parameters:
// 	WIDTH: data width for inputs and output
//
module fourTOonemux#(parameter WIDTH=16)
(
input [1:0] sel,
input [WIDTH-1:0] i1, 
input [WIDTH-1:0] i2, 
input [WIDTH-1:0] i3, 
input [WIDTH-1:0] i4,
output [WIDTH-1:0]  o1
);

reg [WIDTH-1:0] o1_r;
assign o1 = o1_r;


always_comb
  begin
    
    o1_r = 16'dx;
    
    case (sel)
      2'b00:  o1_r = i1;
      2'b01:  o1_r = i2;
      2'b10:  o1_r = i3;
      2'b11:  o1_r = i4;
    endcase
  end
endmodule