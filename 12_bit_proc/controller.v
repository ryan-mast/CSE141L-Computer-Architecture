`timescale 1ns / 1ps

// TODO
// 1. Use output reg instead of all these assigns
// 5. Debug

`define LD 12'b100_???_???_??_0
`define STR 12'b100_???_???_??_1
`define ADDI 12'b010_???_???_??_0
`define SUBI 12'b010_???_???_??_1
`define MOV 12'b111_???_???_??_0
`define BITCNT 12'b111_???_???_??_1
`define SCG 12'b101_???_???_??_0
`define SCL 12'b101_???_???_??_1
`define BEQ 12'b011_???_???_??_?
`define JDNE 12'b110_???_???_??_0
`define JINE 12'b110_???_???_??_1
`define HALT 12'b000_???_???_??_?
`define TBD 12'b001_???_???_??_?

module controller#(parameter I_WIDTH = 12, IA_WIDTH = 8)
(

input  [I_WIDTH-1 : 0] instruction_i,
input [IA_WIDTH-1 : 0] inst_addr_i,
input clk,
input [IA_WIDTH-1 : 0] jump_addr_i,
input reset_i,
input instruction_ready_i,
input refused_i,
input equal_i,
input less_i,
input ones_win_i,

input tb_mem_read_i,
output ctrl_mux2_o,

output  ctrl_mux0_o,
output  ctrl_mux1_o,
output  [1:0] ctrl_threeTOonemux0_o,
output  [1:0] ctrl_threeTOonemux1_o,
output  [1:0] ctrl_fourTOonemux0_o,
output  ctrl_deque_o,
output  regfile_write_en_o,
output [IA_WIDTH-1 : 0] restart_addr_o,
output restart_o,
output reset_mem_o,
output read_write_req_mem_o,
output write_en_mem_o,

output state_s substate_o, substate_next_o
); 

// All the next state logic is right here! Handles reset_i signal, and refused_i signal for memory access.
//typedef enum {sFetch, sDecode, sExecute, sMemory, sWriteBack, sInitialize, sHalt} state_s;
state_s substate_r, substate_n;
always_ff @(posedge clk)
	substate_r <= reset_i ? sInitialize : substate_n;
