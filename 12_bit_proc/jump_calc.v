`timescale 1ns / 1ps

module jump_calc#(parameter IA_WIDTH = 8)
(
input [2 : 0] opcode_i,
input [1 : 0] jump_code_i,
output [IA_WIDTH-1 : 0] destination_o,
output jump_en_o
); 

	reg [IA_WIDTH-1 : 0] destination_r;
	reg jump_en_r;
	assign destination_o = destination_r;
	assign jump_en_o = jump_en_r;
	always_comb
		begin
			//jump_code = instruction_i[I_WIDTH-10 : I_WIDTH-11];
			//opcode = instruction_i[I_WIDTH-1 : I_WIDTH-4];
			// jdne or jine - opcode = 6
			if (opcode_i == 3'd6)
				begin
					jump_en_r = 1'd1;
					case(jump_code_i)
						2'd1 : destination_r = 8'd2;
						2'd2 : destination_r = 8'd5;
						2'd3 : destination_r = 8'd2;
						default: 
							begin
								destination_r = 8'bx;
								jump_en_r = 1'd0;
							end
					endcase
				end
			// beq - opcode = 3
			else if (opcode_i == 3'd3)
				begin
					destination_r = 8'd14; // jump to address 14
					jump_en_r = 1'd0;
				end
			// default, don't care, not a jump
			else
				begin
					destination_r = 8'bx;
					jump_en_r = 1'd0;
				end
		end

endmodule
