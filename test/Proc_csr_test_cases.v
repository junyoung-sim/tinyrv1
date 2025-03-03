//==========================================================
// CSRR: test_simple_csrr
//==========================================================

task test_simple_csrr();
  t.test_case_begin( "test_simple_csrr" );

  // CSR Inputs

  proc_in0 = 1;
  proc_in1 = 1;
  proc_in2 = 1;

  // Assembly Program

  asm( 'h000, "csrr x1 in0"  ); // F D X M W
  asm( 'h004, "csrr x2 in1"  ); //   F D X M W
  asm( 'h008, "csrr x3 in2"  ); //     F D X M W
  asm( 'h00c, "add x1 x1 x2" ); //       F D X M W    (W-D)
  asm( 'h010, "add x1 x1 x3" ); //         F D X M W  (X-D)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h001 );
  check_trace( 'h004, 'h001 );
  check_trace( 'h008, 'h001 );
  check_trace( 'h00c, 'h002 );
  check_trace( 'h010, 'h003 );

endtask

//==========================================================
// CSRW: test_simple_csrw
//==========================================================

task test_simple_csrw();
  t.test_case_begin( "test_simple_csrw" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1" ); // F D X M W
  asm( 'h004, "csrw out0 x1" ); //   F D X M W      (X-D)
  asm( 'h008, "csrw out1 x1" ); //     F D X M W    (M-D)
  asm( 'h00c, "csrw out2 x1" ); //       F D X M W  (W-D)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h001 );
  check_trace( 'h004, 'x    );
  check_trace( 'h008, 'x    );
  check_trace( 'h00c, 'x    );

  // Check Outputs

  `CHECK_EQ( proc_out0, 'h001 );
  `CHECK_EQ( proc_out1, 'h001 );
  `CHECK_EQ( proc_out2, 'h001 );

endtask

//==========================================================
// CSRR/W: test_escape_loop
//==========================================================

task test_escape_loop();
  t.test_case_begin( "test_escape_loop" );

  // CSR Inputs

  proc_in0 = 0;
  proc_in1 = 0;
  proc_in2 = 0;

  // Assembly Program

  asm( 'h000, "csrw out0 x0"    ); // F D X M W     | <------ ESC
  asm( 'h004, "csrr x1 in0"     ); //   F D X M W   |
  asm( 'h008, "addi x2 x0 1"    ); //     F D X M W |
  asm( 'h00c, "bne x1 x2 0x004" ); //       F D X M | W
  asm( 'h010, "csrw out0 x1"    ); //         F D - | - -
  asm( 'h014, "jal x0 0x014"    ); //           F - | - - -
  //   'h004   csrr x1 in0         //             F | D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'x    );
  check_trace( 'h004, 'h000 );
  check_trace( 'h008, 'h001 );

  proc_in0 = 1; // ESC

  check_trace( 'h00c, 'x    );
  check_trace( 'x,    'x    );
  check_trace( 'x,    'x    );

  check_trace( 'h004, 'h001 );
  check_trace( 'h008, 'h001 );
  check_trace( 'h00c, 'x    );
  check_trace( 'x,    'x    );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h014, 'h018 );
    check_trace( 'x,    'x    );
  end

  // Check Outputs

  `CHECK_EQ(proc_out0, 1);
  `CHECK_EQ(proc_out1, 0);
  `CHECK_EQ(proc_out2, 0);

endtask