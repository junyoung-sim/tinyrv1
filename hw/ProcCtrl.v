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
  logic stall_F;

  logic bypass_waddr_X_rs1_D;
  logic bypass_waddr_X_rs2_D;
  logic bypass_waddr_M_rs1_D;
  logic bypass_waddr_M_rs2_D;
  logic bypass_waddr_W_rs1_D;
  logic bypass_waddr_W_rs2_D;

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
                             & (inst_D[`RS1] == inst_X[`RD])
                             & (inst_X[`RD] != 0);
    stall_lw_X_rs2_D = val_D & val_X
                             & (inst_X == `LW)
                             & (inst_D[`RS2] == inst_X[`RD])
                             & (inst_X[`RD] != 0);
    stall_D = val_D & (stall_lw_X_rs1_D | stall_lw_X_rs2_D);
    stall_F = stall_D;
  end

  // Bypass

  logic rs1_en_D;
  logic rs2_en_D;
  
  logic rf_wen_X;
  logic rf_wen_M;
  logic rf_wen_W;

  always_comb begin
    rs1_en_D = (inst_D == `ADD) | (inst_D == `ADDI) |
               (inst_D == `MUL) | (inst_D == `LW  ) |
               (inst_D == `SW ) | (inst_D == `JR  ) |
               (inst_D == `BNE) ;
    rs2_en_D = (inst_D == `ADD) | (inst_D == `MUL ) |
               (inst_D == `SW ) | (inst_D == `BNE ) ;
    // X -> D
    rf_wen_X = (inst_X == `ADD) | (inst_X == `ADDI) |
               (inst_X == `MUL) | (inst_X == `LW  ) |
               (inst_X == `JAL) ;
    bypass_waddr_X_rs1_D =   val_D & rs1_en_D
                           & val_X & rf_wen_X
                           & (inst_D[`RS1] == inst_X[`RD])
                           & (inst_X[`RD] != 0)
                           & (inst_X != `LW);
    bypass_waddr_X_rs2_D =   val_D & rs2_en_D
                           & val_X & rf_wen_X
                           & (inst_D[`RS2] == inst_X[`RD])
                           & (inst_X[`RD] != 0)
                           & (inst_X != `LW);
    // M -> D
    rf_wen_M = (inst_M == `ADD) | (inst_M == `ADDI) |
               (inst_M == `MUL) | (inst_M == `LW  ) |
               (inst_M == `JAL) ;
    bypass_waddr_M_rs1_D =   val_D & rs1_en_D
                           & val_M & rf_wen_M
                           & (inst_D[`RS1] == inst_M[`RD])
                           & (inst_M[`RD] != 0);
    bypass_waddr_M_rs2_D =   val_D & rs2_en_D
                           & val_M & rf_wen_M
                           & (inst_D[`RS2] == inst_M[`RD])
                           & (inst_M[`RD] != 0);
    // W -> D
    rf_wen_W = (inst_W == `ADD) | (inst_W == `ADDI) |
               (inst_W == `MUL) | (inst_W == `LW  ) |
               (inst_W == `JAL) ;
    bypass_waddr_W_rs1_D =   val_D & rs1_en_D
                           & val_W & rf_wen_W
                           & (inst_D[`RS1] == inst_W[`RD])
                           & (inst_W[`RD] != 0);
    bypass_waddr_W_rs2_D =   val_D & rs2_en_D
                           & val_W & rf_wen_W
                           & (inst_D[`RS2] == inst_W[`RD])
                           & (inst_W[`RD] != 0);
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