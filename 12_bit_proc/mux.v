`timescale 1ns / 1ps
//
// CSE141L Lab 3
// University of California, San Diego
//
// Written by Donghwan Jeon, 4/10/2007
// Updated by Sat Garcia, 4/8/2008
// Updated by MBT, 4/4/2011
// Updated by Sat Garcia, 8/13/2011

// 2 input Mux
//
// parameters:
// 	WIDTH: data width for inputs and output
//
module mux#(parameter WIDTH=16)
(
    input    sel,
    input    [WIDTH-1:0] d0_i,
    input    [WIDTH-1:0] d1_i,
    output   [WIDTH-1:0] d_o
);

// fill out.
// if sel == 0, dout = d0_i, otherwise, d_o = d1_i
assign d_o = (sel) ? d1_i : d0_i;

		
endmodule
