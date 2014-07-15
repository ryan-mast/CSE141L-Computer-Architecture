`timescale 1ns / 1ps
//
// CSE141L Lab 3: FIFO
// University of California, San Diego
// 
// Written by Michael Taylor, May 1, 2010
// Modified by: Sat Garcia, Aug 18, 2011
//
//
// parameters:
// 	I_WIDTH: instruction width
// 	A_WIDTH: SRAM address width
//  LG_DEPTH: lg (number of elements)
//


module fifo#(parameter I_WIDTH=12, A_WIDTH=8, LG_DEPTH=2)
(
	input clk,
	input [A_WIDTH-1 : 0] inst_addr_i,
	input [I_WIDTH-1 : 0] inst_data_i,
	input enque_i, 
	input deque_i,	
	input clear_i,
	output [A_WIDTH-1 : 0] inst_addr_o,
	output [I_WIDTH-1 : 0] inst_data_o,
	output empty_o,
	output full_o,
	output valid_o
);

   // some storage
   reg [A_WIDTH-1:0] storage_addr [(2**LG_DEPTH)-1:0];
   reg [I_WIDTH-1:0] storage_data [(2**LG_DEPTH)-1:0];
   
   // one read pointer, one write pointer;
   reg [LG_DEPTH-1:0] rptr_r, wptr_r;

   reg 		      error_r; // lights up if the fifo was used incorrectly

   assign full_o = ((wptr_r + 1'b1) == rptr_r);
   assign empty_o = (wptr_r == rptr_r);
   assign valid_o = !empty_o;
   
   assign inst_addr_o = storage_addr[rptr_r];
   assign inst_data_o = storage_data[rptr_r];
   
   always_ff @(posedge clk)
     if (enque_i)
	 begin
	   storage_addr[wptr_r] <= inst_addr_i;
	   storage_data[wptr_r] <= inst_data_i;
	 end
   
   always_ff @(posedge clk)
     begin
	if (clear_i)
	  begin
	     rptr_r <= 0;
	     wptr_r <= 0;
	     error_r <= 1'b0;
	  end
	else
	  begin
		  if (rptr_r != wptr_r)
			rptr_r <= rptr_r + deque_i;
	     wptr_r <= wptr_r + enque_i;
	     
	     // synthesis translate off
	     
	     if (full_o & enque_i)
	       $display("error: wrote full fifo");
	     if (empty_o & deque_i)
	       $display("error: deque empty fifo");			
	     
	     // synthesis translate on				
	     
	     error_r  <= error_r | (full_o & enque_i) | (empty_o & deque_i);
	  end 
     end
   
endmodule
