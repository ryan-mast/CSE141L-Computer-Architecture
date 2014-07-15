`timescale 1ns / 1ps

/*
 * CSE141L Lab1: Tools of the Trade
 * University of California, San Diego
 * 
 * Written by Matt DeVuyst, 3/30/2010
 * Modified by Vikram Bhatt, 30/3/2010
 */

//
// NOTE: This verilog is non-synthesizable.
// You can only use constructs like "initial", "#10", "forever"
// inside your test bench! Do not use it in your actual design.
//

module test_fetch#(parameter I_WIDTH = 12, A_WIDTH = 8);

    reg          clk;
    // inputs from exec unit
    reg   deque_i;
    reg   restart_i;
    reg   [A_WIDTH-1: 0] restart_addr_i;

    // ouputs to the exec unit
    wire  [I_WIDTH-1: 0] instruction_data_o;
    wire  [A_WIDTH-1: 0] instruction_addr_o;
    wire  instruction_ready_o;

   // The design under test is our adder
   fetch fetch1
    (
	  .clk(clk),
    // inputs from exec unit
    .deque_i(deque_i),
    .restart_i(restart_i),
    .restart_addr_i(restart_addr_i),
    // ouputs to the exec unit
    .instruction_data_o(instruction_data_o),
    .instruction_addr_o(instruction_addr_o),
    .instruction_ready_o(instruction_ready_o)
);

   // Toggle the clock every 10 ns

   initial
     begin
        clk = 0;
        forever #10 clk = !clk;
     end

   // Test with a variety of inputs.
   // Introduce new stimulus on the falling clock edge so that values
   // will be on the input wires in plenty of time to be read by
   // registers on the subsequent rising clock edge.
   initial
     begin
		deque_i = 0;
		restart_i = 1;
        restart_addr_i = 8'b0;
        @(negedge clk);
		
        restart_i = 0;
		deque_i = 1;
        @(negedge clk);
        
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
     end // initial begin

endmodule // test_adder
