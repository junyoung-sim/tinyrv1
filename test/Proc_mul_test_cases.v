//==========================================================
// MUL: test_addi_mul
//==========================================================

task test_addi_mul();
  t.test_case_begin( "test_addi_mul" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 3" ); // F D X M W
  asm( 'h004, "mul x2 x1 x1" ); //   F D X M W       (X-D)
  
  asm( 'h008, "addi x1 x0 3" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F D X M W
  asm( 'h010, "mul x2 x1 x1" ); //     F D X M W     (M-D)
  
  asm( 'h014, "addi x1 x0 3" ); // F D X M W
  asm( 'h018, "add x0 x0 x0" ); //   F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h020, "mul x2 x1 x1" ); //       F D X M W   (W-D)

  asm( 'h024, "addi x1 x0 3" ); // F D X M W
  asm( 'h028, "add x0 x0 x0" ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h030, "add x0 x0 x0" ); //       F D X M W
  asm( 'h034, "mul x2 x1 x1" ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 3 );
  check_trace( 'h004, 9 );

  check_trace( 'h008, 3 );
  check_trace( 'h00c, 0 );
  check_trace( 'h010, 9 );

  check_trace( 'h014, 3 );
  check_trace( 'h018, 0 );
  check_trace( 'h01c, 0 );
  check_trace( 'h020, 9 );

  check_trace( 'h024, 3 );
  check_trace( 'h028, 0 );
  check_trace( 'h02c, 0 );
  check_trace( 'h030, 0 );
  check_trace( 'h034, 9 );

endtask

//==========================================================
// MUL: test_add_mul
//==========================================================

task test_add_mul();
  t.test_case_begin( "test_add_mul" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 2" ); // F D X M W
  asm( 'h004, "add x1 x1 x1" ); //   F D X M W
  asm( 'h008, "mul x2 x1 x1" ); //     F D X M W       (X-D)

  asm( 'h00c, "addi x1 x0 2" ); // F D X M W
  asm( 'h010, "add x1 x1 x1" ); //   F D X M W
  asm( 'h014, "add x0 x0 x0" ); //     F D X M W
  asm( 'h018, "mul x2 x1 x1" ); //       F D X M W     (M-D)
  
  asm( 'h01c, "addi x1 x0 2" ); // F D X M W
  asm( 'h020, "add x1 x1 x1" ); //   F D X M W
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "add x0 x0 x0" ); //       F D X M W
  asm( 'h02c, "mul x2 x1 x1" ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 2" ); // F D X M W
  asm( 'h034, "add x1 x1 x1" ); //   F D X M W
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "add x0 x0 x0" ); //         F D X M W
  asm( 'h044, "mul x2 x1 x1" ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h002 );
  check_trace( 'h004, 'h004 );
  check_trace( 'h008, 'h010 );

  check_trace( 'h00c, 'h002 );
  check_trace( 'h010, 'h004 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'h010 );

  check_trace( 'h01c, 'h002 );
  check_trace( 'h020, 'h004 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h010 );

  check_trace( 'h030, 'h002 );
  check_trace( 'h034, 'h004 );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'h010 );

endtask

//==========================================================
// MUL: test_mul_mul
//==========================================================

task test_mul_mul();
  t.test_case_begin( "test_mul_mul" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 2" ); // F D X M W
  asm( 'h004, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h008, "mul x2 x1 x1" ); //     F D X M W       (X-D)

  asm( 'h00c, "addi x1 x0 2" ); // F D X M W
  asm( 'h010, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h014, "add x0 x0 x0" ); //     F D X M W
  asm( 'h018, "mul x2 x1 x1" ); //       F D X M W     (M-D)

  asm( 'h01c, "addi x1 x0 2" ); // F D X M W
  asm( 'h020, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "add x0 x0 x0" ); //       F D X M W
  asm( 'h02c, "mul x2 x1 x1" ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 2" ); // F D X M W
  asm( 'h034, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "add x0 x0 x0" ); //         F D X M W
  asm( 'h044, "mul x2 x1 x1" ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h002 );
  check_trace( 'h004, 'h004 );
  check_trace( 'h008, 'h010 );

  check_trace( 'h00c, 'h002 );
  check_trace( 'h010, 'h004 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'h010 );

  check_trace( 'h01c, 'h002 );
  check_trace( 'h020, 'h004 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h010 );

  check_trace( 'h030, 'h002 );
  check_trace( 'h034, 'h004 );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'h010 );

endtask

//==========================================================
// MUL: test_lw_mul
//==========================================================

task test_lw_mul();
  t.test_case_begin( "test_lw_mul" );

  // Data Memory

  data( 'h0fc, 'h003 );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h004, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h008, "mul x2 x1 x1"     ); //     F D D X M W     (M-D)

  asm( 'h00c, "addi x1 x0 0x0fc" ); // F F D X M W
  asm( 'h010, "lw x1 0(x1)"      ); //     F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h018, "mul x2 x1 x1"     ); //         F D X M W   (M-D)

  asm( 'h01c, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h020, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h02c, "mul x2 x1 x1"     ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h034, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "mul x2 x1 x1"     ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0fc );
  check_trace( 'h004, 'h003 );
  check_trace( 'x,    'x    );
  check_trace( 'h008, 'h009 );

  check_trace( 'h00c, 'h0fc );
  check_trace( 'h010, 'h003 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'h009 );

  check_trace( 'h01c, 'h0fc );
  check_trace( 'h020, 'h003 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h009 );

  check_trace( 'h030, 'h0fc );
  check_trace( 'h034, 'h003 );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'h009 );

endtask

//==========================================================
// MUL: test_jal_mul
//==========================================================

task test_jal_mul();
  t.test_case_begin( "test_jal_mul" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004" ); // F D X M W
  asm( 'h004, "mul x2 x1 x1" ); //   F F D X M W     (M-D)

  asm( 'h008, "jal x1 0x014" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h010, "add x0 x0 x0" ); //
  asm( 'h014, "mul x2 x1 x1" ); //     F D X M W     (M-D)

  asm( 'h018, "jal x1 0x024" ); // F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h020, "add x0 x0 x0" ); //
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "mul x2 x1 x1" ); //       F D X M W   (W-D)

  asm( 'h02c, "jal x1 0x038" ); // F D X M W
  asm( 'h030, "add x0 x0 x0" ); //   F - - - -
  asm( 'h034, "add x0 x0 x0" ); //
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "mul x2 x1 x1" ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h004, 'h010 );

  check_trace( 'h008, 'h00c );
  check_trace( 'x,    'x    );
  check_trace( 'h014, 'h090 );

  check_trace( 'h018, 'h01c );
  check_trace( 'x,    'x    );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h310 );

  check_trace( 'h02c, 'h030 );
  check_trace( 'x,    'x    );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h900 );

endtask