always_comb
	if (reset_i)
		substate_n = sInitialize;
	else
		unique case (substate_r)
			sInitialize:
					if (instruction_ready_i)
						substate_n = sDecode;
					else
						substate_n = sInitialize;
			sFetch:
				if (!refused_i)
					if (instruction_ready_i)
						substate_n = sDecode;
					else
						substate_n = sFetch;
				else
					substate_n = sMemory;
			sDecode:
				unique casez (instruction_i)
					`TBD: substate_n = sFetch;
					`HALT: substate_n = sHalt;
					default: substate_n = sExecute;
				endcase
			sExecute:
				unique casez (instruction_i)
					`LD: substate_n = sMemory;
					`STR: substate_n = sMemory;
					`BEQ:
						begin
							if (equal_i)
								substate_n = sInitialize;
							else
								substate_n = sFetch;
						end
					default: substate_n = sWriteBack;
				endcase
			sMemory:
				if (!refused_i)
					unique casez (instruction_i)
						`LD: substate_n = sWriteBack;
						`STR: substate_n = sFetch;
						default: substate_n = sWriteBack;
					endcase
				else


					substate_n = sMemory;
			sWriteBack:

				if (!refused_i)
					unique casez (instruction_i)
						`JDNE:
							begin
								if (equal_i)
									substate_n = sInitialize;
								else
									substate_n = sFetch;
							end
						`JINE:
							begin
								if (equal_i)
									substate_n = sInitialize;
								else
									substate_n = sFetch;
							end
						default:
							substate_n = sFetch;

					endcase
				else
					substate_n = sMemory;

			sHalt:
				substate_n = sHalt;
			default: substate_n = sFetch;
		endcase
		
reg  ctrl_mux0_r;
reg  ctrl_mux1_r;
reg [1:0]  ctrl_threeTOonemux0_r;
reg [1:0]  ctrl_threeTOonemux1_r;
reg [1:0]  ctrl_fourTOonemux0_r;
reg  ctrl_deque_r;
reg  regfile_write_en_r;
reg [IA_WIDTH-1 : 0] restart_addr_r;
reg restart_r;
reg reset_mem_r;
reg read_write_req_mem_r;
reg write_en_mem_r;

assign substate_o = substate_r;
assign substate_next_o = substate_n;

assign instruction_r = instruction_i;
assign  ctrl_mux0_o = ctrl_mux0_r;
assign  ctrl_mux1_o = ctrl_mux1_r;
assign   ctrl_threeTOonemux0_o = ctrl_threeTOonemux0_r;
assign   ctrl_threeTOonemux1_o = ctrl_threeTOonemux1_r;
assign  ctrl_fourTOonemux0_o = ctrl_fourTOonemux0_r;
assign  ctrl_deque_o = ctrl_deque_r;
assign  regfile_write_en_o = regfile_write_en_r;
assign restart_addr_o = restart_addr_r;
assign restart_o = restart_r;
assign reset_mem_o = reset_mem_r;
assign read_write_req_mem_o = read_write_req_mem_r;
assign write_en_mem_o = write_en_mem_r;


// SUMMARY: Use always_ff for state advancement logic, always_comb for control signal logic based on state
// combinational decode logic, does not need state awareness; control signals will/might
// control signals, create always_ff that has state advancement logic, then in always_comb control certain signals based on the state

	always_comb
		begin
			ctrl_mux2_o = 1'b0;
			ctrl_mux0_r = 1'dx;
			ctrl_mux1_r = 1'dx;
			ctrl_threeTOonemux0_r = 2'dx;
			ctrl_threeTOonemux1_r = 2'dx;
			ctrl_fourTOonemux0_r = 2'dx;
			restart_addr_r = 12'dx; // normal restart will send the fetch unit back to address 0
			
			// Stateful
			ctrl_deque_r = 0; // wait until instruction_ready_o is high, then deque for 1 cycle before dropping it low again and waiting; set high only if state is "begin" state, and instruction_ready_o is high
			regfile_write_en_r = 0; // don't want to accidentally write stuff
			restart_r = 0; // want fetch to work by default
			reset_mem_r = 0; // don't want to clear data memory without good reason
			read_write_req_mem_r = 0; // no need to request a read unnecessarily
			write_en_mem_r = 0; // no need to write unnecessarily
			
			if (reset_i)
				begin
					restart_addr_r = 0;
					restart_r = 1; // restart the fetch unit
					reset_mem_r = 1; // restart the data memory
					// also, restart the state machine to initial "begin" state (where it waits until instruction_ready_o is true before attempting to deque)
				end
			
			// State-aware
			unique case (substate_r)
				sFetch: 
					if (!refused_i)
						ctrl_deque_r = 1;
					else
						ctrl_deque_r = 0;
				sDecode: ctrl_deque_r = 0;
				sExecute:
					unique casez (instruction_i)
						`BEQ:
							begin
								if (equal_i) // if equal, then branch prediction will have failed and a fetch unit restart is needed
									begin
										restart_addr_r = jump_addr_i;
										restart_r = 1; // need state awareness so that this is only high for 1 cycle
									end
							end
						`JDNE:
							begin
								if (equal_i) // if not equal, branch prediction will have failed, and restart will be necessary
									begin
										restart_addr_r = inst_addr_i + 1;
										restart_r = 1;
									end
							end
						`JINE:
							begin
								if (equal_i) // if not equal, branch prediction will have failed, and restart will be necessary
									begin
										restart_addr_r = inst_addr_i + 1;
										restart_r = 1;
									end
							end
						default:
							begin
								restart_r = 0;
							end
					endcase
				sMemory:
					unique casez (instruction_i)
						`LD:
							begin
								read_write_req_mem_r = 1;
								write_en_mem_r = 0;
							end
						`STR:
							begin
								read_write_req_mem_r = 1;
								write_en_mem_r = 1;
							end
						default:
							begin
								read_write_req_mem_r = 0;
								write_en_mem_r = 0;
							end
					endcase
				sWriteBack:
					if (!refused_i)
						unique casez (instruction_i)
							`BITCNT:
								if (ones_win_i)
									regfile_write_en_r = 1;
								else
									regfile_write_en_r = 0;
							`BEQ:
								regfile_write_en_r = 0;
							`STR:
								regfile_write_en_r = 0;
							default:
								regfile_write_en_r = 1;
						endcase
					else
						regfile_write_en_r = 0;
				sHalt: // just the defaults
					begin
						ctrl_mux2_o = 1;
						ctrl_deque_r = 0;
						regfile_write_en_r = 0;
						reset_mem_r = 0;
						read_write_req_mem_r = tb_mem_read_i;
						write_en_mem_r = 0;
					end
				default: ctrl_deque_r = 0; // weird state, shouldn't happen
			endcase

			// Non-State Aware: MUXes
			unique casez (instruction_i)
				// `HALT:
				// `TBD:
				`ADDI:
					begin
						ctrl_mux0_r = 1'bx; //mux that feeds into 4to1 mux
						ctrl_mux1_r = 1'b0; //Mux that feeds into Adder1
						ctrl_fourTOonemux0_r = 2'd1; // selects adder1_o as item to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i 
					end
				`SUBI:
					begin
						ctrl_mux0_r = 1'bx; //mux that feeds into 4to1 mux
						ctrl_mux1_r = 1'b0; //Mux that feeds into Adder1
						ctrl_fourTOonemux0_r = 2'd1; // selects adder1_o as item to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i 
					end
				`BEQ:
					begin
						ctrl_threeTOonemux0_r = 2'd2; // compare to plain output from register
					end
				`LD:
					begin
						ctrl_mux1_r = 1'b0;	// address is a sum of the immediate, and rs (rd0)
						ctrl_fourTOonemux0_r = 2'd2; // selects output from memory as value to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
					end
				`STR:
					begin
						ctrl_mux1_r = 1'b0;	// address is a sum of the immediate, and rs (rd0)
						ctrl_fourTOonemux0_r = 2'd2; // selects output from memory as value to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
					end
				`SCG:
					begin
						ctrl_fourTOonemux0_r = 2'd0; // picks larger/smaller thing to write to it
						ctrl_threeTOonemux0_r = 2'd2; // compare the plain outputs from the registers
						ctrl_threeTOonemux1_r = 2'd2; // pick register 7
						if (less_i) // d0 < d1, then save d1 as larger
							ctrl_mux0_r = 1'd1;
						else
							ctrl_mux0_r = 1'd0;
					end
				`SCL:
					begin
						ctrl_fourTOonemux0_r = 2'd0; // picks larger/smaller thing to write to it
						ctrl_threeTOonemux0_r = 2'd2; // compare the plain outputs from the registers
						ctrl_threeTOonemux1_r = 2'd1; // pick register 6
						if (less_i) // d0 < d1, then save d0 one as smaller
							ctrl_mux0_r = 1'd0;
						else
							ctrl_mux0_r = 1'd1;
					end
				`JDNE:
					begin
						ctrl_mux1_r = 1'b1; // imm or value in rt should be added together, to achieve the increment or decrement
						ctrl_fourTOonemux0_r = 2'd1; // selects output from adder as value to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
						if(instruction_i[5:3] == 3'd2) // if using register, 2, then add 32 to the value in register 0
							ctrl_threeTOonemux0_r = 2'd1; // compare to 32+reg[0]
						else
							ctrl_threeTOonemux0_r = 2'd0; // compare to 32
					end
				`JINE:
					begin
						ctrl_mux1_r = 1'b1; // imm or value in rt should be added together, to achieve the increment or decrement
						ctrl_fourTOonemux0_r = 2'd1; // selects output from adder as value to write to reg file
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
						ctrl_threeTOonemux0_r = 2'd2; // compare to plain output from register, because this is jine
					end
				`MOV:
					begin
						ctrl_fourTOonemux0_r = 2'd3; // selects output from immediate translator as value to write to register
						ctrl_mux1_r = 1'b0; // imm or value in register should be added together
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
					end
				`BITCNT:
					begin
						ctrl_fourTOonemux0_r = 2'd1; // selects output from adder as value to write to reg file
						ctrl_mux1_r = 1'b1;
						ctrl_threeTOonemux1_r = 2'd0; // uses register specified in instruction as wa_i
					end
				default:
					begin

					end
			endcase
		end

endmodule
