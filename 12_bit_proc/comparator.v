`timescale 1ns / 1ps
module comparator#(parameter D_WIDTH = 16)
(

input signed [D_WIDTH-1 : 0] d0_i, d1_i,

output equal_o, less_o, greater_o
); 

	assign equal_o = (d0_i == d1_i) ? 1 : 0;
	assign less_o = (d0_i < d1_i) ? 1 : 0;
	assign greater_o = (d0_i > d1_i) ? 1 : 0;

endmodule
