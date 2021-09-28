module cpu_fetch
(

input [15:0] instr_x,
input [15:0] instr_w,
input n,
input z,

output logic pc_ld,
output logic decode_pc_ld,
output logic decode_ir_ld,
output logic pc_rd,
output logic [1:0] pc_addr_sel,
output logic flush_f,
output logic fwd_pc
);
logic rx_write;
logic branch;
logic cond_b_n;
logic cond_b_z;

//j,jr,call,callr instruction
assign branch = ((!instr_x[0] && instr_x[3] && !instr_x[1]) || (instr_x[3:2] == 2'b11));

//jzr,jz instruction
assign cond_b_z = (instr_x[3] && instr_x[0] && z);

//jnr,jn instruction
assign cond_b_n = (instr_x[3] && instr_x[1] && n);

//instr in writeback is writing to rX
assign rx_write = ((instr_w[3:0] <= 4'd4));

assign fwd_pc = (rx_write) && (instr_x[7:5] == instr_w[7:5]);

always_comb begin

	pc_ld = 1'b0;
	decode_pc_ld = 1'b1;
	decode_ir_ld = 1'b1;
	pc_rd = 1'b1;
	flush_f = 1'b0;
	
	//if branch instr
	if(instr_x[3] == 1'b1)begin
	//if taken branch
		if(branch || cond_b_z || cond_b_n) begin
			case(instr_x[4])
				1'b0: pc_addr_sel = 2'd1;
				1'b1: pc_addr_sel = 2'd2;
			endcase
			pc_ld = 1'b1;
			flush_f = 1'b1;
		end
		else begin
			pc_addr_sel = 2'd0;
			pc_ld = 1'b1;
		end
	end
	//not a branch instr
	else begin
		pc_addr_sel = 2'd0;
		pc_ld = 1'b1;
	end
end

endmodule