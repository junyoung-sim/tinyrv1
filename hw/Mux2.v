`ifndef MUX2_V
`define MUX2_V

module Mux2
#(
  parameter nbits=32
)(
  input  logic             sel,
  input  logic [nbits-1:0] in0,
  input  logic [nbits-1:0] in1,
  output logic [nbits-1:0] out
);

  always_comb begin
    case(sel)
      1'b0: out = in0;
      1'b1: out = in1;
    endcase
  end

endmodule

`endif
