//==========================================================
// LW: test_lw_simple
//==========================================================

task test_lw_simple();
  t.test_case_begin( "test_lw_simple" );

  // Data Memory

  data( 'h078, 'hdeadbeef );
  data( 'h07c, 'hcafe2300 );
  data( 'h080, 'hacedbeef );
  data( 'h084, 'hdeafface );
  data( 'h088, 'habacadab );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x080" ); // F D X M W
  asm( 'h004, "lw x2 -8(x1)"     ); //   F D X M W
  asm( 'h008, "lw x2 -4(x1)"     ); //     F D X M W
  asm( 'h00c, "lw x2 0(x1)"      ); //       F D X M W
  asm( 'h010, "lw x2 4(x1)"      ); //         F D X M W
  asm( 'h014, "lw x2 8(x1)"      ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h00000080 );
  check_trace( 'h004, 'hdeadbeef );
  check_trace( 'h008, 'hcafe2300 );
  check_trace( 'h00c, 'hacedbeef );
  check_trace( 'h010, 'hdeafface );
  check_trace( 'h014, 'habacadab );

endtask

//==========================================================
// LW: test_addi_lw
//==========================================================

task test_addi_lw();
  t.test_case_begin( "test_addi_lw" );

  // Data Memory

  data( 'h0fc, 'hcafe2300 );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h004, "lw x1 0(x1)"      ); //   F D X M W       (X-D)

  asm( 'h008, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h010, "lw x1 0(x1)"      ); //     F D X M W     (M-D)

  asm( 'h014, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h018, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h01c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h020, "lw x1 0(x1)"      ); //       F D X M W   (W-D)

  asm( 'h024, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h030, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h034, "lw x1 0(x1)"      ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h000000fc );
  check_trace( 'h004, 'hcafe2300 );

  check_trace( 'h008, 'h000000fc );
  check_trace( 'h00c, 'h00000000 );
  check_trace( 'h010, 'hcafe2300 );

  check_trace( 'h014, 'h000000fc );
  check_trace( 'h018, 'h00000000 );
  check_trace( 'h01c, 'h00000000 );
  check_trace( 'h020, 'hcafe2300 );
  
  check_trace( 'h024, 'h000000fc );
  check_trace( 'h028, 'h00000000 );
  check_trace( 'h02c, 'h00000000 );
  check_trace( 'h030, 'h00000000 );
  check_trace( 'h034, 'hcafe2300 );

endtask

//==========================================================
// LW: test_add_lw
//==========================================================

task test_add_lw();
  t.test_case_begin( "test_add_lw" );

  // Data Memory

  data( 'h0fc, 'hdeadbeef );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h004, "add x1 x0 x1"     ); //   F D X M W
  asm( 'h008, "lw x1 0(x1)"      ); //     F D X M W       (X-D)

  asm( 'h00c, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h010, "add x1 x0 x1"     ); //   F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h018, "lw x1 0(x1)"      ); //       F D X M W     (M-D)

  asm( 'h01c, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h020, "add x1 x0 x1"     ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h02c, "lw x1 0(x1)"      ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h034, "add x1 x0 x1"     ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "lw x1 0(x1)"      ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h000000fc );
  check_trace( 'h004, 'h000000fc );
  check_trace( 'h008, 'hdeadbeef );

  check_trace( 'h00c, 'h000000fc );
  check_trace( 'h010, 'h000000fc );
  check_trace( 'h014, 'h00000000 );
  check_trace( 'h018, 'hdeadbeef );

  check_trace( 'h01c, 'h000000fc );
  check_trace( 'h020, 'h000000fc );
  check_trace( 'h024, 'h00000000 );
  check_trace( 'h028, 'h00000000 );
  check_trace( 'h02c, 'hdeadbeef );

  check_trace( 'h030, 'h000000fc );
  check_trace( 'h034, 'h000000fc );
  check_trace( 'h038, 'h00000000 );
  check_trace( 'h03c, 'h00000000 );
  check_trace( 'h040, 'h00000000 );
  check_trace( 'h044, 'hdeadbeef );

endtask


//==========================================================
// LW: test_mul_lw
//==========================================================

task test_mul_lw();
  t.test_case_begin( "test_mul_lw" );

  // Data Memory

  data( 'h0fc, 'hbeefcafe );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h004, "addi x2 x0 0x0fc" ); //   F D X M W
  asm( 'h008, "mul x1 x1 x2"     ); //     F D X M W
  asm( 'h00c, "lw x1 0(x1)"      ); //       F D X M W       (X-D)

  asm( 'h010, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h014, "addi x2 x0 0x0fc" ); //   F D X M W
  asm( 'h018, "mul x1 x1 x2"     ); //     F D X M W
  asm( 'h01c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h020, "lw x1 0(x1)"      ); //         F D X M W     (M-D)

  asm( 'h024, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h028, "addi x2 x0 0x0fc" ); //   F D X M W
  asm( 'h02c, "mul x1 x1 x2"     ); //     F D X M W
  asm( 'h030, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h034, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h038, "lw x1 0(x1)"      ); //           F D X M W   (W-D)

  asm( 'h03c, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h040, "addi x2 x0 0x0fc" ); //   F D X M W
  asm( 'h044, "mul x1 x1 x2"     ); //     F D X M W
  asm( 'h048, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h04c, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h050, "add x0 x0 x0"     ); //           F D X M W
  asm( 'h054, "lw x1 0(x1)"      ); //             F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h00000001 );
  check_trace( 'h004, 'h000000fc );
  check_trace( 'h008, 'h000000fc );
  check_trace( 'h00c, 'hbeefcafe );

  check_trace( 'h010, 'h00000001 );
  check_trace( 'h014, 'h000000fc );
  check_trace( 'h018, 'h000000fc );
  check_trace( 'h01c, 'h00000000 );
  check_trace( 'h020, 'hbeefcafe );

  check_trace( 'h024, 'h00000001 );
  check_trace( 'h028, 'h000000fc );
  check_trace( 'h02c, 'h000000fc );
  check_trace( 'h030, 'h00000000 );
  check_trace( 'h034, 'h00000000 );
  check_trace( 'h038, 'hbeefcafe );

  check_trace( 'h03c, 'h00000001 );
  check_trace( 'h040, 'h000000fc );
  check_trace( 'h044, 'h000000fc );
  check_trace( 'h048, 'h00000000 );
  check_trace( 'h04c, 'h00000000 );
  check_trace( 'h050, 'h00000000 );
  check_trace( 'h054, 'hbeefcafe );

endtask

//==========================================================
// LW: test_lw_lw
//==========================================================

task test_lw_lw();
  t.test_case_begin( "test_lw_lw" );

  // Data Memory

  data( 'h0f8, 'h000000fc );
  data( 'h0fc, 'hfeedbeef );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0f8" ); // F D X M W
  asm( 'h004, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h008, "lw x3 0(x2)"      ); //     F D D X M W     (M-D)

  asm( 'h00c, "addi x1 x0 0x0f8" ); // F F D X M W
  asm( 'h010, "lw x2 0(x1)"      ); //     F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h018, "lw x3 0(x2)"      ); //         F D X M W   (M-D)

  asm( 'h01c, "addi x1 x0 0x0f8" ); // F D X M W
  asm( 'h020, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h02c, "lw x3 0(x2)"      ); //         F D X M W   (W-D)

  asm( 'h030, "addi x1 x0 0x0f8" ); // F D X M W
  asm( 'h034, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "lw x3 0(x2)"      ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h000000f8 );
  check_trace( 'h004, 'h000000fc );
  check_trace( 'x,    'x         );
  check_trace( 'h008, 'hfeedbeef );

  check_trace( 'h00c, 'h000000f8 );
  check_trace( 'h010, 'h000000fc );
  check_trace( 'h014, 'h00000000 );
  check_trace( 'h018, 'hfeedbeef );

  check_trace( 'h01c, 'h000000f8 );
  check_trace( 'h020, 'h000000fc );
  check_trace( 'h024, 'h00000000 );
  check_trace( 'h028, 'h00000000 );
  check_trace( 'h02c, 'hfeedbeef );

  check_trace( 'h030, 'h000000f8 );
  check_trace( 'h034, 'h000000fc );
  check_trace( 'h038, 'h00000000 );
  check_trace( 'h03c, 'h00000000 );
  check_trace( 'h040, 'h00000000 );
  check_trace( 'h044, 'hfeedbeef );

endtask

//==========================================================
// LW: test_sw_lw
//==========================================================

task test_sw_lw();
  t.test_case_begin( "test_sw_lw" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h004, "addi x2 x0 0x001" ); //   F D X M W
  asm( 'h008, "lw x3 0(x1)"      ); //     F D X M W
  asm( 'h00c, "sw x2 0(x1)"      ); //       F D X M W
  asm( 'h010, "lw x3 0(x1)"      ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0fc );
  check_trace( 'h004, 'h001 );
  check_trace( 'h008, 'x    );
  check_trace( 'h00c, 'x    );
  check_trace( 'h010, 'h001 );

endtask

//==========================================================
// LW: test_jal_lw
//==========================================================

task test_jal_lw();
  t.test_case_begin( "test_jal_lw" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004" ); // F D X M W
  asm( 'h004, "lw x2 0(x1)"  ); //   F F D X M W     (M-D)

  asm( 'h008, "jal x1 0x014" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h010, "add x0 x0 x0" ); //
  asm( 'h014, "lw x2 0(x1)"  ); //     F D X M W     (M-D)

  asm( 'h018, "jal x1 0x024" ); // F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h020, "add x0 x0 x0" ); //
  asm( 'h024, "add x0 x0 x0" ); //     F D X M W
  asm( 'h028, "lw x2 0(x1)"  ); //       F D X M W   (W-D)

  asm( 'h02c, "jal x1 0x038" ); // F D X M W
  asm( 'h030, "add x0 x0 x0" ); //   F - - - -
  asm( 'h034, "add x0 x0 x0" ); //
  asm( 'h038, "add x0 x0 x0" ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //       F D X M W
  asm( 'h040, "lw x2 0(x1)"  ); //         F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h004, tinyrv1.asm( 'h004, "lw x2 0(x1)" ) );

  check_trace( 'h008, 'h00c );
  check_trace( 'x,    'x    );
  check_trace( 'h014, tinyrv1.asm( 'h00c, "add x0 x0 x0") );

  check_trace( 'h018, 'h01c );
  check_trace( 'x,    'x    );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, tinyrv1.asm( 'h01c, "add x0 x0 x0") );

  check_trace( 'h02c, 'h030 );
  check_trace( 'x,    'x    );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, tinyrv1.asm( 'h030, "add x0 x0 x0") );

endtask