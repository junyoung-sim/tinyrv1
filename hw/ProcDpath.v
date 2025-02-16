`ifndef PROCDPATH_V
`define PROCDPATH_V

`include "ALU.v"
`include "Mux4.v"
`include "Adder.v"
`include "ImmGen.v"
`include "TinyRV1.v"
`include "Regfile.v"
`include "Register.v"
`include "Multiplier.v"

module ProcDpath
(
  input  logic        clk,
  input  logic        rst,

  // Memory Interface

  output logic        imemreq_val,
  output logic [31:0] imemreq_addr,
  input  logic [31:0] imemresp_data,

  output logic        dmemreq_val,
  output logic        dmemreq_type,
  output logic [31:0] dmemreq_addr,
  output logic [31:0] dmemreq_wdata,
  input  logic [31:0] dmemresp_rdata,

  // I/O Interface

  input  logic [31:0] in0,
  input  logic [31:0] in1,
  input  logic [31:0] in2,

  output logic [31:0] out0,
  output logic [31:0] out1,
  output logic [31:0] out2,

  // Control Signals

  input  logic        c2d_imemreq_val_F,
  input  logic        c2d_reg_en_F,
  input  logic [1:0]  c2d_pc_sel_F,
  input  logic        c2d_reg_en_D,
  input  logic [1:0]  c2d_imm_type_D,
  input  logic [1:0]  c2d_op1_byp_sel_D,
  input  logic [1:0]  c2d_op2_byp_sel_D,
  input  logic        c2d_op1_sel_D,
  input  logic [1:0]  c2d_op2_sel_D,
  input  logic [1:0]  c2d_csrr_sel_D,
  input  logic        c2d_alu_fn_X,
  input  logic [1:0]  c2d_result_sel_X,
  input  logic        c2d_dmemreq_val_M,
  input  logic        c2d_dmemreq_type_M,
  input  logic        c2d_wb_sel_M,
  input  logic        c2d_rf_wen_W,
  input  logic [4:0]  c2d_rf_waddr_W,
  input  logic        c2d_csrw_out0_en_W,
  input  logic        c2d_csrw_out1_en_W,
  input  logic        c2d_csrw_out2_en_W,
  
  // Status Signals

  output logic        d2c_eq_X,
  output logic [31:0] d2c_inst,

  // Trace Data

  output logic [31:0] trace_addr,
  output logic [31:0] trace_inst,
  output logic [31:0] trace_data
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

  logic [31:0] out_DX;

  Register#(32) csrw_out_DX (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(op1_bypass),
    .q(out_DX)
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

  logic [31:0] out_XM;

  Register#(32) csrw_out_XM (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out_DX),
    .q(out_XM)
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

  logic [31:0] out_MW;

  Register#(32) csrw_out_MW (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(out_XM),
    .q(out_MW)
  );

  //==========================================================
  // Stage W
  //==========================================================

  // RF Writeback

  assign result_W_next = result_M;

  assign rf_wen   = c2d_rf_wen_W;
  assign rf_waddr = c2d_rf_waddr_W;
  assign rf_wdata = result_W_next;

  // CSRW (Output)

  Register#(32) csrw_out0 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out0_en_W),
    .d(out_MW),
    .q(out0)
  );

  Register#(32) csrw_out1 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out1_en_W),
    .d(out_MW),
    .q(out1)
  );

  Register#(32) csrw_out2 (
    .clk(clk),
    .rst(rst),
    .en(c2d_csrw_out2_en_W),
    .d(out_MW),
    .q(out2)
  );

  //==========================================================
  // Trace Data
  //==========================================================

  assign trace_addr = pc;
  assign trace_inst = imemresp_data;
  assign trace_data = rf_wdata;

endmodule

`endif