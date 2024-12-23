`ifndef PROCDPATH_V
`define PROCDPATH_V

`include "../hw/Mux4.v"
`include "../hw/Adder.v"
`include "../hw/Register.v"

module ProcDpath
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic        imemreq_val,
  (* keep=1 *) output logic [31:0] imemreq_addr,
  (* keep=1 *) input  logic [31:0] imemresp_data,

  // Control Signals

  (* keep=1 *) input  logic        c2d_reg_en_F,
  (* keep=1 *) input  logic        c2d_imemreq_val,

  // Status Signals

  (* keep=1 *) output logic [31:0] d2c_inst
);

  //==========================================================
  // Stage F
  //==========================================================

  // Program Counter

  logic [31:0] pc;
  logic [31:0] pc_next;

  logic [31:0] pc_plus_4;

  Register#(32) pc_F (
    .clk(clk),
    .rst(rst),
    .en(reg_en_F),
    .d(pc_next),
    .q(pc)
  );

  Adder#(32) pc_plus_4_adder (
    .in0(pc),
    .in1(32'h00000004);
    .sum(pc_plus_4);
  );

  Mux4#(32) pc_mux (
    .in0(pc_plus_4),
    .in1(32'b0),
    .in2(32'b0),
    .in3(32'b0),
    .out(pc_next)
  );

  // Fetch

  assign imemreq_val  = c2d_imemreq_val;
  assign imemreq_addr = pc;

  logic [31:0] inst;
  assign inst     = imemresp_data;
  assign d2c_inst = imemresp_data;

  //==========================================================
  // Stage D
  //==========================================================

endmodule

`endif