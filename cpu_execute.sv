module cpu_execute
(
input [15:0] instr_x,
input [15:0] instr_rfw,
input n,
input z,

output logic rfwrite_pc_ld,
output logic rfwrite_ir_ld,

output logic alu_a_sel,
output logic [1:0]alu_b_sel, 
output logic alu_ld_n,
output logic alu_ld_z,
output logic alu_op,
output logic alu_A_ld,

output logic rfx_wr_ld,
output logic rfy_wr_ld,
output logic rfx_wr_sel,
output logic rfy_wr_sel,

output logic ldst_rd,
output logic ldst_wr,

output logic ldst_addr_sel,
output logic ldst_wrdata_sel

);

//bypass logic 
logic [2:0] rx_w,ry_w;
logic [2:0] rx_x,ry_x;
logic rx_used,ry_used; //if writeback uses ry
logic callr;

assign rx_w = instr_rfw [7:5];
assign ry_w = instr_rfw [10:8];
assign rx_x = instr_x [7:5];
assign ry_x = instr_x [10:8];

assign fwd_rx = (rx_w == rx_x);
assign fwd_ry = (rx_w == ry_x);

assign ry_used = (instr_x[4:3] == 2'd0 && instr_x[3:0] != 4'd7);
assign rx_used = (instr_rfw[3:0] != 4'd7);

assign callr = (instr_rfw[3:0] == 4'd12 && rx_x == 3'd7);


always_comb begin

	rfwrite_pc_ld = 1'b1;
	rfwrite_ir_ld = 1'b1;

	//alu signals
	alu_op = 1'b0;
	alu_a_sel = 1'b0;
	alu_b_sel= 1'b0;
	alu_ld_n = 1'b0;
	alu_ld_z = 1'b0;
	alu_A_ld = 1'b0;
	
	//writeback ld signals
	rfx_wr_ld = 1'b1;
	rfy_wr_ld = 1'b1;
	rfx_wr_sel = 1'b0;
	rfy_wr_sel = 1'b0;
	
	
	//ld or st signals
	ldst_rd = 1'b0;
	ldst_wr = 1'b0;
	ldst_wrdata_sel = 1'b0;
	ldst_addr_sel = 1'b0;
	

	//mv or mvi or mvhi instruction
	if(instr_x[3:0] == 4'd0 || instr_x[3:0] == 4'd6)begin
		//do stuff in rfwrite
		if(fwd_rx || callr)begin
			rfx_wr_sel = 1'b1;
		end
		if(fwd_ry)begin
			rfy_wr_sel = 1'b1;
		end
	end
	//alu operation 
	else if(instr_x[3:0] >= 4'd1 && instr_x[3:0] <= 4'd3)begin
		alu_ld_n = 1'b1;
		alu_ld_z = 1'b1;
		alu_A_ld = 1'b1;
		//0 for add, 1 for sub/cmp
		alu_op = instr_x[1];
		
		if(fwd_rx || callr) begin
			alu_a_sel = 1'b1;
		end
		if((fwd_ry && ry_used) || callr) begin
			alu_b_sel = 2'd2;
		end
			else alu_b_sel = instr_x[4] ? 2'd1 : 2'd0; //1 for imm8, 0 for ry
		end
	//ld or st
	else if(instr_x[3:1] == 3'd2)begin
		ldst_rd = !instr_x[0];
		ldst_wr = instr_x[0];
		if((fwd_ry && ry_used && rx_used) || callr)begin
			ldst_addr_sel = 1'd1;
			rfy_wr_sel = 1'b1;
		end
		if((fwd_rx && rx_used) || callr)begin
			rfx_wr_sel = 1'b1;
			ldst_wrdata_sel = 1'd1;
		end
	end
end
endmodule