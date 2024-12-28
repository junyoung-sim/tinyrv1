`ifndef IMMGEN_V
`define IMMGEN_V

`include "../hw/TinyRV1.v"

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
      `IMM_I: imm = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
      `IMM_S: imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
      `IMM_J: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
      `IMM_B: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    endcase
  end

endmodule

`endif