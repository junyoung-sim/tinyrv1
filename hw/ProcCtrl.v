`ifndef PROCCTRL_V
`define PROCCTRL_V

module ProcCtrl
(
  (* keep=1 *) input  logic        rst,

  // Control Signals

  (* keep=1 *) output logic        c2d_reg_en_F,
  (* keep=1 *) output logic        c2d_imemreq_val,

  // Status Signals

  (* keep=1 *) input  logic [31:0] d2c_inst
);

  //==========================================================
  // Control Signal Table
  //==========================================================

  task automatic cs
  (
    input logic imemreq_val
  );
    c2d_imemreq_val = imemreq_val;
  endtask

  //==========================================================
  // Stage F & D (Stall, Bypass, Squash)
  //==========================================================

  

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