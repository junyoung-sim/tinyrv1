`ifndef IMMGEN_V
`define IMMGEN_V

`include "TinyRV1.v"

// I: imm_type=0
// S: imm_type=1
// J: imm_type=2
// B: imm_type=3

module ImmGen
(
  (* keep=1 *) input  logic [31:0] inst,
  (* keep=1 *) input  logic [1:0]  imm_type,
  (* keep=1 *) output logic [31:0] imm
);

  logic [6:0] inst_unused;

  always_comb begin
    inst_unused = inst[6:0];
    case(imm_type)
      2'b00: imm = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
      2'b01: imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
      2'b10: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
      2'b11: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    endcase
  end

endmodule

`endif