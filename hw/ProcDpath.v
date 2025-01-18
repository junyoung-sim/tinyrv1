`ifndef PROCDPATH_V
`define PROCDPATH_V

`include "../hw/ALU.v"
`include "../hw/Mux4.v"
`include "../hw/Adder.v"
`include "../hw/ImmGen.v"
`include "../hw/TinyRV1.v"
`include "../hw/Regfile.v"
`include "../hw/Register.v"
`include "../hw/Multiplier.v"

module ProcDpath
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic        imemreq_val,
  (* keep=1 *) output logic [31:0] imemreq_addr,
  (* keep=1 *) input  logic [31:0] imemresp_data,

  (* keep=1 *) output logic        dmemreq_val,
  (* keep=1 *) output logic        dmemreq_type,
  (* keep=1 *) output logic [31:0] dmemreq_addr,
  (* keep=1 *) output logic [31:0] dmemreq_wdata,
  (* keep=1 *) input  logic [31:0] dmemresp_rdata,

  // I/O Interface

  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,

  (* keep=1 *) output logic [31:0] out0,
  (* keep=1 *) output logic [31:0] out1,
  (* keep=1 *) output logic [31:0] out2,

  // Control Signals

  (* keep=1 *) input  logic        c2d_imemreq_val_F,
  (* keep=1 *) input  logic        c2d_reg_en_F,
  (* keep=1 *) input  logic [1:0]  c2d_pc_sel_F,
  (* keep=1 *) input  logic        c2d_reg_en_D,
  (* keep=1 *) input  logic [1:0]  c2d_imm_type_D,
  (* keep=1 *) input  logic [1:0]  c2d_op1_byp_sel_D,
  (* keep=1 *) input  logic [1:0]  c2d_op2_byp_sel_D,
  (* keep=1 *) input  logic        c2d_op1_sel_D,
  (* keep=1 *) input  logic [1:0]  c2d_op2_sel_D,
  (* keep=1 *) input  logic [1:0]  c2d_csrr_sel_D,
  (* keep=1 *) input  logic        c2d_alu_fn_X,
  (* keep=1 *) input  logic [1:0]  c2d_result_sel_X,
  (* keep=1 *) input  logic        c2d_dmemreq_val_M,
  (* keep=1 *) input  logic        c2d_dmemreq_type_M,
  (* keep=1 *) input  logic        c2d_wb_sel_M,
  (* keep=1 *) input  logic        c2d_rf_wen_W,
  (* keep=1 *) input  logic [4:0]  c2d_rf_waddr_W,
  (* keep=1 *) input  logic        c2d_csrw_out0_en_W,
  (* keep=1 *) input  logic        c2d_csrw_out1_en_W,
  (* keep=1 *) input  logic        c2d_csrw_out2_en_W,
  
  // Status Signals

  (* keep=1 *) output logic        d2c_eq_X,
  (* keep=1 *) output logic [31:0] d2c_inst,

  // Trace Data

  (* keep=1 *) output logic [31:0] trace_data
);

  //==========================================================
  // Register File
  //==========================================================

  logic        rf_wen;
  logic [4:0]  rf_waddr;
  logic [31:0] rf_wdata;

  logic [4:0]  rs1_addr;
  logic [4:0]  rs2_addr;

  logic [31:0] rs1;
  logic [31:0] rs2;

  Regfile RF (
    .clk(clk),
    .wen(rf_wen),
    .waddr(rf_waddr),
    .wdata(rf_wdata),
    .raddr0(rs1_addr),
    .rdata0(rs1),
    .raddr1(rs2_addr),
    .rdata1(rs2)
  );

  //==========================================================
  // Bypass Paths
  //==========================================================

  logic [31:0] result_X_next;
  logic [31:0] result_M_next;
  logic [31:0] result_W_next;

  logic [31:0] op1_bypass;
  logic [31:0] op2_bypass;

  //==========================================================
  // Stage F
  //==========================================================

  // Program Counter

  logic [31:0] pc;
  logic [31:0] pc_next;

  Register#(32) pc_F (
    .clk(clk),
    .rst(rst),
    .en(c2d_reg_en_F),
    .d(pc_next),
    .q(pc)
  );

  logic [31:0] pc_plus4;

  Adder#(32) pc_plus4_adder (
    .in0(pc),
    .in1(32'h00000004),
    .sum(pc_plus4)
  );

  logic [31:0] pc_jr;
  logic [31:0] pc_targ;
  logic [31:0] pc_jtarg;
  logic [31:0] pc_btarg;

  assign pc_jr    = op1_bypass;
  assign pc_jtarg = pc_targ;

  Mux4#(32) pc_mux (
    .sel(c2d_pc_sel_F),
    .in0(pc_plus4),
    .in1(pc_jr),
    .in2(pc_jtarg),
    .in3(pc_btarg),
    .out(pc_next)
  );

  // Fetch

  assign imemreq_val  = c2d_imemreq_val_F;
  assign imemreq_addr = pc;

  logic [31:0] inst;
  logic [31:0] inst_next;

  assign inst_next = imemresp_data;

  Register#(32) ir_FD (
    .clk(clk),
    .rst(rst),
    .en(c2d_reg_en_D),
    .d(inst_next),
    .q(inst)
  );

  assign d2c_inst = inst;

  // Program Counter (FD)

  logic [31:0] inst_pc;

  Register#(32) pc_FD (
    .clk(clk),
    .rst(rst),
    .en(c2d_reg_en_D),
    .d(pc),
    .q(inst_pc)
  );

  //==========================================================
  // Stage D
  //==========================================================

  assign rs1_addr = inst[`RS1];
  assign rs2_addr = inst[`RS2];

  // Immediate Generation

  logic [31:0] imm;

  ImmGen immgen (
    .inst(inst),
    .imm_type(c2d_imm_type_D),
    .imm(imm)
  );

  // Jump & Branch Target

  Adder#(32) pc_targ_adder (
    .in0(inst_pc),
    .in1(imm),
    .sum(pc_targ)
  );

  Register#(32) btarg_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(pc_targ),
    .q(pc_btarg)
  );

  // Operand Bypass Selection

  Mux4#(32) op1_bypass_mux (
    .sel(c2d_op1_byp_sel_D),
    .in0(rs1),
    .in1(result_X_next),
    .in2(result_M_next),
    .in3(result_W_next),
    .out(op1_bypass)
  );

  Mux4#(32) op2_bypass_mux (
    .sel(c2d_op2_byp_sel_D),
    .in0(rs2),
    .in1(result_X_next),
    .in2(result_M_next),
    .in3(result_W_next),
    .out(op2_bypass)
  );

  // Operand Selection

  logic [31:0] op1;
  logic [31:0] op2;

  logic [31:0] op1_next;
  logic [31:0] op2_next;

  Mux2#(32) op1_mux (
    .sel(c2d_op1_sel_D),
    .in0(op1_bypass),
    .in1(inst_pc),
    .out(op1_next)
  );

  Mux4#(32) op2_mux (
    .sel(c2d_op2_sel_D),
    .in0(op2_bypass),
    .in1(imm),
    .in2(32'h00000004),
    .in3(32'h00000000),
    .out(op2_next)
  );

  Register#(32) op1_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op1_next),
    .q(op1)
  );

  Register#(32) op2_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op2_next),
    .q(op2)
  );

  // Store Data

  logic [31:0] sd_X;

  Register#(32) sd_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op2_bypass),
    .q(sd_X)
  );

  // CSRR

  logic [31:0] csrr_next;

  Mux4#(32) csrr_mux (
    .sel(c2d_csrr_sel_D),
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .in3(32'b0),
    .out(csrr_next)
  );

  logic [31:0] csrr;

  Register#(32) csrr_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(csrr_next),
    .q(csrr)
  );

  // CSRW (DX)

  logic [31:0] out0_DX;
  logic [31:0] out1_DX;
  logic [31:0] out2_DX;

  Register#(32) csrw_out0_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op1_bypass),
    .q(out0_DX)
  );

  Register#(32) csrw_out1_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op1_bypass),
    .q(out1_DX)
  );

  Register#(32) csrw_out2_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op1_bypass),
    .q(out2_DX)
  );

  //==========================================================
  // Stage X
  //==========================================================

  // Arithmetic Logic Unit

  logic [31:0] alu_out;

  ALU alu (
    .op(c2d_alu_fn_X),
    .in0(op1),
    .in1(op2),
    .out(alu_out)
  );

  assign d2c_eq_X = alu_out[0];

  // Multiplier

  logic [31:0] mul_out;

  Multiplier#(32) mul (
    .in0(op1),
    .in1(op2),
    .prod(mul_out)
  );

  // Result Selection

  Mux4#(32) result_X_mux (
    .sel(c2d_result_sel_X),
    .in0(alu_out),
    .in1(mul_out),
    .in2(csrr),
    .in3(32'b0),
    .out(result_X_next)
  );

  logic [31:0] result_X;

  Register#(32) result_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(result_X_next),
    .q(result_X)
  );

  // Store Data

  logic [31:0] sd_M;

  Register#(32) sd_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(sd_X),
    .q(sd_M)
  );

  // CSRW (XM)

  logic [31:0] out0_XM;
  logic [31:0] out1_XM;
  logic [31:0] out2_XM;

  Register#(32) csrw_out0_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out0_DX),
    .q(out0_XM)
  );

  Register#(32) csrw_out1_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out1_DX),
    .q(out1_XM)
  );

  Register#(32) csrw_out2_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out2_DX),
    .q(out2_XM)
  );

  //==========================================================
  // Stage M
  //==========================================================

  // Data Memory Requests

  assign dmemreq_val   = c2d_dmemreq_val_M;
  assign dmemreq_type  = c2d_dmemreq_type_M;
  assign dmemreq_addr  = result_X;
  assign dmemreq_wdata = sd_M;

  // Writeback Selection

  Mux2#(32) wb_mux (
    .sel(c2d_wb_sel_M),
    .in0(result_X),
    .in1(dmemresp_rdata),
    .out(result_M_next)
  );

  logic [31:0] result_M;

  Register#(32) result_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(result_M_next),
    .q(result_M)
  );

  // CSRW (MW)

  logic [31:0] out0_MW;
  logic [31:0] out1_MW;
  logic [31:0] out2_MW;

  Register#(32) csrw_out0_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out0_XM),
    .q(out0_MW)
  );

  Register#(32) csrw_out1_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out1_XM),
    .q(out1_MW)
  );

  Register#(32) csrw_out2_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out2_XM),
    .q(out2_MW)
  );

  //==========================================================
  // Stage W
  //==========================================================

  // RF Writeback

  assign result_W_next = result_M;

  assign rf_wen   = c2d_rf_wen_W;
  assign rf_waddr = c2d_rf_waddr_W;
  assign rf_wdata = result_W_next;

  // Trace Data

  assign trace_data = rf_wdata;

  // CSRW (Output)

  Register#(32) csrw_out0 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out0_en_W),
    .d(out0_MW),
    .q(out0)
  );

  Register#(32) csrw_out1 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out1_en_W),
    .d(out1_MW),
    .q(out1)
  );

  Register#(32) csrw_out2 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out2_en_W),
    .d(out2_MW),
    .q(out2)
  );

endmodule

`endif