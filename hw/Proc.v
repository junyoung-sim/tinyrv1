`ifndef PROC_V
`define PROC_V

`include "ProcCtrl.v"
`include "ProcDpath.v"

module Proc
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

  // Trace Data

  output logic [31:0] trace_addr,
  output logic [31:0] trace_inst,
  output logic [31:0] trace_data,
  output logic        trace_stall
);

  // Control Signals

  logic        c2d_imemreq_val_F;
  logic        c2d_reg_en_F;
  logic [1:0]  c2d_pc_sel_F;
  logic        c2d_reg_en_D;
  logic [1:0]  c2d_imm_type_D;
  logic [1:0]  c2d_op1_byp_sel_D;
  logic [1:0]  c2d_op2_byp_sel_D;
  logic        c2d_op1_sel_D;
  logic [1:0]  c2d_op2_sel_D;
  logic [1:0]  c2d_csrr_sel_D;
  logic        c2d_alu_fn_X;
  logic [1:0]  c2d_result_sel_X;
  logic        c2d_dmemreq_val_M;
  logic        c2d_dmemreq_type_M;
  logic        c2d_wb_sel_M;
  logic        c2d_rf_wen_W;
  logic [4:0]  c2d_rf_waddr_W;
  logic        c2d_csrw_out0_en_W;
  logic        c2d_csrw_out1_en_W;
  logic        c2d_csrw_out2_en_W;

  // Status Signals

  logic        d2c_eq_X;
  logic [31:0] d2c_inst;

  //==========================================================
  // Processor Controller
  //==========================================================

  ProcCtrl ctrl
  (
    .*
  );

  //==========================================================
  // Processor Data Path
  //==========================================================

  ProcDpath dpath
  (
    .*
  );

endmodule

`endif
