`ifndef MUX2_V
`define MUX2_V

module Mux2
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic             sel,
  (* keep=1 *) input  logic [nbits-1:0] in0,
  (* keep=1 *) input  logic [nbits-1:0] in1,
  (* keep=1 *) output logic [nbits-1:0] out,
);

  always_comb begin
    case(sel)
      1'b0: out = in0;
      1'b1: out = in1;
    endcase
  end

endmodule

`endif