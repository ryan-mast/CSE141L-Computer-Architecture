`timescale 1ns / 1ps

module imm_calc
(
input [2 : 0] opcode_i,
input funct_i,
input [1 : 0] imm_code_i,
output reg signed [15 : 0] imm_o
); 

	

	always_comb
		begin
			// addi - opcode = 2, func = 0, imm(01) = 30 else 31 (code only uses 31)
			// subi - opcode = 2, func = 1, imm = -1
			// ld - opcode 4, func = 0, imm(11) = 4, imm(10) = 2, else 0
			// str - opcode 4, func = 1, imm(11) = 4, imm(10) = 2, else 0
			// jdne - opcode 6, func = 0, comp to 32 if rt == 0, otherwise comp to 32+r0 if rt == 2
			// jine - opcode 6, func = 1, comp registers, imm doesn't matter
			// mov - opcode 7, func = 0, imm => imm000 - 1, imm(000001) = 1, imm(0) = 0, else 127
			// bitcnt - opcode 7, func = 1, imm = 1 (+1)
			imm_o = 16'd0;
			// addi, subi
			if (opcode_i == 3'd2)
				begin
					if (funct_i == 1'd0)
						begin
							case(imm_code_i)
								2'd1 : imm_o = 16'd30;
								default: imm_o = 16'd31;
							endcase
						end
					else if (funct_i == 1'd1)
						begin
							imm_o = 16'hFFFF; // -1, output is signed
						end
					else
						imm_o = 16'dx;
				end
			// ld, str
			else if (opcode_i == 3'd4)
				begin
					case(imm_code_i)
						2'd3 : imm_o = 16'd4; // used for reading in address 4 (bubblesort.s)
						2'd2 : imm_o = 16'd2; // used for saving in address 2 (bitcount.s)
						default : imm_o = 16'd0; // all other cases
					endcase
				end
			// jdne, jine
			else if (opcode_i == 3'd6)
				begin
					if (funct_i == 1'b0)
						imm_o = 16'hFFFF;
					else
						imm_o = 16'b1;
				end
			// mov, bitcnt
			else if (opcode_i == 3'd7)
				begin
					if (funct_i == 1'd0)
						begin
							case(imm_code_i)
								2'd0 : imm_o = 16'd0; // mov 0 (bitcount.s)
								2'd1 : imm_o = 16'd1; // mov 0x8 *cough* 1 (bubblesort.s)
								default : imm_o = 16'd127; // for mov 0x80, end address (bitcount.s)
							endcase
						end
					else if (funct_i == 1'd1)
						imm_o = 16'd1; // bitcnt only uses +1
				end
			else
				begin
					imm_o = 16'bx;
				end
		end

endmodule
