module cpu_decode(

input [15:0] instr_d,
input [15:0] instr_x,
input [15:0] instr_w,

output logic execute_pc_ld,
output logic execute_ir_ld,
output logic rf_rx_rd,
output logic rf_ry_rd,
output logic ry_sel,
output logic rx_sel

);

logic [2:0] rx_d,ry_d;
logic [2:0] rx_x,ry_x;
logic [2:0] rx_w,ry_w;
logic callr;
logic rx_used,ry_used; //if writeback uses ry

assign rx_d = instr_d [7:5];
assign ry_d = instr_d [10:8];
assign rx_x = instr_x [7:5];
assign ry_x = instr_x [10:8];
assign rx_w = instr_w [7:5];
assign ry_w = instr_w [10:8];

assign callr = (instr_w[3:0] == 4'd12 && rx_d == 3'd7);
assign ry_used = (instr_w[4:3] == 2'd0 && instr_w[3:0] != 4'd7);
assign rx_used = (instr_w[3:2] == 2'd0 && instr_w[1:0] != 2'd3) ||
              (instr_w[3:2] == 2'd1 && ~instr_w[0]);

always_comb begin

	execute_pc_ld = 1'b1;
	execute_ir_ld = 1'b1;
	rf_rx_rd = 1'b1;
	rf_ry_rd = 1'b1;
	ry_sel = 1'b0;
	rx_sel = 1'b0;

	//forwarding for decode and writeback instr
	if((rx_d == rx_w && rx_used) || callr)begin
		rx_sel = 1'b1;
	end
	if(ry_d == rx_w && ry_used)begin
		ry_sel = 1'b1;
	end
end

endmodule