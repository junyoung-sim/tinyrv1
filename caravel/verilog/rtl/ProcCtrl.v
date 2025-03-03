`ifndef PROCCTRL_V
`define PROCCTRL_V

`include "TinyRV1.v"
`include "Register.v"

module ProcCtrl
(
  input  logic        clk,
  input  logic        rst,

  // Control Signals

  output logic        c2d_imemreq_val_F,
  output logic        c2d_reg_en_F,
  output logic [1:0]  c2d_pc_sel_F,
  output logic        c2d_reg_en_D,
  output logic [1:0]  c2d_imm_type_D,
  output logic [1:0]  c2d_op1_byp_sel_D,
  output logic [1:0]  c2d_op2_byp_sel_D,
  output logic        c2d_op1_sel_D,
  output logic [1:0]  c2d_op2_sel_D,
  output logic [1:0]  c2d_csrr_sel_D,
  output logic        c2d_alu_fn_X,
  output logic [1:0]  c2d_result_sel_X,
  output logic        c2d_dmemreq_val_M,
  output logic        c2d_dmemreq_type_M,
  output logic        c2d_wb_sel_M,
  output logic        c2d_rf_wen_W,
  output logic [4:0]  c2d_rf_waddr_W,
  output logic        c2d_csrw_out0_en_W,
  output logic        c2d_csrw_out1_en_W,
  output logic        c2d_csrw_out2_en_W,

  // Status Signals

  input  logic        d2c_eq_X,
  input  logic [31:0] d2c_inst
);

  //==========================================================
  // Internal Signals
  //==========================================================

  logic [31:0] inst_D;
  logic [31:0] inst_X;
  logic [31:0] inst_M;
  logic [31:0] inst_W;

  logic val_D;
  logic val_X;
  logic val_M;
  logic val_W;

  logic       rs1_en_D;
  logic       rs2_en_D;
  logic       rf_wen_X;
  logic       rf_wen_M;
  logic       rf_wen_W;
  logic [4:0] rf_waddr_W;

  logic [4:0] rs1_D;
  logic [4:0] rs2_D;

  logic [4:0] rd_X;
  logic [4:0] rd_M;
  logic [4:0] rd_W;

  logic bypass_waddr_X_rs1_D;
  logic bypass_waddr_X_rs2_D;
  logic bypass_waddr_M_rs1_D;
  logic bypass_waddr_M_rs2_D;
  logic bypass_waddr_W_rs1_D;
  logic bypass_waddr_W_rs2_D;

  logic stall_lw_X_rs1_D;
  logic stall_lw_X_rs2_D;
  logic stall_D;
  logic stall_F;

  logic squash_D;
  logic squash_F;

  logic [11:0] csrr_num;
  logic [1:0]  csrr_sel;
  logic [11:0] csrw_num;

  //==========================================================
  // Instruction Registers
  //==========================================================

  assign inst_D = d2c_inst;

  Register #(32) ir_DX
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (inst_D),
    .q   (inst_X)
  );

  Register #(32) ir_XM
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (inst_X),
    .q   (inst_M)
  );

  Register #(32) ir_MW
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (inst_M),
    .q   (inst_W)
  );

  //==========================================================
  // Validation Registers
  //==========================================================

  Register #(1) val_FD
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (~squash_F | stall_D),
    .q   (val_D)
  );

  Register #(1) val_DX
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (val_D & ~stall_D & ~squash_D),
    .q   (val_X)
  );

  Register #(1) val_XM
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (val_X),
    .q   (val_M)
  );

  Register #(1) val_MW
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d   (val_M),
    .q   (val_W)
  );

  //==========================================================
  // Hazard Management
  //==========================================================

  always_comb begin
    // RF Read Instructions
    rs1_en_D = (inst_D ==? `ADD) | (inst_D ==? `ADDI) |
               (inst_D ==? `MUL) | (inst_D ==? `LW  ) |
               (inst_D ==? `SW ) | (inst_D ==? `JR  ) |
               (inst_D ==? `BNE) | (inst_D ==? `CSRW) ;
    rs2_en_D = (inst_D ==? `ADD) | (inst_D ==? `MUL ) |
               (inst_D ==? `SW ) | (inst_D ==? `BNE ) ;
    // RF Write Instructions
    rf_wen_X = (inst_X ==? `ADD) | (inst_X ==? `ADDI) |
               (inst_X ==? `MUL) | (inst_X ==? `LW  ) |
               (inst_X ==? `JAL) | (inst_X ==? `CSRR) ;
    rf_wen_M = (inst_M ==? `ADD) | (inst_M ==? `ADDI) |
               (inst_M ==? `MUL) | (inst_M ==? `LW  ) |
               (inst_M ==? `JAL) | (inst_M ==? `CSRR) ;
    rf_wen_W = (inst_W ==? `ADD) | (inst_W ==? `ADDI) |
               (inst_W ==? `MUL) | (inst_W ==? `LW  ) |
               (inst_W ==? `JAL) | (inst_W ==? `CSRR) ;
  end

  assign rs1_D = inst_D[`RS1];
  assign rs2_D = inst_D[`RS2];

  assign rd_X = inst_X[`RD];
  assign rd_M = inst_M[`RD];
  assign rd_W = inst_W[`RD];

  // Bypass

  always_comb begin
    // X -> D
    bypass_waddr_X_rs1_D =   val_D & rs1_en_D
                           & val_X & rf_wen_X
                           & (rs1_D == rd_X)
                           & (rd_X != 0)
                           & (inst_X !=? `LW);
    bypass_waddr_X_rs2_D =   val_D & rs2_en_D
                           & val_X & rf_wen_X
                           & (rs2_D == rd_X)
                           & (rd_X != 0)
                           & (inst_X !=? `LW);
    // M -> D
    bypass_waddr_M_rs1_D =   val_D & rs1_en_D
                           & val_M & rf_wen_M
                           & (rs1_D == rd_M)
                           & (rd_M != 0);
    bypass_waddr_M_rs2_D =   val_D & rs2_en_D
                           & val_M & rf_wen_M
                           & (rs2_D == rd_M)
                           & (rd_M != 0);
    // W -> D
    bypass_waddr_W_rs1_D =   val_D & rs1_en_D
                           & val_W & rf_wen_W
                           & (rs1_D == rd_W)
                           & (rd_W != 0);
    bypass_waddr_W_rs2_D =   val_D & rs2_en_D
                           & val_W & rf_wen_W
                           & (rs2_D == rd_W)
                           & (rd_W != 0);
  end

  // Stall

  always_comb begin
    stall_lw_X_rs1_D =   val_D & rs1_en_D
                       & val_X & (inst_X ==? `LW)
                       & (rs1_D == rd_X)
                       & (rd_X != 0);
    stall_lw_X_rs2_D =   val_D & rs2_en_D
                       & val_X & (inst_X ==? `LW)
                       & (rs2_D == rd_X)
                       & (rd_X != 0);
    stall_D = val_D & (stall_lw_X_rs1_D | stall_lw_X_rs2_D);
    stall_F = stall_D;
  end

  // Squash

  always_comb begin
    squash_D = val_X & (inst_X ==? `BNE) & ~d2c_eq_X;
    squash_F = squash_D | (val_D & ( (inst_D ==? `JAL)
                                   | (inst_D ==? `JR ) ));
  end

  //==========================================================
  // Stage F
  //==========================================================

  // Stall

  assign c2d_reg_en_F = ~stall_F;

  // Fetch Logic

  assign c2d_imemreq_val_F = 1;

  always_comb begin
    if(squash_D) c2d_pc_sel_F = 3;
    else if(val_D) begin
      casez(inst_D)
        `JR  :   c2d_pc_sel_F = 1;
        `JAL :   c2d_pc_sel_F = 2;
        default: c2d_pc_sel_F = 0;
      endcase
    end
    else
      c2d_pc_sel_F = 0;
  end

  //==========================================================
  // Stage D
  //==========================================================

  // Stall

  assign c2d_reg_en_D = ~stall_D;

  // Bypass

  always_comb begin
    if(bypass_waddr_X_rs1_D)
      c2d_op1_byp_sel_D = 1; // X -> D (rs1)
    else if(bypass_waddr_M_rs1_D)
      c2d_op1_byp_sel_D = 2; // M -> D (rs1)
    else if(bypass_waddr_W_rs1_D)
      c2d_op1_byp_sel_D = 3; // W -> D (rs1)
    else
      c2d_op1_byp_sel_D = 0;
  end

  always_comb begin
    if(bypass_waddr_X_rs2_D)
      c2d_op2_byp_sel_D = 1; // X -> D (rs2)
    else if(bypass_waddr_M_rs2_D)
      c2d_op2_byp_sel_D = 2; // M -> D (rs2)
    else if(bypass_waddr_W_rs2_D)
      c2d_op2_byp_sel_D = 3; // W -> D (rs2)
    else
      c2d_op2_byp_sel_D = 0;
  end

  // Immediate, Operand, CSRR Selection

  always_comb begin
    if(val_D & (inst_D ==? `CSRR)) begin
      csrr_num = inst_D[`CSR];
      case(csrr_num)
        `CSR_IN0 : csrr_sel = 0;
        `CSR_IN1 : csrr_sel = 1;
        `CSR_IN2 : csrr_sel = 2;
        default: csrr_sel = 'x;
      endcase
    end
    else begin
      csrr_num = 'x;
      csrr_sel = 'x;
    end
  end

  task automatic cs_D
  (
    input logic [1:0] imm_type_D,
    input logic       op1_sel_D,
    input logic [1:0] op2_sel_D,
    input logic [1:0] csrr_sel_D
  );
    c2d_imm_type_D = imm_type_D;
    c2d_op1_sel_D  = op1_sel_D;
    c2d_op2_sel_D  = op2_sel_D;
    c2d_csrr_sel_D = csrr_sel_D;
  endtask

  always_comb begin
    if(val_D) begin
      casez(inst_D)
        //             imm op1 op2   csrr
        `ADD  :  cs_D( 'x,  0,  0,   'x     );
        `ADDI :  cs_D(  0,  0,  1,   'x     );
        `MUL  :  cs_D( 'x,  0,  0,   'x     );
        `LW   :  cs_D(  0,  0,  1,   'x     );
        `SW   :  cs_D(  1,  0,  1,   'x     );
        `JR   :  cs_D( 'x,  0, 'x,   'x     );
        `JAL  :  cs_D(  2,  1,  2,   'x     );
        `BNE  :  cs_D(  3,  0,  0,   'x     );
        `CSRR :  cs_D( 'x, 'x, 'x, csrr_sel );
        `CSRW :  cs_D( 'x, 'x, 'x,   'x     );
        default: cs_D( 'x, 'x, 'x,   'x     );
      endcase
    end
    else
      cs_D( 'x, 'x, 'x, 'x );
  end

  //==========================================================
  // Stage X
  //==========================================================

  // ALU Function & Result Selection

  task automatic cs_X
  (
    input logic       alu_fn_X,
    input logic [1:0] result_sel_X
  );
    c2d_alu_fn_X     = alu_fn_X;
    c2d_result_sel_X = result_sel_X;
  endtask

  always_comb begin
    if(val_X) begin
      casez(inst_X)
        //             alu res
        `ADD  :  cs_X(  0,  0 );
        `ADDI :  cs_X(  0,  0 );
        `MUL  :  cs_X( 'x,  1 );
        `LW   :  cs_X(  0,  0 );
        `SW   :  cs_X(  0,  0 );
        `JR   :  cs_X( 'x, 'x );
        `JAL  :  cs_X(  0,  0 );
        `BNE  :  cs_X(  1, 'x );
        `CSRR :  cs_X( 'x,  2 );
        `CSRW :  cs_X( 'x, 'x );
        default: cs_X( 'x, 'x );
      endcase
    end
    else
      cs_X( 'x, 'x );
  end

  //==========================================================
  // Stage M
  //==========================================================

  // Data Memory Request & Writeback Selection

  task automatic cs_M
  (
    input logic dmemreq_val_M,
    input logic dmemreq_type_M,
    input logic wb_sel_M
  );
    c2d_dmemreq_val_M  = dmemreq_val_M;
    c2d_dmemreq_type_M = dmemreq_type_M;
    c2d_wb_sel_M       = wb_sel_M;
  endtask

  always_comb begin
    if(val_M) begin
      casez(inst_M)
        //             dval dtype wb
        `ADD  :  cs_M(  0,  'x,   0 );
        `ADDI :  cs_M(  0,  'x,   0 );
        `MUL  :  cs_M(  0,  'x,   0 );
        `LW   :  cs_M(  1,   0,   1 );
        `SW   :  cs_M(  1,   1,  'x );
        `JR   :  cs_M(  0,  'x,  'x );
        `JAL  :  cs_M(  0,  'x,   0 );
        `BNE  :  cs_M(  0,  'x,  'x );
        `CSRR :  cs_M(  0,  'x,   0 );
        `CSRW :  cs_M(  0,  'x,  'x );
        default: cs_M( 'x,  'x,  'x );
      endcase
    end
    else
      cs_M( 'x, 'x, 'x );
  end

  //==========================================================
  // Stage W
  //==========================================================

  // RF Writeback

  task automatic cs_W
  (
    input logic       _rf_wen_W,
    input logic [4:0] _rf_waddr_W
  );
    c2d_rf_wen_W   = _rf_wen_W;
    c2d_rf_waddr_W = _rf_waddr_W;
  endtask

  always_comb begin
    if(val_W) begin
      rf_waddr_W = inst_W[`RD];
      casez(inst_W)
        //             wen rf_waddr
        `ADD  :  cs_W(  1, rf_waddr_W );
        `ADDI :  cs_W(  1, rf_waddr_W );
        `MUL  :  cs_W(  1, rf_waddr_W );
        `LW   :  cs_W(  1, rf_waddr_W );
        `SW   :  cs_W(  0, 'x         );
        `JR   :  cs_W(  0, 'x         );
        `JAL  :  cs_W(  1, rf_waddr_W );
        `BNE  :  cs_W(  0, 'x         );
        `CSRR :  cs_W(  1, rf_waddr_W );
        `CSRW :  cs_W(  0, 'x         );
        default: cs_W( 'x, 'x         );
      endcase
    end
    else begin
      rf_waddr_W = 'x;
      cs_W( 'x, 'x );
    end
  end

  // CSRW Selection

  always_comb begin
    if(val_W & (inst_W ==? `CSRW)) begin
      csrw_num = inst_W[`CSR];
      case(csrw_num)
        `CSR_OUT0: begin
          c2d_csrw_out0_en_W = 1;
          c2d_csrw_out1_en_W = 0;
          c2d_csrw_out2_en_W = 0;
        end
        `CSR_OUT1: begin
          c2d_csrw_out0_en_W = 0;
          c2d_csrw_out1_en_W = 1;
          c2d_csrw_out2_en_W = 0;
        end
        `CSR_OUT2: begin
          c2d_csrw_out0_en_W = 0;
          c2d_csrw_out1_en_W = 0;
          c2d_csrw_out2_en_W = 1;
        end
        default: begin
          c2d_csrw_out0_en_W = 0;
          c2d_csrw_out1_en_W = 0;
          c2d_csrw_out2_en_W = 0;
        end
      endcase
    end
    else begin
      csrw_num = 'x;
      c2d_csrw_out0_en_W = 0;
      c2d_csrw_out1_en_W = 0;
      c2d_csrw_out2_en_W = 0;
    end
  end

endmodule

`endif
