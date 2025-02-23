`ifndef ALU_V
`define ALU_V

`include "Adder.v"
`include "EqComp.v"
`include "Mux2.v"

module ALU
#(
  parameter nbits=32
)(
  input  logic             op,
  input  logic [nbits-1:0] in0,
  input  logic [nbits-1:0] in1,
  output logic [nbits-1:0] out
);

  // Adder

  logic [nbits-1:0] sum;

  Adder #(32) adder
  (
    .in0 (in0),
    .in1 (in1),
    .sum (sum)
  );

  // Equality Comparator

  logic eq;

  EqComp #(32) eq_comp
  (
    .in0 (in0),
    .in1 (in1),
    .eq  (eq)
  );

  // Output Multiplexer

  Mux2 #(32) out_mux
  (
    .sel (op),
    .in0 (sum),         // op=0 (add)
    .in1 ({31'b0, eq}), // op=1 (eq)
    .out (out)
  );

endmodule

`endif
