`ifndef REGFILE_V
`define REGFILE_V

module Regfile
(
  input  logic        clk,

  input  logic        wen,
  input  logic [4:0]  waddr,
  input  logic [31:0] wdata,

  input  logic [4:0]  raddr0,
  output logic [31:0] rdata0,
  input  logic [4:0]  raddr1,
  output logic [31:0] rdata1
);

  logic [31:0] R [32];

  always_ff @(posedge clk) begin
    R[waddr] <= (wen & waddr != 0 ? wdata : R[waddr]);
  end

  always_comb begin
    rdata0 = (raddr0 == 0 ? 32'b0 : R[raddr0]);
    rdata1 = (raddr1 == 0 ? 32'b0 : R[raddr1]);
  end

endmodule

`endif
