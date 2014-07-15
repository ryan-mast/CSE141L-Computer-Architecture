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

module test_dmem#(parameter D_WIDTH = 16, A_WIDTH = 8);

    reg          clk;
    // inputs from exec unit
        reg  reset_i;

	reg  read_write_req_i;
	reg  write_en_i;
	reg  [A_WIDTH-1 : 0] addr_i;
	reg  [D_WIDTH-1 : 0] din_i;
	
	wire [D_WIDTH-1 : 0] dout_o;
	wire refused_o;

   // The design under test is our adder
   dmem dataMemory
    (
	        .reset_i(reset_i),
	  .clk(clk),
	  .read_write_req_i(read_write_req_i),
	  .write_en_i(write_en_i),
	   .addr_i(addr_i),
	  .din_i(din_i),
	//output
	  .dout_o(dout_o),
	 .refused_o(refused_o)
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
   
   // Read opeartion  
  //read_write_req_i <= 1, write_en_i <= 0 
  
  //Write operation
  //read_write_req_i <= 1, write_en_i <= 1, din_i <= 16-bit data to write 


   initial
     begin
        reset_i = 1;
        read_write_req_i = 0;
        write_en_i = 0;
        addr_i = 8'd0;
        din_i = 16'd0;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 1;
        addr_i = 8'd0;
        din_i = 16'd0;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 1;
        addr_i = 8'd1;
        din_i = 16'd1;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 1;
        addr_i = 8'd2;
        din_i = 16'd2;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 0;
        addr_i = 8'd0;
        din_i = 16'd0;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 0;
        addr_i = 8'd1;
        din_i = 16'd0;
        
        @(negedge clk);
        reset_i = 0;
        read_write_req_i = 1;
        write_en_i = 0;
        addr_i = 8'd2;
        din_i = 16'd0;
        
     end // initial begin

endmodule // test_adder
