`ifndef PROC_V
`define PROC_V

`include "ProcMem.v"
`include "ProcCtrl.v"
`include "ProcDpath.v"

module Proc
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // I/O Interface

  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,

  (* keep=1 *) output logic [31:0] out0,
  (* keep=1 *) output logic [31:0] out1,
  (* keep=1 *) output logic [31:0] out2,

  // Trace Data

  (* keep=1 *) output logic [31:0] trace_data
);

  // Memory Interface

  logic        imemreq_val;
  logic [31:0] imemreq_addr;
  logic [31:0] imemresp_data;

  logic        dmemreq_val;
  logic        dmemreq_type;
  logic [31:0] dmemreq_addr;
  logic [31:0] dmemreq_wdata;
  logic [31:0] dmemresp_rdata;

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
  logic        c2d_csrw_out0_en_D;
  logic        c2d_csrw_out1_en_D;
  logic        c2d_csrw_out2_en_D;
  logic        c2d_alu_fn_X;
  logic [1:0]  c2d_result_sel_X;
  logic        c2d_dmemreq_val_M;
  logic        c2d_dmemreq_type_M;
  logic        c2d_wb_sel_M;
  logic        c2d_rf_wen_W;
  logic [4:0]  c2d_rf_waddr_W;

  // Status Signals

  logic        d2c_eq_X;
  logic [31:0] d2c_inst;

  //==========================================================
  // Processor Memory
  //==========================================================

  ProcMem mem
  (
    .*
  );

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