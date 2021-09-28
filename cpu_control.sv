module cpu_control
(
input clk,
input reset,

//fetch
output logic o_decode_pc_ld,
output logic o_decode_ir_ld,
output logic o_pc_ld,
output logic o_pc_rd,
output logic [1:0]o_pc_addr_sel,
output logic o_flush_f,
output logic o_fwd_pc,

//decode
input [15:0] i_ir_decode,
output logic o_execute_pc_ld,
output logic o_execute_ir_ld,
output logic o_rf_rx_rd,
output logic o_rf_ry_rd,
output logic o_rx_d_sel,
output logic o_ry_d_sel,

//execute
input [15:0] i_ir_execute,
input [15:0] i_ir_rf_write,
input i_n,
input i_z,
output logic o_rfwrite_pc_ld,
output logic o_rfwrite_ir_ld,

output logic o_alu_a_sel,
output logic [1:0]o_alu_b_sel, 
output logic o_alu_ld_n,
output logic o_alu_ld_z,
output logic o_alu_op,
output logic o_alu_A_ld,

output logic o_rfx_wr_ld,
output logic o_rfy_wr_ld,
output logic o_rfx_wr_sel,
output logic o_rfy_wr_sel,


output o_ldst_rd,
output o_ldst_wr,
output logic o_ldst_addr_sel,
output logic o_ldst_wrdata_sel,

//rf writeback
output logic o_rf_wr,
output logic o_rf_seven,
output logic [2:0] o_rf_sel,
output logic o_flush_w
);


//fetch
//gets instruction from memory using pc address
cpu_fetch cpu_fetch0
(
	.instr_x(i_ir_execute),
	.instr_w(i_ir_rf_write),
	.n(i_n),
	.z(i_z),
	
	.pc_ld(o_pc_ld),
	.decode_pc_ld(o_decode_pc_ld),
	.decode_ir_ld(o_decode_ir_ld),
	.pc_rd(o_pc_rd),
	.pc_addr_sel(o_pc_addr_sel),
	.flush_f(o_flush_f),
	.fwd_pc(o_fwd_pc)
);

//decode
cpu_decode cpu_decode0
(

	.instr_d(i_ir_decode),
	.instr_x(i_ir_execute),
	.instr_w(i_ir_rf_write),

	.execute_pc_ld(o_execute_pc_ld),
	.execute_ir_ld(o_execute_ir_ld),
	.rf_rx_rd(o_rf_rx_rd),
	.rf_ry_rd(o_rf_ry_rd),
	.rx_sel(o_rx_d_sel),
	.ry_sel(o_ry_d_sel)

);

//execute
cpu_execute cpu_execute0
(

	.instr_x(i_ir_execute),
	.instr_rfw(i_ir_rf_write),
	.n(i_n),
	.z(i_z),
	
	.rfwrite_pc_ld(o_rfwrite_pc_ld),
	.rfwrite_ir_ld(o_rfwrite_ir_ld),
	
	.alu_a_sel(o_alu_a_sel),
	.alu_b_sel(o_alu_b_sel),
	.alu_ld_n(o_alu_ld_n),
	.alu_ld_z(o_alu_ld_z),
	.alu_op(o_alu_op),
	.alu_A_ld(o_alu_A_ld),
	
	.rfx_wr_ld(o_rfx_wr_ld),
	.rfy_wr_ld(o_rfy_wr_ld),
	.rfx_wr_sel(o_rfx_wr_sel),
	.rfy_wr_sel(o_rfy_wr_sel),


	.ldst_rd(o_ldst_rd),
	.ldst_wr(o_ldst_wr),
	.ldst_addr_sel(o_ldst_addr_sel),
	.ldst_wrdata_sel(o_ldst_wrdata_sel)
	
);

//register file writeback

cpu_rfwrite cpu_rfwrite0
(
	.instr(i_ir_rf_write),
	.n(i_n),
	.z(i_z),

	.rf_wr(o_rf_wr),
	.rf_seven(o_rf_seven),
	.rf_sel(o_rf_sel),
	.flush_w(o_flush_w)

);


endmodule