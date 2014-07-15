`timescale 1ns / 1ps

//`define INPUT_FILE "core.tb.in"
`define OUTPUT_FILE "core.tb.out"

//`ifndef INPUT_FILE
//error: INPUT_FILE not defined in testbench
//`endif

`ifndef OUTPUT_FILE
error: OUTPUT_FILE not defined in testbench
`endif

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
`include "C:/Users/eaoliver/Desktop/rapidsvn/Rapidsvn/Data/lab4/trunk/debug.v"

//`ifdef INPUT_FILE
//	`include `INPUT_FILE
//`endif

module core_tb#(parameter I_WIDTH = 12, A_WIDTH = 8);

	// inputs to core
    reg   clk;
    reg   reset_i;

	// inputs to core, used for debugging
	 reg tb_mem_read;
	 reg [9:0] tb_addr;
	 
    // outputs from core, used for debugging
	 debug_packet_s debug_o;
	wire [$bits(debug_packet_s)-1:0] debug_flat_o;
	assign debug_o = debug_flat_o; // converted flattened struct to real struct
	
	instantiated
		core dut
		(
			.clk(clk),
			.reset_i(reset_i),
			.debug_flat_o(debug_flat_o),
			.tb_mem_read_i(tb_mem_read),
			.tb_addr_i(tb_addr)
		);
	
	int ExecutionCycles = 0;
	int DynamicIC = 0;
	int prevFetch = 0;
	
	
   // Toggle the clock every 10 ns

   initial
     begin
        clk = 0;
        forever #7 clk = !clk;
     end

   // Test with a variety of inputs.
   // Introduce new stimulus on the falling clock edge so that values
   // will be on the input wires in plenty of time to be read by
   // registers on the subsequent rising clock edge.
   initial
     begin
        reset_i = 1;
        
        @(negedge clk);
        reset_i = 1;
        
		  @(negedge clk);
        reset_i = 0;
     end // initial begin
	  
	  
	  always @(negedge clk)
		begin
			if ((debug_o.substate_r != sHalt) &&
				((debug_o.substate_r == sFetch) || (debug_o.substate_r == sInitialize)))
				begin
					if (prevFetch == 0)
						begin
							prevFetch = 1;
							DynamicIC++;
						end
				end
			else
				begin
					prevFetch = 0;
				end
				
			if ((reset_i != 1) && (debug_o.substate_r != sHalt))
				begin
					ExecutionCycles++;
				end
			else
				begin
					ExecutionCycles = 0;
					DynamicIC = 0;
				end
			
			$display("IC: %d, CYC: %d\n", DynamicIC, ExecutionCycles); // count instructions
				
			if (debug_o.substate_r == sHalt)
				begin
					tb_mem_read = 1;
					for (i = 0; i < 1024; i++)
					begin
						tb_addr = i;
						@(negedge clk)
							begin
							if (!debug_o.refused)
								begin
									//$display("M[%d] = %h\n",i,debug_o.dmem_out);
								end
							else
								begin
									$display("Refused: ");
									//i = i - 1;
								end
							$display("%d\n", i);
							/*
								if(debug_o.refused)
									begin
									@(negedge clk)
										begin
											tb_addr = i;
										end
									end
								else
									tb_addr = i;
								*/
							end
					end
				end
		end
		
		always @(posedge clk)
		begin
			if (debug_o.substate_r == sHalt)
				begin
					/*if (!debug_o.refused)
						$display("M[%d] = %h\n",i,debug_o.dmem_out);
					else
						begin
							$display("Refused\n");
							i = i - 1;
						end*/
						
				end
		end

endmodule // test_adder