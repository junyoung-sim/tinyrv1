`ifndef REGFILE_V
`define REGFILE_V

module Regfile
(
  (* keep=1 *) input  logic        clk,

  (* keep=1 *) input  logic        wen,
  (* keep=1 *) input  logic [4:0]  waddr,
  (* keep=1 *) input  logic [31:0] wdata,

  (* keep=1 *) input  logic [4:0]  raddr0,
  (* keep=1 *) output logic [31:0] rdata0,
  (* keep=1 *) input  logic [4:0]  raddr1,
  (* keep=1 *) output logic [31:0] rdata1
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