`timescale 1ns / 1ps
/*
 * CSE141L Lab 2: Tools of the Trade
 * Part 4: Register File
 * 
 * Ryan Mast, 16/8/2011
 */

module register_file#(parameter W = 16, N = 8)
(
 input clk,
 input wen_i,
 input [$clog2(N)-1:0] wa_i,
 input [W-1:0] wd_i,
 input [$clog2(N)-1:0] ra0_i, ra1_i,
 output reg [W-1:0] rd0_o,
 output [W-1:0] rd1_o, rd2_o,
 
 output [W-1:0] rf_o[N-1:0]
);
	
	reg [W-1:0] rf[N-1:0];
	
	assign rf_o = rf;
	
	// allow reading at any time, and allow it to happen simultaneously
	//assign rd0_o = rf[ra0_i];
	assign rd1_o = rf[ra1_i];
	assign rd2_o = rf[0];
	
	always_comb
		begin
			// if rs = 0, then value is 0
			rd0_o = rf[ra0_i];
			
			if (ra0_i == 0)
				rd0_o = 16'd0;
		end
	
   always_ff @(posedge clk) //enable SystemVerilog to make always_ff work!
     begin
	     // only write the data to the register file if wen_i is high, and on the posedge of the clk
		  if (wen_i)
			 rf[wa_i] <= wd_i;
     end

endmodule
 