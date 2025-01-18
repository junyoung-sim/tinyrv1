`ifndef ALU_V
`define ALU_V

`include "Adder.v"
`include "EqComp.v"
`include "Mux2.v"

module ALU
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic             op,
  (* keep=1 *) input  logic [nbits-1:0] in0,
  (* keep=1 *) input  logic [nbits-1:0] in1,
  (* keep=1 *) output logic [nbits-1:0] out
);

  // Adder

  logic [nbits-1:0] sum;

  Adder #(
    .nbits(32)
  ) adder (
    .in0(in0),
    .in1(in1),
    .sum(sum)
  );

  // Equality Comparator

  logic eq;

  EqComp #(
    .nbits(32)
  ) eq_comp (
    .in0(in0),
    .in1(in1),
    .eq(eq)
  );

  // Output Multiplexer

  Mux2 #(
    .nbits(32)
  ) out_mux (
    .sel(op),
    .in0(sum),         // op=0 (add)
    .in1({31'b0, eq}), // op=1 (eq)
    .out(out)
  );

endmodule

`endif