`ifndef PROC_V
`define PROC_V

`include "../hw/ProcMem.v"
`include "../hw/ProcCtrl.v"
`include "../hw/ProcDpath.v"

module Proc
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,



);

  // Control Signals

  logic        c2d_reg_en_F;
  logic [1:0]  c2d_pc_sel_F;
  logic        c2d_reg_en_D;
  logic [1:0]  c2d_op1_byp_sel_D;
  logic [1:0]  c2d_op2_byp_sel_D;
  logic        c2d_op1_sel_D;
  logic        c2d_op2_sel_D;
  logic        c2d_alu_fn_X;
  logic        c2d_result_sel_X;
  logic        c2d_wb_sel_M;
  logic        c2d_rf_wen_W;
  logic [4:0]  c2d_rf_waddr_W;
  logic        c2d_imemreq_val;

  // Status Signals

  logic        d2c_eq_X;
  logic [31:0] d2c_inst;

  

endmodule

`endif