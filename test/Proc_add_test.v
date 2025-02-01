`include "../hw/Proc.v"
`include "TestMemory.v"
`include "TestUtils.v"

module Top();

  // verilator lint_off UNUSED
  logic clk;
  logic rst;
  // verilator lint_on UNUSED

  TestUtils t
  (
    .*
  );

  //==========================================================
  // DUT
  //==========================================================

  logic        imemreq_val;
  logic [31:0] imemreq_addr;
  logic [31:0] imemresp_data;

  logic        dmemreq_val;
  logic        dmemreq_type;
  logic [31:0] dmemreq_addr;
  logic [31:0] dmemreq_wdata;
  logic [31:0] dmemresp_rdata;

  // verilator lint_off UNUSED
  logic [31:0] proc_in0;
  logic [31:0] proc_in1;
  logic [31:0] proc_in2;

  logic [31:0] proc_out0;
  logic [31:0] proc_out1;
  logic [31:0] proc_out2;
  // verilator lint_on UNUSED

  logic [31:0] proc_trace_data;

  Proc proc
  (
    .clk            (clk),
    .rst            (rst),

    .imemreq_val    (imemreq_val),
    .imemreq_addr   (imemreq_addr),
    .imemresp_data  (imemresp_data),

    .dmemreq_val    (dmemreq_val),
    .dmemreq_type   (dmemreq_type),
    .dmemreq_addr   (dmemreq_addr),
    .dmemreq_wdata  (dmemreq_wdata),
    .dmemresp_rdata (dmemresp_rdata),

    .in0            (proc_in0),
    .in1            (proc_in1),
    .in2            (proc_in2),

    .out0           (proc_out0),
    .out1           (proc_out1),
    .out2           (proc_out2),

    .trace_data     (proc_trace_data)
  );

  TestMemory mem
  (
    .clk            (clk),
    .rst            (rst),

    .imemreq_val    (imemreq_val)
    .imemreq_addr   (imemreq_addr)
    .imemresp_data  (imemresp_data)

    .dmemreq_val    (dmemreq_val)
    .dmemreq_type   (dmemreq_type)
    .dmemreq_addr   (dmemreq_addr)
    .dmemreq_wdata  (dmemreq_wdata)
    .dmemresp_rdata (dmemresp_rdata)
  );

endmodule