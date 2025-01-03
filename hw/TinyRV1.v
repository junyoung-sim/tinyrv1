//==========================================================
// TinyRV1 Instruction Set Specification
//==========================================================
//
// ECE 2300 TinyRV1 ISA
// https://cornell-ece2300.github.io/ece2300-docs/ece2300-tinyrv1-isa/
//
//  31          25 24   20 19   15 14    12 11          7 6      0
// | funct7       | rs2   | rs1   | funct3 | rd          | opcode |  R-type
// | imm[11:0]            | rs1   | funct3 | rd          | opcode |  I-type,I-imm
// | imm[11:5]    | rs2   | rs1   | funct3 | imm[4:0]    | opcode |  S-type,S-imm
// | imm[12|10:5] | rs2   | rs1   | funct3 | imm[4:1|11] | opcode |  S-type,B-imm
// | imm[20|10:1|11|19:12]                 | rd          | opcode |  U-type,J-imm

`ifndef TINYRV1_V
`define TINYRV1_V

//==========================================================
// Immediate Types
//==========================================================

`define IMM_I 2'b00
`define IMM_S 2'b01
`define IMM_J 2'b01
`define IMM_B 2'b11

//==========================================================
// Control Flow Types
//==========================================================

`define PC_PLUS4 2'b00
`define PC_JR    2'b01
`define PC_JTARG 2'b10
`define PC_BTARG 2'b11

//==========================================================
// Instruction Fields
//==========================================================

`define RS2 24:20
`define RS1 19:15
`define RD  11:7

//==========================================================
// Instruction Opcodes
//==========================================================

`define ADD  32'b0000000_?????_?????_000_?????_0110011
`define ADDI 32'b???????_?????_?????_000_?????_0010011
`define MUL  32'b0000001_?????_?????_000_?????_0110011
`define LW   32'b???????_?????_?????_010_?????_0000011
`define SW   32'b???????_?????_?????_010_?????_0100011
`define JAL  32'b???????_?????_?????_???_?????_1101111
`define JR   32'b???????_?????_?????_000_?????_1100111
`define BNE  32'b???????_?????_?????_001_?????_1100011

`endif