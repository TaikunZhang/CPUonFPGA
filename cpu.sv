module cpu
(
input clk,
input reset,

//port1
output [15:0] o_pc_addr,
output o_pc_rd,
input [15:0] i_pc_rddata,

//port2
input [15:0] i_ldst_rddata,
output [15:0] o_ldst_wrdata,
output [15:0] o_ldst_addr,

output o_ldst_rd,
output o_ldst_wr,

//tb-regs
output [7:0][15:0] o_tb_regs
);

//fetch
logic decode_pc_ld;
logic decode_ir_ld;
logic pc_ld;
logic [1:0] pc_addr_sel;
logic flush_w;
logic flush_f;
logic fwd_pc;

//decode
logic [15:0] ir_decode;
logic execute_pc_ld;
logic execute_ir_ld;
logic rf_rx_rd;
logic rf_ry_rd;
logic ry_d_sel;
logic rx_d_sel;

//execute
logic [15:0] ir_execute;
logic [15:0] ir_rf_write;
logic n;
logic z;
logic rfwrite_pc_ld;
logic rfwrite_ir_ld;

logic alu_a_sel;
logic [1:0] alu_b_sel; 
logic alu_ld_n;
logic alu_ld_z;
logic alu_op;
logic alu_A_ld;

logic rfx_wr_ld;
logic rfy_wr_ld;
logic rfx_wr_sel;
logic rfy_wr_sel;

logic ldst_addr_sel;
logic ldst_wrdata_sel;

//rf writeback
logic rf_wr;
logic rf_seven;
logic [2:0] rf_sel;

cpu_control cpu_control0
(
	.clk(clk),
	.reset(reset),


	.o_decode_pc_ld(decode_pc_ld),
	.o_decode_ir_ld(decode_ir_ld),
	.o_pc_ld(pc_ld),
	.o_pc_rd(o_pc_rd),
	.o_pc_addr_sel(pc_addr_sel),
	.o_flush_f(flush_f),
	.o_fwd_pc(fwd_pc),

	.i_ir_decode(ir_decode),
	.o_execute_pc_ld(execute_pc_ld),
	.o_execute_ir_ld(execute_ir_ld),
	.o_rf_rx_rd(rf_rx_rd),
	.o_rf_ry_rd(rf_ry_rd),
	.o_rx_d_sel(rx_d_sel),
	.o_ry_d_sel(ry_d_sel),


	.i_ir_execute(ir_execute),
	.i_ir_rf_write(ir_rf_write),
	.i_n(n),
	.i_z(z),
	.o_rfwrite_pc_ld(rfwrite_pc_ld),
	.o_rfwrite_ir_ld(rfwrite_ir_ld),

	.o_alu_a_sel(alu_a_sel),
	.o_alu_b_sel(alu_b_sel), 
	.o_alu_ld_n(alu_ld_n),
	.o_alu_ld_z(alu_ld_z),
	.o_alu_op(alu_op),
	.o_alu_A_ld(alu_A_ld),

	.o_rfx_wr_ld(rfx_wr_ld),
	.o_rfy_wr_ld(rfy_wr_ld),
	.o_rfx_wr_sel(rfx_wr_sel),
	.o_rfy_wr_sel(rfy_wr_sel),

	.o_ldst_rd(o_ldst_rd),
	.o_ldst_wr(o_ldst_wr),
	.o_ldst_addr_sel(ldst_addr_sel),
	.o_ldst_wrdata_sel(ldst_wrdata_sel),


	.o_rf_wr(rf_wr),
	.o_rf_seven(rf_seven),
	.o_rf_sel(rf_sel),
	.o_flush_w(flush_w)
);

cpu_datapath cpu_datapath0
(
	.clk(clk),
	.reset(reset),

	//port 1
	.i_pc_rddata(i_pc_rddata),
	.o_pc_addr(o_pc_addr),

	//port2
	.i_ldst_rddata(i_ldst_rddata),
	.o_ldst_wrdata(o_ldst_wrdata),
	.o_ldst_addr(o_ldst_addr),

	//fetch
	.i_pc_ld(pc_ld),
	.i_decode_pc_ld(decode_pc_ld),
	.i_decode_ir_ld(decode_ir_ld),
	.i_pc_addr_sel(pc_addr_sel),
	.i_flush_f(flush_f),
	.i_flush_w(flush_w),
	.i_fwd_pc(fwd_pc),

	//decode
	.o_ir_decode(ir_decode),
	.i_execute_pc_ld(execute_pc_ld),
	.i_execute_ir_ld(execute_ir_ld),
	.i_rf_rx_rd(rf_rx_rd),
	.i_rf_ry_rd(rf_ry_rd),
	.i_rx_d_sel(rx_d_sel),
	.i_ry_d_sel(ry_d_sel),

	//execute
	.o_ir_execute(ir_execute),
	.o_ir_rf_write(ir_rf_write),
	.o_n(n),
	.o_z(z),
	.i_rfwrite_pc_ld(rfwrite_pc_ld),
	.i_rfwrite_ir_ld(rfwrite_ir_ld),
	.i_alu_a_sel(alu_a_sel),
	.i_alu_b_sel(alu_b_sel), 
	.i_alu_ld_n(alu_ld_n),
	.i_alu_ld_z(alu_ld_z),
	.i_alu_op(alu_op),
	.i_alu_A_ld(alu_A_ld),

	.i_rfx_wr_ld(rfx_wr_ld),
	.i_rfy_wr_ld(rfy_wr_ld),
	.i_rfx_wr_sel(rfx_wr_sel),
	.i_rfy_wr_sel(rfy_wr_sel),
	
	.i_ldst_addr_sel(ldst_addr_sel),
	.i_ldst_wrdata_sel(ldst_wrdata_sel),

	//rf writeback
	.i_rf_wr(rf_wr),
	.i_rf_seven(rf_seven),
	.i_rf_sel(rf_sel),


	//tb regs
	.o_tb_regs(o_tb_regs)
);
endmodule