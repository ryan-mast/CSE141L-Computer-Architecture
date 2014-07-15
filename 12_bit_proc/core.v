`timescale 1ns / 1ps

// D_WIDTH : data width
module core#(parameter D_WIDTH = 16)
(
input clk,
input reset_i,

// used by tb
input tb_mem_read_i,
input [9:0] tb_addr_i,

// flattened output
output [$bits(debug_packet_s)-1:0] debug_flat_o
);

wire deque, restart, instruction_ready;
wire [7 : 0] instruction_addr, restart_addr;
wire [11 : 0] instruction_data;

// original structure
debug_packet_s debug_s;
assign debug_flat_o = debug_s; // convert struct to flattened struct 

// instantiate and wire up fetch unit to the backend, no control logic needed
fetch Fetch
(
	.clk(clk)
	,.deque_i(deque)
	,.restart_i(restart)
	,.restart_addr_i(restart_addr)
	,.instruction_data_o(instruction_data)
	,.instruction_addr_o(instruction_addr)
	,.instruction_ready_o(instruction_ready)
);

backend Backend
(
	.clk(clk)
	,.reset_i(reset_i)
	,.instruction_data_i(instruction_data)
	,.instruction_addr_i(instruction_addr)
	,.instruction_ready_i(instruction_ready)
	,.deque_o(deque)
	,.restart_o(restart)
	,.restart_addr_o(restart_addr)
	,.debug_o(debug_s)
	,.tb_mem_read_i(tb_mem_read_i)
	,.tb_addr_i(tb_addr_i)
);

endmodule
