`timescale 1ns / 1ps
//
// CSE141L Lab 3: Processor Datapath
//
// Written by Donghwan Jeon, 4/10/2007
// Updated by Sat Garcia, 4/9/2008
// Updated by Michael Taylor, 4/4/2011
// Updated by Sat Garcia, 8/13/2011

// Fetch unit module
//
// parameters:
//      I_WIDTH: instruction width
//      A_WIDTH: instruction ROM address width
//

module fetch#(parameter I_WIDTH = 12, A_WIDTH = 8)
(
    input   clk,

    // inputs from exec unit
    input   deque_i,
    input   restart_i,
    input   [A_WIDTH-1: 0] restart_addr_i,

    // ouputs to the exec unit
    output  [I_WIDTH-1: 0] instruction_data_o,
    output  [A_WIDTH-1: 0] instruction_addr_o,
    output  instruction_ready_o
);

   wire fifo_enque, fifo_clear, fifo_valid, fifo_full, fifo_empty;
   wire [A_WIDTH-1 : 0] imem_addr;
   wire [I_WIDTH-1 : 0] imem_data;
	wire [A_WIDTH-1 : 0] mux1_o;
	wire [1 : 0] sel_mux;
	
	wire [A_WIDTH-1 : 0] adder_o_mux2_i, mux2_o, jump_dest;

   wire [A_WIDTH-1 : 0] pc_next;

   // registers for the data path inputs
   reg [A_WIDTH-1 : 0]  restart_addr_r;

   reg  [A_WIDTH-1 : 0] pc_r;
   
   // control unit instantiation
   fetch_control control
    (
	  .clk(clk)
	  ,.restart_i(restart_i)
	  ,.fifo_full_i(fifo_full)
	  ,.fifo_valid_i(fifo_valid)
	  ,.sel_mux_o(sel_mux)
	  ,.fifo_enque_o(fifo_enque)
	  ,.fifo_clear_r_o(fifo_clear)
	  ,.instruction_ready_o(instruction_ready_o)
);
	
	
   // fifo instantiation
   fifo fetch_fifo
     (
      .clk(clk)
	  ,.inst_addr_i(pc_r)
	  ,.inst_data_i(imem_data)
      ,.deque_i(deque_i)
      ,.clear_i(fifo_clear)
      ,.enque_i(fifo_enque)
	  ,.inst_addr_o(instruction_addr_o)
	  ,.inst_data_o(instruction_data_o)
      ,.empty_o(fifo_empty)
      ,.full_o(fifo_full)
      ,.valid_o(fifo_valid)
      );

		assign pc_next = imem_addr;
		
always_ff @(posedge clk)
begin
	pc_r <= pc_next;
	restart_addr_r <= restart_addr_i;
end
		
		
 adder #(8) adder1
(
    .d0_i(pc_r)
    ,.d1_i(8'b1)
    ,.d_o(adder_o_mux2_i)
);

 mux #(8) mux1
(
       .sel(sel_mux[1]),
       .d0_i(pc_r),
       .d1_i(mux2_o),
      .d_o(mux1_o)
);

 mux #(8) mux0
(
       .sel(sel_mux[0]),
       .d0_i(restart_addr_r),
       .d1_i(mux1_o),
       .d_o(imem_addr)
);

// advanced: add another mux to select between calculated pc, and jump address
// instantiate a jump calculator
mux #(8) mux2
(
	.sel(jump_en)
	,.d0_i(adder_o_mux2_i)
	,.d1_i(jump_dest)
	,.d_o(mux2_o)
);

jump_calc JC
(
	.opcode_i(imem_data[11:9])
	,.jump_code_i(imem_data[2:1])
	,.destination_o(jump_dest)
	,.jump_en_o(jump_en)
);

   // instruction memory (ROM) instantiation
   imem_12_256 rom
     (
      .address(imem_addr)
      ,.clock(clk)
      ,.q(imem_data)             //data_out
      );


   // noble 141L student, complete this file!
	

/*

*/
   
endmodule
