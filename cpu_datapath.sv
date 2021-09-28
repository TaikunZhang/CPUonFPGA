module cpu_datapath
(
input clk,
input reset,

//port 1
input [15:0] i_pc_rddata,
output logic [15:0] o_pc_addr,

//port2
input [15:0] i_ldst_rddata,
output logic [15:0] o_ldst_wrdata,
output logic [15:0] o_ldst_addr,

//fetch
input i_pc_ld,
input i_decode_pc_ld,
input i_decode_ir_ld,
input [1:0]i_pc_addr_sel,
input i_flush_w,
input i_flush_f,
input i_fwd_pc,


//decode
output [15:0] o_ir_decode,
input i_execute_pc_ld,
input i_execute_ir_ld,
input i_rf_rx_rd,
input i_rf_ry_rd,
input i_rx_d_sel,
input i_ry_d_sel,

//execute
output [15:0] o_ir_execute,
output [15:0] o_ir_rf_write,
output logic o_n,
output logic o_z,
input i_rfwrite_pc_ld,
input i_rfwrite_ir_ld,
input i_alu_a_sel,
input [1:0]i_alu_b_sel, 
input i_alu_ld_n,
input i_alu_ld_z,
input i_alu_op,
input i_alu_A_ld,

input i_rfx_wr_ld,
input i_rfy_wr_ld,
input i_rfx_wr_sel,
input i_rfy_wr_sel,

input i_ldst_addr_sel,
input i_ldst_wrdata_sel,

//rf writeback
input i_rf_wr,
input i_rf_seven,
input [2:0] i_rf_sel,


//tb regs
output logic [7:0][15:0] o_tb_regs
);

//pc registers
logic [15:0] pc, pc_in, pc_register;
logic [15:0] pc_next;
logic [15:0] pc_jmp;
logic [15:0] pc_decode;
logic [15:0] pc_execute;
logic [15:0] pc_writeback;

//instruction registers
logic [15:0] ir;
logic [15:0] ir_decode;
logic [15:0] ir_execute;
logic [15:0] ir_writeback;

//regfile related
logic [15:0] rx_execute, ry_execute;
logic [15:0] rx_writeback, ry_writeback;
logic [15:0] rX,rY,rXin,rYin,rx_writebackIn,ry_writebackIn;
logic [15:0] rf_data_in;
logic [2:0] rf_addr; //address of one to write too
logic [2:0] rX_Addr;
logic [2:0] rY_Addr;

//immediate values
logic [15:0] decode_imm8, execute_imm8, writeback_imm8;
logic [15:0] decode_imm11, execute_imm11, writeback_imm11;

//alu data
logic [15:0] alu_op_a;
logic [15:0] alu_op_b;
logic [15:0] alu_out;
logic [15:0] alu_A;
logic alu_n;
logic alu_z;

//ALU
alu a0(
	.i_op_sel(i_alu_op),
	.i_op_a(alu_op_a),
	.i_op_b(alu_op_b),
	.o_alu_out(alu_out),
	.o_n(alu_n),
	.o_z(alu_z)
);

//REGISTERFILE
regfile r0(
	 .clk(clk),
    .reset(reset),
    .i_write(i_rf_wr),
    .i_addrw(rf_addr),
    .i_addrx(rX_Addr),
    .i_addry(rY_Addr),
    .i_data_in(rf_data_in),
    .o_datax(rX),
    .o_datay(rY),
	 
	 .tb_regs(o_tb_regs)

);

//assign outputs
assign o_ir_decode = ir_decode;
assign o_ir_execute = ir_execute;
assign o_ir_rf_write = ir_writeback;


//pc logic
assign pc_next = pc + 2;
assign pc_jmp = pc_execute + (execute_imm11 << 1);
assign pc_register = (i_fwd_pc) ? rf_data_in : rx_execute;
//assign o_pc_addr = pc;

