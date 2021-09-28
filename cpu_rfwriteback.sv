module cpu_rfwrite(
input [15:0] instr,
input n,
input z,

output logic rf_wr,
output logic rf_seven,
output logic [2:0] rf_sel,
output logic flush_w
);

always_comb begin

rf_wr = 1'b0;
rf_seven = 1'b0;
rf_sel = 3'd0;
flush_w = 1'b0;

	case(instr[3:0])
		4'd0:begin
			rf_wr = 1'b1;
			rf_sel = (instr[4] == 1'b1) ? 3'd5:3'd0; // 5 for imm8, 0 for rY
		end
		4'd1:begin
			rf_wr = 1'b1;
			rf_sel = 3'd2; //alu
		end
		4'd2:begin
			rf_wr = 1'b1;
			rf_sel = 3'd2; //alu
		end
		4'd4:begin
			rf_wr = 1'b1;
			rf_sel = 3'd4; //ld
		end
		4'd6:begin
			rf_wr = 1'b1;
			rf_sel = 3'd1; //imm8,rx[15:8]
		end
		4'd12:begin
			rf_wr = 1'b1;
			rf_seven = 1'b1;
			rf_sel = 3'd3; //store pc in rX
		end
	endcase
end
 
endmodule