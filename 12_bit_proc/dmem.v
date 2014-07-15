`timescale 1ns / 1ps
//
// CSE141L Lab 4, Part 1: Execution Unit Datapath
// University of California, San Diego
// 
// Written by Donghwan Jeon, 5/18/2007
// Update by Sat Garcia, 5/8/2008
// Updated by Arash Arfaee 4/30/2010
// Updated by Sat Garcia, 8/19/2011 (5 years... yay!)

// Data Memory Module
//
// parameters:
// 	A_WIDTH: SRAM address width
// 	D_WIDTH: data width

module dmem#(parameter A_WIDTH = 10, D_WIDTH = 16)
(
    input  reset_i,
	input  clk,
	input  read_write_req_i,
	input  write_en_i,
	input  [A_WIDTH-1 : 0] addr_i,
	input  [D_WIDTH-1 : 0] din_i,
	output [D_WIDTH-1 : 0] dout_o,
	output refused_o
);

reg  [2:0] counter;
reg  refused_r;
reg  read_req_r;
reg  read_write_req_r;
wire refused_w;
wire [D_WIDTH-1 : 0] dout_temp;
wire write_control;


assign write_control = read_write_req_i & write_en_i & ~refused_w;
assign refused_o = refused_r & read_write_req_r;
assign refused_w = counter[2] & counter[1] & counter[0];
assign dout_o = (refused_o | ~read_req_r)? {(D_WIDTH){1'b1}} : dout_temp;

dmem_16_1024 mem 
(
	.address(addr_i),
	.clock(clk),
	.data(din_i),
	.wren(write_control),
	.q(dout_temp) 
); 

always@(posedge clk)
begin
	if (reset_i)
		counter <= 3'b0;
	else
		counter <= counter + 1;

	refused_r <= refused_w;
	read_write_req_r <= read_write_req_i;
	read_req_r <= read_write_req_i & ~write_en_i;
end	

endmodule
