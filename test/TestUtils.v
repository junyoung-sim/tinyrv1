`ifndef TESTUTILS_V
`define TESTUTILS_V

`define RED    "\033[31m"
`define GREEN  "\033[32m"
`define YELLOW "\033[33m"
`define RESET  "\033[0m"

module TestUtils
(
  output logic clk,
  output logic rst
);

  // verilator lint_off BLKSEQ
  initial clk   = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  logic failed = 0;

  // verilator lint_off UNUSEDSIGNAL
  string vcd_filename;
  int n = 0;
  int test_case = 0;
  // verilator lint_on UNUSEDSIGNAL

  initial begin

    if(!$value$plusargs("test-case=%d", test_case))
      test_case = 0;
    
    n = test_case;

    if($value$plusargs("dump-vcd=%s", vcd_filename)) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

  end

  // verilator lint_off UNUSEDSIGNAL
  int seed = 32'hdeadbeef;
  // verilator lint_on UNUSEDSIGNAL

  int cycles;

  always @(posedge clk) begin
    
    if(rst)
      cycles <= 0;
    else
      cycles <= cycles + 1;
    
    if(cycles > 10000) begin
      $display("\nERROR (cycles=%0d): timeout!", cycles);
      $finish;
    end

  end

  //==========================================================
  // test_bench_begin
  //==========================================================

  task test_bench_begin(string filename);
    $write("\n", filename);
    #1;
  endtask

  //==========================================================
  // test_bench_end
  //==========================================================

  task test_bench_end();
    $write("\n");
    if(t.n == 0)
      $write("\n");
    $finish;
  endtask

  //==========================================================
  // test_case_begin
  //==========================================================

  task test_case_begin(string taskname);
    $write("\n  ", taskname, " ");
    if(t.n != 0)
      $write("\n");
    
    seed = 32'hdeadbeef;
    failed = 0;

    rst = 1;
    #30;
    rst = 0;
  endtask

endmodule

//============================================================
// CHECK_EQ
//============================================================

`define CHECK_EQ( __dut, __ref )                             \
  if ( __ref !== ( __ref ^ __dut ^ __ref ) ) begin           \
    if ( t.n != 0 )                                          \
      $display( {"\n", `RED, "ERROR", `RESET, " (cycle=%0d): %s != %s (%b != %b)"}, \
                t.cycles, "__dut", "__ref", __dut, __ref );  \
    else                                                     \
      $write({`RED, "FAILED", `RESET});                      \
    t.failed = 1;                                            \
  end                                                        \
  else begin                                                 \
    if ( t.n == 0 )                                          \
      $write({`GREEN, ".", `RESET});                         \
  end                                                        \
  if (1)

//============================================================
// CHECK_EQ_HEX
//============================================================

`define CHECK_EQ_HEX( __dut, __ref )                         \
  if ( __ref !== ( __ref ^ __dut ^ __ref ) ) begin           \
    if ( t.n != 0 )                                          \
      $display( {"\n", `RED, "ERROR", `RESET, " (cycle=%0d): %s != %s (%x != %x)"}, \
                t.cycles, "__dut", "__ref", __dut, __ref );  \
    else                                                     \
      $write({`RED, "FAILED", `RESET});                      \
    t.failed = 1;                                            \
  end                                                        \
  else begin                                                 \
    if ( t.n == 0 )                                          \
      $write({`GREEN, ".", `RESET});                         \
  end                                                        \
  if (1)

`endif