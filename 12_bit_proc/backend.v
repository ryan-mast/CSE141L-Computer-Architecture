`timescale 1ns / 1ps

// I_WIDTH : instruction width
// IA_WIDTH : instruction address width
// D_WIDTH : data width
module backend#(parameter I_WIDTH = 12, IA_WIDTH = 8, D_WIDTH = 16)
(
input clk,
input reset_i,

// inputs from the fetch unit
input [I_WIDTH-1 : 0] instruction_data_i,
input [IA_WIDTH-1 : 0] instruction_addr_i,
input instruction_ready_i,

// used for testbench
input tb_mem_read_i,
input [9:0] tb_addr_i,

// outputs to the fetch unit
output deque_o,
output restart_o,
output [IA_WIDTH-1 : 0] restart_addr_o,

output debug_packet_s debug_o
);

// implement backend using structural verilog, no need to implement control yet; draw datapath schematic first

wire [1:0] ctrl_threeTOonemux0_o;
wire [1:0] ctrl_threeTOonemux1_o;
wire [1:0] ctrl_fourTOonemux0_o;

//mux0 wires 
wire [D_WIDTH-1 : 0] reg_port0_o;
wire [D_WIDTH-1 : 0] reg_port1_o;
wire [D_WIDTH-1 : 0] mux0_o;

//mux 1 wires
wire [D_WIDTH-1 : 0] mux1_o;

// used for tb
wire [D_WIDTH-1 : 0] mux2_o;

//3to1mux wires
wire [D_WIDTH-1 : 0] adder0_o;
wire [D_WIDTH-1 : 0] threeTOonemux0_o;

wire [2 : 0] threeTOonemux1_o;

//4to1mux wires
wire [D_WIDTH-1 : 0] adder1_o;
wire [D_WIDTH-1 : 0] dout_o;
wire [D_WIDTH-1 : 0] imm_o;
wire [D_WIDTH-1 : 0] fourTOonemux0_o;

//regport wire
wire [D_WIDTH-1 : 0] reg_port2_o;

wire [7 : 0] destination_o;

wire [15:0] rf[7:0];

// debug struct to help with debugging the timing simulation
assign debug_o.reset_i = reset_i;
assign debug_o.instr_data = instruction_data_i;
assign debug_o.instr_addr = instruction_addr_i;
assign debug_o.instr_ready = instruction_ready_i;
assign debug_o.deque = deque_o;
assign debug_o.restart = restart_o;
assign debug_o.restart_addr = restart_addr_o;
assign debug_o.imm = imm_o;
assign debug_o.adder1 = adder1_o;
assign debug_o.dmem_out = dout_o;
assign debug_o.destination = destination_o;
assign debug_o.refused = refused_o;
assign debug_o.equal = equal_o;
assign debug_o.less = less_o;
assign debug_o.ones_win = ones_win_o;
assign debug_o.ctrl_mux0 = ctrl_mux0_o;
assign debug_o.ctrl_mux1 = ctrl_mux1_o;
assign debug_o.ctrl_threeTOonemux0 = ctrl_threeTOonemux0_o;
assign debug_o.ctrl_threeTOonemux1 = ctrl_threeTOonemux1_o;
assign debug_o.ctrl_fourTOonemux0 = ctrl_fourTOonemux0_o;
assign debug_o.reset_mem = reset_mem_i;
assign debug_o.read_write_req_mem = read_write_req_mem_i;
assign debug_o.write_en_mem = write_en_mem_i;
assign debug_o.reg_port0 = reg_port0_o;
assign debug_o.reg_port1 = reg_port1_o;
assign debug_o.reg_port2 = reg_port2_o;
assign debug_o.regfile_write_en = regfile_write_en_o;
assign debug_o.rf0 = rf[0];
assign debug_o.rf1 = rf[1];
assign debug_o.rf2 = rf[2];
assign debug_o.rf3 = rf[3];
assign debug_o.rf4 = rf[4];
assign debug_o.rf5 = rf[5];
assign debug_o.rf6 = rf[6];
assign debug_o.rf7 = rf[7];

 controller control
(
	.clk(clk),
	.instruction_i(instruction_data_i),
	.inst_addr_i(instruction_addr_i),
	.jump_addr_i(destination_o),
	.reset_i(reset_i),
	.instruction_ready_i(instruction_ready_i),
	.refused_i(refused_o),
	.equal_i(equal_o),
	.less_i(less_o),
	.ones_win_i(ones_win_o),
	
	.tb_mem_read_i(tb_mem_read_i),
	.ctrl_mux2_o(ctrl_mux2_o),
	
	.ctrl_mux0_o(ctrl_mux0_o),
	.ctrl_mux1_o(ctrl_mux1_o),
	.ctrl_threeTOonemux0_o(ctrl_threeTOonemux0_o),
	.ctrl_threeTOonemux1_o(ctrl_threeTOonemux1_o),
	.ctrl_fourTOonemux0_o(ctrl_fourTOonemux0_o),
	.ctrl_deque_o(deque_o),
	.regfile_write_en_o(regfile_write_en_o),
	.restart_addr_o(restart_addr_o),
	.restart_o(restart_o),
	.reset_mem_o(reset_mem_i),
	.read_write_req_mem_o(read_write_req_mem_i),
	.write_en_mem_o(write_en_mem_i),
	.substate_o(debug_o.substate_r),
	.substate_next_o(debug_o.substate_n)
); 

//2 2to1 muxes
//mux to 4to1mux
mux mux0(
	.sel(ctrl_mux0_o)
	,.d0_i(reg_port0_o)
	,.d1_i(reg_port1_o)
	,.d_o(mux0_o)
);

//mux to adder1
mux mux1(
	.sel(ctrl_mux1_o)
	,.d0_i(reg_port0_o)
	,.d1_i(reg_port1_o)
	,.d_o(mux1_o)
);

// mux used for testbench
mux mux2(
	.sel(ctrl_mux2_o)
	,.d0_i(adder1_o)
	,.d1_i(tb_addr_i)
	,.d_o(mux2_o)
);

//2 3to1 muxes
//Mux into Comparator


threeTOonemux #(16) threeTOonemux0(
	.sel(ctrl_threeTOonemux0_o)
	,.i1(16'd32)
	,.i2(adder0_o)
	,.i3(reg_port0_o)
	,.o1(threeTOonemux0_o)
);

//Mux into Register File
threeTOonemux #(3) threeTOonemux1(
	.sel(ctrl_threeTOonemux1_o)
	,.i1(instruction_data_i[8:6])
	,.i2(3'd6)
	,.i3(3'd7)
	,.o1(threeTOonemux1_o)
);

//1 4to1 mux



fourTOonemux fourTOonemux0(
	.sel(ctrl_fourTOonemux0_o)
	,.i1(mux0_o)
	,.i2(adder1_o)
	,.i3(dout_o)
	,.i4(imm_o)
	,.o1(fourTOonemux0_o)
);

//2 adders



 adder #(16) adder0
(
    .d1_i(reg_port2_o)
    ,.d0_i(16'd32)
    ,.d_o(adder0_o)
);

 adder #(16) adder1
(
    .d0_i(mux1_o)
    ,.d1_i(imm_o)
    ,.d_o(adder1_o)
);





//Data memory
dmem dataMemory(
	.reset_i(reset_mem_i), // control
	.clk(clk),
	.read_write_req_i(read_write_req_mem_i), // control
	.write_en_i(write_en_mem_i), // control
	.addr_i(mux2_o),
	.din_i(reg_port1_o),
	.dout_o(dout_o),
	.refused_o(refused_o)

);

//bit count module
//does the input have more ones than zeros?
bitcount bitcount(
	.d_i(reg_port0_o),
	.ones_win_o(ones_win_o)

);

//compares inputs, 3 different outputs
//lessthan, greaterthan, or equal
comparator comparator(
	.d0_i(threeTOonemux0_o),
	.d1_i(reg_port1_o),
	.equal_o(equal_o),
	.less_o(less_o), 
	.greater_o(greater_o)
);

//extend immediate values because we don't have
//enough bits.
imm_calc imm_trans(
	.opcode_i(instruction_data_i[11:9]),
	.funct_i(instruction_data_i[0]),
	.imm_code_i(instruction_data_i[2:1]),
	.imm_o(imm_o)
);

jump_calc jump_calc(
	.opcode_i(instruction_data_i[11:9]),
	.jump_code_i(instruction_data_i[2:1]),
	.destination_o(destination_o),
	.jump_en_o(jump_en_o)
);

//The registers.
register_file reg_file(

	.clk(clk),
	.wen_i(regfile_write_en_o),
	.wa_i(threeTOonemux1_o),
	.wd_i(fourTOonemux0_o),
	.ra0_i(instruction_data_i[5:3]), 
	.ra1_i(instruction_data_i[8:6]),
	.rd0_o(reg_port0_o), 
	.rd1_o(reg_port1_o),
	.rd2_o(reg_port2_o),
	.rf_o(rf)
);

endmodule
