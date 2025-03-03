`include "Proc.v"
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

  logic [31:0] proc_trace_addr;
  logic [31:0] proc_trace_inst;
  logic [31:0] proc_trace_data;

  logic        proc_trace_stall;

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

    .trace_addr     (proc_trace_addr),
    .trace_inst     (proc_trace_inst),
    .trace_data     (proc_trace_data),
    .trace_stall    (proc_trace_stall)
  );

  TestMemory mem
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
    .dmemresp_rdata (dmemresp_rdata)
  );

  //==========================================================
  // Trace Data
  //==========================================================

  logic [31:0] proc_trace_addr_F;
  logic [31:0] proc_trace_addr_D;
  logic [31:0] proc_trace_addr_X;
  logic [31:0] proc_trace_addr_M;
  logic [31:0] proc_trace_addr_W;

  logic [31:0] proc_trace_inst_F;
  logic [31:0] proc_trace_inst_D;
  logic [31:0] proc_trace_inst_X;
  logic [31:0] proc_trace_inst_M;
  logic [31:0] proc_trace_inst_W;

  logic [31:0] proc_trace_data_W;

  assign proc_trace_addr_F = proc_trace_addr;
  assign proc_trace_inst_F = proc_trace_inst;

  always_ff @(posedge clk) begin
    if(proc_trace_stall)
      proc_trace_addr_D <= proc_trace_addr_D;
    else
      proc_trace_addr_D <= proc_trace_addr_F;
    proc_trace_addr_X <= proc_trace_addr_D;
    proc_trace_addr_M <= proc_trace_addr_X;
    proc_trace_addr_W <= proc_trace_addr_M;
  end

  always_ff @(posedge clk) begin
    if(proc_trace_stall)
      proc_trace_inst_D <= proc_trace_inst_D;
    else
      proc_trace_inst_D <= proc_trace_inst_F;
    proc_trace_inst_X <= proc_trace_inst_D;
    proc_trace_inst_M <= proc_trace_inst_X;
    proc_trace_inst_W <= proc_trace_inst_M;
  end
  
  assign proc_trace_data_W = proc_trace_data;

  //==========================================================
  // Verification
  //==========================================================

  TinyRV1 tinyrv1();

  task check_trace
  (
    input logic [31:0] addr,
    input logic [31:0] data
  );

    if(!t.failed) begin
      #8;
      if(t.n != 0) begin
        if (data === 'x)
          $display( "%3d: %x %-s         ", t.cycles,
                    proc_trace_addr_W,
                    tinyrv1.disasm(proc_trace_addr_W, proc_trace_inst_W) );
        else
          $display( "%3d: %x %-s %x", t.cycles,
                    proc_trace_addr_W,
                    tinyrv1.disasm(proc_trace_addr_W, proc_trace_inst_W),
                    proc_trace_data_W );
      end
      `CHECK_EQ_HEX(proc_trace_addr_W, addr);
      `CHECK_EQ_HEX(proc_trace_data_W, data);
      #2;
    end

  endtask

  //==========================================================
  // Assembly
  //==========================================================

  task asm
  (
    input [31:0] addr,
    input string inst
  );

    mem.asm(addr, inst);

  endtask

  //==========================================================
  // Data
  //==========================================================

  logic [31:0] data_addr_unused;

  task data
  (
    input [31:0] addr,
    input [31:0] data_
  );

    mem.write(addr, data_);
    data_addr_unused = addr;

  endtask

  //==========================================================
  // Test Cases
  //==========================================================

  `include "Proc_csr_test_cases.v"

  //==========================================================
  // Main
  //==========================================================

  initial begin
    t.test_bench_begin(`__FILE__);

    proc_in0 = 'x;
    proc_in1 = 'x;
    proc_in2 = 'x;

    if((t.n <= 0) || (t.n == 1)) test_simple_csrr();
    if((t.n <= 0) || (t.n == 2)) test_simple_csrw();
    if((t.n <= 0) || (t.n == 3)) test_escape_loop();

    t.test_bench_end();
  end

endmodule