always_comb begin
	case(i_pc_addr_sel)
		2'd0: begin
			pc_in = pc_next;
			o_pc_addr = pc;
		end
		2'd1: begin
			pc_in = pc_register + 2; 
			o_pc_addr = pc_register;
		end
		2'd2: begin
			pc_in = pc_jmp + 2;
			o_pc_addr = pc_jmp;
		end
		default: begin
			pc_in = {'0};
			o_pc_addr = {'0};
		end
	endcase
end

/*DECODE*/
//ir logic
assign ir_decode = (i_flush_f || i_flush_w) ? 16'h0007 : i_pc_rddata;
assign ir = (i_flush_f || i_flush_w) ? 16'h0007 : i_pc_rddata;

//register logic
assign rX_Addr = ir_decode[7:5];
assign rY_Addr = ir_decode[10:8];

//immediate value logic 
assign deocde_imm8 = {{8{ir_decode[15]}},{ir_decode[15:8]}};
assign decode_imm11 = {{5{ir_decode[15]}},{ir_decode[15:5]}};

//forward logic
assign rXin = (i_rx_d_sel) ? rf_data_in : rX;
assign rYin = (i_ry_d_sel) ? rf_data_in : rY;

/*EXECUTE*/
assign execute_imm8 = {{8{ir_execute[15]}},{ir_execute[15:8]}};
assign execute_imm11 = {{5{ir_execute[15]}},{ir_execute[15:5]}};

//alu inputs
assign alu_op_a = (i_alu_a_sel) ? rf_data_in : rx_execute;
always_comb begin
	case(i_alu_b_sel)
		2'd0: alu_op_b = ry_execute;
		2'd1: alu_op_b = execute_imm8;
		2'd2: alu_op_b = rf_data_in;
		default: alu_op_b = {'0};
	endcase
end

//st or ld addresses
assign o_ldst_wrdata = (i_ldst_wrdata_sel) ? rf_data_in : rx_writebackIn;
assign o_ldst_addr = (i_ldst_addr_sel) ? rf_data_in : ry_writebackIn;

/*WRITEBACK*/
assign writeback_imm8 = {{8{ir_writeback[15]}},{ir_writeback[15:8]}};
assign writeback_imm11 = {{5{ir_writeback[15]}},{ir_writeback[15:5]}};
assign rx_writebackIn = (i_rfx_wr_sel) ? rf_data_in : rx_execute;
assign ry_writebackIn = (i_rfy_wr_sel) ? rf_data_in : ry_execute;

always_comb begin

	rf_addr = (i_rf_seven) ? 3'd7 : ir_writeback[7:5];
	
	//regfile data multiplexer
	case (i_rf_sel)
		3'd0:rf_data_in = ry_writeback; //mv 
		3'd1:rf_data_in = {writeback_imm8[7:0],rx_writeback[7:0]}; //mvhi
		3'd2:rf_data_in = alu_A; // add or sub
		3'd3:rf_data_in = pc_writeback; //call
		3'd4:rf_data_in = i_ldst_rddata; //ld
		3'd5:rf_data_in = writeback_imm8; //mvi
		default: rf_data_in = {'0};
    endcase
end




//pipeline registers
always_ff @ (posedge clk, posedge reset) begin
	if (reset) begin
		pc <= 0;
		pc_decode <= 0;
		pc_execute <= 0;
		pc_writeback <= 0;
		//ir_decode <= 0;
		ir_execute <= 0;
		ir_writeback <= 0;
		o_n <= 0;
		o_z <= 0;
		rx_execute <= 0;
		ry_execute <= 0;
		rx_writeback <= 0;
		ry_writeback <= 0;
	end
	else if(i_flush_f)begin
		///fetch 
		if(i_pc_ld) pc <= pc_in;
		//decode
		if(i_decode_pc_ld) pc_decode <= pc_in;
		ry_execute <= 0;
		rx_execute <= 0;
		pc_execute <= 16'h0007; //noops
		ir_execute <= 16'h0007; //noops
		if(i_rfwrite_pc_ld) pc_writeback <= pc_execute;
		if(i_rfwrite_ir_ld) ir_writeback <= ir_execute;
		if(i_rfx_wr_ld) rx_writeback <= rx_writebackIn;
		if(i_rfy_wr_ld) ry_writeback <= ry_writebackIn;
	end
	else begin
		///fetch 
		if(i_pc_ld) pc <= pc_in;
		//decode
		if(i_decode_pc_ld) pc_decode <= pc_in;
		if(i_rf_rx_rd) rx_execute <= rXin;
		if(i_rf_ry_rd) ry_execute <= rYin;
		//execute
		if(i_execute_pc_ld)pc_execute <= pc_decode;
		if(i_execute_ir_ld)ir_execute <= ir_decode;
		if(i_alu_ld_n) o_n <= alu_n;
		if(i_alu_ld_z) o_z <= alu_z;
		if(i_alu_A_ld) alu_A <= alu_out;
		//writeback
		if(i_rfwrite_pc_ld) pc_writeback <= pc_execute;
		if(i_rfwrite_ir_ld) ir_writeback <= ir_execute;
		if(i_rfx_wr_ld) rx_writeback <= rx_writebackIn;
		if(i_rfy_wr_ld) ry_writeback <= ry_writebackIn;
	end
end


endmodule

