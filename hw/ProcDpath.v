`ifndef PROCDPATH_V
`define PROCDPATH_V

`include "../hw/Mux4.v"
`include "../hw/Adder.v"
`include "../hw/Regfile.v"
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
  (* keep=1 *) input  logic        c2d_reg_en_D,
  (* keep=1 *) input  logic        c2d_op1_byp_sel_D,
  (* keep=1 *) input  logic        c2d_op2_byp_sel_D,
  (* keep=1 *) input  logic        c2d_op1_sel_D,
  (* keep=1 *) input  logic        c2d_op2_sel_D,
  (* keep=1 *) input  logic        c2d_imemreq_val,

  // Status Signals

  (* keep=1 *) output logic [31:0] d2c_inst;
);

  //==========================================================
  // Register File
  //==========================================================

  logic [4:0]  rs1_addr;
  logic [4:0]  rs2_addr;

  logic [31:0] rs1;
  logic [31:0] rs2;

  Regfile RF (
    .clk(clk),
    .wen(),
    .waddr(),
    .wdata(),
    .raddr0(rs1_addr),
    .rdata0(rs1),
    .raddr1(rs2_addr),
    .rdata1(rs2),
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
    .en(c2d_reg_en_F),
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

  //==========================================================
  // Stage D
  //==========================================================

  assign rs1_addr = inst[19:15];
  assign rs2_addr = inst[24:20];

  // Operand Bypass Selection

  logic [31:0] op1_bypass;
  logic [31:0] op2_bypass;

  Mux4#(32) op1_bypass_mux (
    .sel(c2d_op1_byp_sel_D),
    .in0(rs1),
    .in1(32'b0),
    .in2(32'b0),
    .in3(32'b0),
    .out(op1_bypass)
  );

  Mux4#(32) op2_bypass_mux (
    .sel(c2d_op2_byp_sel_D),
    .in0(rs2),
    .in1(32'b0),
    .in2(32'b0),
    .in3(32'b0),
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
    .in1(32'b0),
    .out(op1_next)
  );

  Mux2#(32) op2_mux (
    .sel(c2d_op2_sel_D),
    .in0(op2_bypass),
    .in1(32'b0),
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

  //==========================================================
  // Stage X
  //==========================================================



endmodule

`endif