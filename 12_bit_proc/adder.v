`timescale 1ns / 1ps
//
// CSE141L Lab 3
// University of California, San Diego
// 
// Written by Donghwan Jeon, 4/10/2007
// Updated by Sat Garcia, 4/8/2008
// Updated by Michael Taylor, 4/4/2011
// Updated by Sat Garcia, 8/13/2011

// 2 input Adder Module
//
// parameters:
// 	WIDTH: data width for inputs and output
//
module adder#(parameter WIDTH=16)
(
    input signed   [WIDTH-1:0] d0_i,
    input signed   [WIDTH-1:0] d1_i,
    output signed  [WIDTH-1:0] d_o
);

	assign d_o = d0_i + d1_i;

   // fill out; easy!
   // unlike lab2, this shouldn't use a clk or flip flops

endmodule
