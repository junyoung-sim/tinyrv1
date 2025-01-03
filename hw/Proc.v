`ifndef PROC_V
`define PROC_V

`include "../hw/ProcMem.v"
`include "../hw/ProcCtrl.v"
`include "../hw/ProcDpath.v"

module Proc
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // External Memory Interface (Cocotb)

  (* keep=1 *) input  logic        ext_dmemreq_val,
  (* keep=1 *) input  logic        ext_dmemreq_type,
  (* keep=1 *) input  logic [31:0] ext_dmemreq_addr,
  (* keep=1 *) input  logic [31:0] ext_dmemreq_wdata,
  (* keep=1 *) output logic [31:0] ext_dmemresp_rdata,

  // Trace Data

  (* keep=1 *) output logic [31:0] trace_data
);

  // Internal Memory Interface

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
  logic        c2d_op2_sel_D;
  logic        c2d_alu_fn_X;
  logic        c2d_result_sel_X;
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

  logic        dval;
  logic        dtype;
  logic [31:0] daddr;
  logic [31:0] wdata;

  always_comb begin

    dval = (dmemreq_val | ext_dmemreq_val);
    
    if(ext_dmemreq_val) begin
      dtype = ext_dmemreq_type;
      daddr = ext_dmemreq_addr;
      wdata = ext_dmemreq_wdata;
    end

    if(dmemreq_val) begin
      dtype = dmemreq_type;
      daddr = dmemreq_addr;
      wdata = dmemreq_wdata;
    end

    ext_dmemresp_rdata = dmemresp_rdata;
  
  end

  ProcMem mem
  (
    .clk(clk),
    .rst(rst),
    .imemreq_val(imemreq_val),
    .imemreq_addr(imemreq_addr),
    .imemresp_data(imemresp_data),
    .dmemreq_val(dval),
    .dmemreq_type(dtype),
    .dmemreq_addr(daddr),
    .dmemreq_wdata(wdata),
    .dmemresp_rdata(dmemresp_rdata)
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