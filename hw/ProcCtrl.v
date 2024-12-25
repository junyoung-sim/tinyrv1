`ifndef PROCCTRL_V
`define PROCCTRL_V

`include "../hw/Register.v"

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

module ProcCtrl
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Control Signals

  (* keep=1 *) output logic        c2d_reg_en_F,
  (* keep=1 *) output logic [1:0]  c2d_pc_sel_F,
  (* keep=1 *) output logic        c2d_reg_en_D,
  (* keep=1 *) output logic [1:0]  c2d_op1_byp_sel_D,
  (* keep=1 *) output logic [1:0]  c2d_op2_byp_sel_D,
  (* keep=1 *) output logic        c2d_op1_sel_D,
  (* keep=1 *) output logic        c2d_op2_sel_D,
  (* keep=1 *) output logic        c2d_alu_fn_X,
  (* keep=1 *) output logic        c2d_result_sel_X,
  (* keep=1 *) output logic        c2d_wb_sel_M,
  (* keep=1 *) output logic        c2d_rf_wen_W,
  (* keep=1 *) output logic [4:0]  c2d_rf_waddr_W,
  (* keep=1 *) output logic        c2d_imemreq_val,

  // Status Signals

  (* keep=1 *) input  logic        d2c_eq_X,
  (* keep=1 *) input  logic [31:0] d2c_inst
);

  //==========================================================
  // Hazard Signals
  //==========================================================

  logic squash_D;
  logic squash_F;

  logic stall_lw_X_rs1_D;
  logic stall_lw_X_rs2_D;
  logic stall_D;

  //==========================================================
  // Instruction Registers
  //==========================================================

  logic [31:0] inst_D;
  logic [31:0] inst_X;
  logic [31:0] inst_M;
  logic [31:0] inst_W;

  assign inst_D = d2c_inst;

  Register#(32) ir_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(inst_D),
    .q(inst_X)
  );

  Register#(32) ir_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(inst_X),
    .q(inst_M)
  );

  Register#(32) ir_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(inst_M),
    .q(inst_W)
  );

  //==========================================================
  // Validation Registers
  //==========================================================

  logic val_D;
  logic val_X;
  logic val_M;
  logic val_W;

  Register#(1) val_FD (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(~squash_F),
    .q(val_D)
  );

  Register#(1) val_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(~squash_D),
    .q(val_X)
  );

  Register#(1) val_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(val_X),
    .q(val_M)
  );

  Register#(1) val_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(val_M),
    .q(val_W)
  );

  //==========================================================
  // Hazard Management
  //==========================================================

  // Squash

  always_comb begin
    squash_D = val_X & (inst_X == `BNE) & ~d2c_eq_X;
    squash_F = squash_D | (val_D & ( (inst_D == `JAL)
                                   | (inst_D == `JR ) ));
  end

  // Stall

  always_comb begin
    stall_lw_X_rs1_D = val_D & val_X
                             & (inst_X == `LW)
                             & (inst_D[19:15] == inst_X[11:7])
                             & (inst_X[11:7] != 0);
    stall_lw_X_rs2_D = val_D & val_X
                             & (inst_X == `LW)
                             & (inst_D[24:20] == inst_X[11:7])
                             & (inst_X[11:7] != 0);
    stall_D = val_D & (stall_lw_X_rs1_D | stall_lw_X_rs2_D);
  end

  //==========================================================
  // Stage F
  //==========================================================



  //==========================================================
  // Stage D
  //==========================================================

  task automatic cs_D
  (
    input logic op1_sel_D,
    input logic op2_sel_D
  );
    c2d_op1_sel_D = op1_sel_D;
    c2d_op2_sel_D = op2_sel_D;
  endtask

  always_comb begin
    if(val_D) begin
      case(inst_D)
        //         op1 op2
        `ADD: cs_D( 0,  0 );
        default: cs_D( 'x, 'x );
      endcase
    end
    else
      cs_D( 'x, 'x );
  end

  //==========================================================
  // Stage X
  //==========================================================



  //==========================================================
  // Stage M
  //==========================================================



  //==========================================================
  // Stage W
  //==========================================================



endmodule

`endif