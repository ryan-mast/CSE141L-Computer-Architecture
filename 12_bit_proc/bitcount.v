`timescale 1ns / 1ps

module bitcount#(parameter D_WIDTH = 16)
(

input [D_WIDTH-1 : 0] d_i,

output ones_win_o
); 

reg [D_WIDTH-1 : 0] v_r, c_r;
reg ones_win_r;

assign ones_win_o = ones_win_r;

	always_comb
		begin
			v_r = d_i;
			c_r = (v_r - ((v_r >> 1) & 16'h5555));
			c_r = (((c_r >> 2) & 16'h3333) + (c_r & 16'h3333));
			c_r = (((c_r >> 4) + c_r) & 16'h0F0F);
			c_r = (((c_r >> 8) + c_r) & 16'h00FF);
			
			if (c_r > 8)
				ones_win_r = 1'b1;
			else
				ones_win_r = 1'b0;
		end

endmodule
