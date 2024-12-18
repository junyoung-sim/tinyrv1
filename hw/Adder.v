`ifndef ADDER_V
`define ADDER_V

module Adder
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic [nbits-1:0] in0,
  (* keep=1 *) input  logic [nbits-1:0] in1,
  (* keep=1 *) output logic [nbits-1:0] sum
);

  always_comb begin
    sum = in0 + in1;
  end

endmodule

`endif