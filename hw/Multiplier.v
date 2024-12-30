`ifndef MULTIPLIER_V
`define MULTIPLIER_V

module Multiplier
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic [nbits-1:0] in0,
  (* keep=1 *) input  logic [nbits-1:0] in1,
  (* keep=1 *) output logic [nbits-1:0] prod
);

  always_comb begin
    prod = in0 * in1;
  end

endmodule

`endif