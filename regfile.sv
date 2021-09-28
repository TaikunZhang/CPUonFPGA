module regfile 
(
  input clk,
  input reset,

  input i_write,
  input [2:0] i_addrw,
  input [2:0] i_addrx,
  input [2:0] i_addry,
  input [15:0] i_data_in,
  output logic [15:0] o_datax,
  output logic [15:0] o_datay,
  output logic [7:0][15:0] tb_regs
);

  //registers
  logic [7:0][15:0] regs;

  assign o_datax = regs[i_addrx];
  assign o_datay = regs[i_addry];

  always_ff @ (posedge clk, posedge reset) begin
    if (reset) regs <= {'0};
    else if (i_write) regs[i_addrw] <= i_data_in;
  end
  
  assign tb_regs = regs;
  
endmodule
