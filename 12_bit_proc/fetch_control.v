`timescale 1ns / 1ps
//
// CSE141L Lab 3: Processor Datapath
// University of California, San Diego
// 
// Written by Sat Garcia, 8/13/2011

// Instruction Fetch Control Module


module fetch_control
(
	input  clk,
	input  restart_i,
	input  fifo_full_i,
	input  fifo_valid_i,
	output [1 : 0] sel_mux_o,
	output fifo_enque_o,
	output reg fifo_clear_r_o,
	output instruction_ready_o
);

reg  restart_r;

assign sel_mux_o[0] = ~restart_r;
assign sel_mux_o[1] = ~fifo_full_i;
assign fifo_enque_o = ~restart_r & ~fifo_full_i;
assign instruction_ready_o = fifo_valid_i;

always_ff @(posedge clk)
begin
	restart_r <= restart_i;
	fifo_clear_r_o <= restart_i;
end

endmodule
