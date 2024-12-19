`ifndef MUX4_V
`define MUX4_V

module Mux4
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic [1:0]       sel,
  (* keep=1 *) input  logic [nbits-1:0] in0,
  (* keep=1 *) input  logic [nbits-1:0] in1,
  (* keep=1 *) input  logic [nbits-1:0] in2,
  (* keep=1 *) input  logic [nbits-1:0] in3,
  (* keep=1 *) output logic [nbits-1:0] out
);

  always_comb begin
    case(sel)
      2'b00: out = in0;
      2'b01: out = in1;
      2'b10: out = in2;
      2'b11: out = in3;
    endcase
  end

endmodule

`endif