typedef enum {sFetch, sDecode, sExecute, sMemory, sWriteBack, sInitialize, sHalt} state_s;

typedef struct packed {
// backend source
logic reset_i;
logic [11:0] instr_data;
logic [7:0] instr_addr;
logic	instr_ready;
logic deque;
logic restart;
logic [7:0] restart_addr;
logic [15:0] imm;
logic [15:0] adder1;
logic [15:0] dmem_out;
logic [7:0] destination;
logic refused;
logic equal;
logic less;
logic ones_win;
logic ctrl_mux0;
logic ctrl_mux1;
logic [1:0] ctrl_threeTOonemux0;
logic [1:0] ctrl_threeTOonemux1;
logic [1:0] ctrl_fourTOonemux0;
logic reset_mem;
logic read_write_req_mem;
logic write_en_mem;
logic [15:0] reg_port0;
logic [15:0] reg_port1;
logic [15:0] reg_port2;
logic regfile_write_en;

// register file source
logic [15:0] rf0;
logic [15:0] rf1;
logic [15:0] rf2;
logic [15:0] rf3;
logic [15:0] rf4;
logic [15:0] rf5;
logic [15:0] rf6;
logic [15:0] rf7;

// controller source
state_s substate_r;
state_s substate_n;
} debug_packet_s; 