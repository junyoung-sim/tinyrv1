//==============================================================================
// TinyRV1 Instruction Set Specification
//==============================================================================
//  31          25 24   20 19   15 14    12 11          7 6      0
// | funct7       | rs2   | rs1   | funct3 | rd          | opcode | R-type
// | imm[11:0]            | rs1   | funct3 | rd          | opcode | I-type,I-imm
// | imm[11:5]    | rs2   | rs1   | funct3 | imm[4:0]    | opcode | S-type,S-imm
// | imm[12|10:5] | rs2   | rs1   | funct3 | imm[4:1|11] | opcode | S-type,B-imm
// | imm[20|10:1|11|19:12]                 | rd          | opcode | U-type,J-imm

`ifndef TINYRV1_ASM_V
`define TINYRV1_ASM_V

//------------------------------------------------------------------------------
// Instruction Fields
//------------------------------------------------------------------------------

`define TINYRV1_INST_IMM_J   31:12
`define TINYRV1_INST_IMM_I   31:20
`define TINYRV1_INST_CSR     31:20
`define TINYRV1_INST_FUNCT7  31:25
`define TINYRV1_INST_RS2     24:20
`define TINYRV1_INST_RS1     19:15
`define TINYRV1_INST_FUNCT3  14:12
`define TINYRV1_INST_RD      11:7
`define TINYRV_1_INST_OPCODE 6:0

//------------------------------------------------------------------------------
// Instruction Field Sizes
//------------------------------------------------------------------------------

`define TINYRV1_INST_NBITS        32
`define TINYRV1_INST_IMM_J_NBITS  20
`define TINYRV1_INST_IMM_I_NBITS  12
`define TINYRV1_INST_CSR_NBITS    12
`define TINYRV1_INST_FUNCT7_NBITS 7
`define TINYRV1_INST_RS2_NBITS    5
`define TINYRV1_INST_RS1_NBITS    5
`define TINYRV1_INST_FUNCT3_NBITS 3
`define TINYRV1_INST_RD_NBITS     5
`define TINYRV1_INST_OPCODE_NBITS 7

//------------------------------------------------------------------------------
// Instruction Opcodes
//------------------------------------------------------------------------------

`define TINYRV1_INST_CSRR 32'b???????_?????_?????_010_?????_1110011
`define TINYRV1_INST_CSRW 32'b???????_?????_?????_001_?????_1110011
`define TINYRV1_INST_ADD  32'b0000000_?????_?????_000_?????_0110011
`define TINYRV1_INST_ADDI 32'b???????_?????_?????_000_?????_0010011
`define TINYRV1_INST_MUL  32'b0000001_?????_?????_000_?????_0110011
`define TINYRV1_INST_LW   32'b???????_?????_?????_010_?????_0000011
`define TINYRV1_INST_SW   32'b???????_?????_?????_010_?????_0100011
`define TINYRV1_INST_JAL  32'b???????_?????_?????_???_?????_1101111
`define TINYRV1_INST_JR   32'b???????_?????_?????_000_?????_1100111
`define TINYRV1_INST_BNE  32'b???????_?????_?????_001_?????_1100011

//------------------------------------------------------------------------------
// Co-Processor Registers
//------------------------------------------------------------------------------

`define TINYRV1_CSR_IN0  12'hfc2
`define TINYRV1_CSR_IN1  12'hfc3
`define TINYRV1_CSR_IN2  12'hfc4
`define TINYRV1_CSR_OUT0 12'h7c2
`define TINYRV1_CSR_OUT1 12'h7c3
`define TINYRV1_CSR_OUT2 12'h7c4

`ifndef SYNTHESIS

module TinyRV1();

  //----------------------------------------------------------------------------
  // Global Signals
  //----------------------------------------------------------------------------

  integer e;

  //----------------------------------------------------------------------------
  // check_imm
  //----------------------------------------------------------------------------
  // Verify immediates can be stored in nbits (dec: signed, hex: unsigned)

  function check_imm
  (
    input integer nbits,
    input integer is_dec,
    input integer value
  );

    check_imm = 1;
    if(is_dec) begin
      if((value < -(2**(nbits-1))) || (value > (2**(nbits-1))-1)) begin
        $display("ERROR: Immediate (%d) is out-of-range [%d,%d]",
          value, -(2**(nbits-1)), (2**(nbits-1))-1);
        check_imm = 0;
      end
    end
    else if((value < 0) || (value > (2**nbits)-1)) begin
      $display("ERROR: Immediate (%x) is out-of-range [0x000, %x]",
        value, (2**nbits)-1);
      check_imm = 0;
    end

  endfunction

  

endmodule

`endif /* SYNTHESIS */

`endif /* TINYRV1_ASM_V */