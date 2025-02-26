`ifndef EQCOMP_V
`define EQCOMP_V

module EqComp
#(
  parameter nbits=32
)(
  input  logic [nbits-1:0] in0,
  input  logic [nbits-1:0] in1,
  output logic             eq
);

  always_comb begin
    eq = (in0 == in1);
  end

endmodule

`endif
