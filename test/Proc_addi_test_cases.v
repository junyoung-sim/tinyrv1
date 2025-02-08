//===========================================================
// ADDI: test_immediate
//===========================================================

task test_immediate();
  t.test_case_begin( "test_immediate" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 2047"  );
  asm( 'h004, "addi x1 x0 -2048" );

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h000007ff );
  check_trace( 'h004, 'hfffff800 );

endtask

//===========================================================
// ADDI: test_addi_addi
//===========================================================

task test_addi_addi();
  t.test_case_begin( "test_addi_addi" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1" ); // F D X M W
  asm( 'h004, "addi x2 x1 1" ); //   F D X M W       (X-D)
  
  asm( 'h008, "addi x1 x0 1" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F D X M W
  asm( 'h010, "addi x2 x1 1" ); //     F D X M W     (M-D)
  
  asm( 'h014, "addi x1 x0 1" ); // F D X M W
  asm( 'h018, "add x0 x0 x0" ); //   F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h020, "addi x2 x1 1" ); //       F D X M W   (W-D)

  asm( 'h024, "addi x1 x0 1" ); // F D X M W
  asm( 'h028, "add x0 x0 x0" ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h030, "add x0 x0 x0" ); //       F D X M W
  asm( 'h034, "addi x2 x1 1" ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 1 );
  check_trace( 'h004, 2 );

  check_trace( 'h008, 1 );
  check_trace( 'h00c, 0 );
  check_trace( 'h010, 2 );

  check_trace( 'h014, 1 );
  check_trace( 'h018, 0 );
  check_trace( 'h01c, 0 );
  check_trace( 'h020, 2 );

  check_trace( 'h024, 1 );
  check_trace( 'h028, 0 );
  check_trace( 'h02c, 0 );
  check_trace( 'h030, 0 );
  check_trace( 'h034, 2 );
endtask

//===========================================================
// ADDI: test_add_addi
//===========================================================

task test_add_addi();
  t.test_case_begin( "test_add_addi" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1" ); // F D X M W
  asm( 'h004, "add x1 x1 x1" ); //   F D X M W
  asm( 'h008, "addi x1 x1 1" ); //     F D X M W       (X-D)

  asm( 'h00c, "addi x1 x0 1" ); // F D X M W
  asm( 'h010, "add x1 x1 x1" ); //   F D X M W
  asm( 'h014, "add x0 x0 x0" ); //     F D X M W
  asm( 'h018, "addi x1 x1 1" ); //       F D X M W     (M-D)
  
  asm( 'h01c, "addi x1 x0 1" ); // F D X M W
  asm( 'h020, "add x1 x1 x1" ); //   F D X M W
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "add x0 x0 x0" ); //       F D X M W
  asm( 'h02c, "addi x1 x1 1" ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 1" ); // F D X M W
  asm( 'h034, "add x1 x1 x1" ); //   F D X M W
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "add x0 x0 x0" ); //         F D X M W
  asm( 'h044, "addi x1 x1 1" ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 1 );
  check_trace( 'h004, 2 );
  check_trace( 'h008, 3 );

  check_trace( 'h00c, 1 );
  check_trace( 'h010, 2 );
  check_trace( 'h014, 0 );
  check_trace( 'h018, 3 );

  check_trace( 'h01c, 1 );
  check_trace( 'h020, 2 );
  check_trace( 'h024, 0 );
  check_trace( 'h028, 0 );
  check_trace( 'h02c, 3 );

  check_trace( 'h030, 1 );
  check_trace( 'h034, 2 );
  check_trace( 'h038, 0 );
  check_trace( 'h03c, 0 );
  check_trace( 'h040, 0 );
  check_trace( 'h044, 3 );

endtask

//===========================================================
// ADDI: test_mul_addi
//===========================================================

task test_mul_addi();
  t.test_case_begin( "test_mul_add" );

   // Assembly Program

  asm( 'h000, "addi x1 x0 3" ); // F D X M W
  asm( 'h004, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h008, "addi x1 x1 9" ); //     F D X M W      (X-D)

  asm( 'h00c, "addi x1 x0 3" ); // F D X M W
  asm( 'h010, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h014, "add x0 x0 x0" ); //     F D X M W
  asm( 'h018, "addi x1 x1 9" ); //       F D X M W    (M-D)

  asm( 'h01c, "addi x1 x0 3" ); // F D X M W
  asm( 'h020, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "add x0 x0 x0" ); //       F D X M W
  asm( 'h02c, "addi x1 x1 9" ); //         F D X M W  (W-D)

  asm( 'h030, "addi x1 x0 3" ); // F D X M W
  asm( 'h034, "mul x1 x1 x1" ); //   F D X M W
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "add x0 x0 x0" ); //         F D X M W
  asm( 'h044, "addi x1 x1 9" ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h003 );
  check_trace( 'h004, 'h009 );
  check_trace( 'h008, 'h012 );

  check_trace( 'h00c, 'h003 );
  check_trace( 'h010, 'h009 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'h012 );

  check_trace( 'h01c, 'h003 );
  check_trace( 'h020, 'h009 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h012 );

  check_trace( 'h030, 'h003 );
  check_trace( 'h034, 'h009 );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'h012 );

endtask

//===========================================================
// ADDI: test_lw_addi
//===========================================================

task test_lw_addi();
  t.test_case_begin( "test_lw_addi" );

  // Data Memory

  data( 'h0fc, 'h001 );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h004, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h008, "addi x1 x1 1"     ); //     F D D X M W    (M-D)

  asm( 'h00c, "addi x1 x0 0x0fc" ); // F F D X M W
  asm( 'h010, "lw x1 0(x1)"      ); //     F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h018, "addi x1 x1 1"     ); //         F D X M W  (M-D)

  asm( 'h01c, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h020, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h02c, "addi x1 x1 1"     ); //         F D X M W  (W-D)

  asm( 'h030, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h034, "lw x1 0(x1)"      ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "addi x1 x1 1"     ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0fc );
  check_trace( 'h004, 'h001 );
  check_trace( 'x,    'x    );
  check_trace( 'h008, 'h002 );

  check_trace( 'h00c, 'h0fc );
  check_trace( 'h010, 'h001 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'h002 );

  check_trace( 'h01c, 'h0fc );
  check_trace( 'h020, 'h001 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h002 );

  check_trace( 'h030, 'h0fc );
  check_trace( 'h034, 'h001 );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'h002 );

endtask

//===========================================================
// ADDI: test_jal_addi
//===========================================================

task test_jal_addi();
  t.test_case_begin( "test_jal_addi" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004" ); // F D X M W
  asm( 'h004, "addi x2 x1 4" ); //   F F D X M W     (M-D)

  asm( 'h008, "jal x1 0x014" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h010, "add x0 x0 x0" ); //
  asm( 'h014, "addi x2 x1 4" ); //     F D X M W     (M-D)

  asm( 'h018, "jal x1 0x024" ); // F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h020, "add x0 x0 x0" ); //
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "addi x2 x1 4" ); //       F D X M W   (W-D)

  asm( 'h02c, "jal x1 0x038" ); // F D X M W
  asm( 'h030, "add x0 x0 x0" ); //   F - - - -
  asm( 'h034, "add x0 x0 x0" ); //
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "addi x2 x1 4" ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h004, 'h008 );

  check_trace( 'h008, 'h00c );
  check_trace( 'x,    'x    );
  check_trace( 'h014, 'h010 );

  check_trace( 'h018, 'h01c );
  check_trace( 'x,    'x    );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h020 );

  check_trace( 'h02c, 'h030 );
  check_trace( 'x,    'x    );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h034 );

endtask