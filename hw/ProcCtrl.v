`ifndef PROCCTRL_V
`define PROCCTRL_V

`include "../hw/TinyRV1.v"
`include "../hw/Register.v"

module ProcCtrl
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Control Signals

  (* keep=1 *) output logic        c2d_reg_en_F,
  (* keep=1 *) output logic [1:0]  c2d_pc_sel_F,
  (* keep=1 *) output logic        c2d_reg_en_D,
  (* keep=1 *) output logic        c2d_op1_byp_sel_D,
  (* keep=1 *) output logic        c2d_op2_byp_sel_D,

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
  // Squash Signals
  //==========================================================

  logic squash_D;
  logic squash_F;

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
  // Squash
  //==========================================================

  always_comb begin
    squash_D = val_X & (inst_X == `TINYRV1_INST_BNE) & ~d2c_eq_X;
    squash_F = squash_D | (val_D & ( (inst_D == `TINYRV1_INST_JAL) 
                                   | (inst_D == `TINYRV1_INST_JR ) ));
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
    case(inst_D)
      //                      op1 op2
      `TINYRV1_INST_ADD: cs_D( 0,  0 );

      default: cs_D( 'x, 'x );
    endcase
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