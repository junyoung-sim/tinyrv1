//==========================================================
// SW: test_sw_simple
//==========================================================

task test_sw_simple();
  t.test_case_begin( "test_sw_simple" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x080" );
  asm( 'h004, "addi x2 x0 0x001" );

  asm( 'h008, "lw x3 -8(x1)"     );
  asm( 'h00c, "sw x2 -8(x1)"     );
  asm( 'h010, "lw x3 -8(x1)"     );
  
  asm( 'h014, "lw x3 -4(x1)"     );
  asm( 'h018, "sw x2 -4(x1)"     );
  asm( 'h01c, "lw x3 -4(x1)"     );
  
  asm( 'h020, "lw x3 0(x1)"      );
  asm( 'h024, "sw x2 0(x1)"      );
  asm( 'h028, "lw x3 0(x1)"      );
  
  asm( 'h02c, "lw x3 4(x1)"      );
  asm( 'h030, "sw x2 4(x1)"      );
  asm( 'h034, "lw x3 4(x1)"      );
  
  asm( 'h038, "lw x3 8(x1)"      );
  asm( 'h03c, "sw x2 8(x1)"      );
  asm( 'h040, "lw x3 8(x1)"      );

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h080 );
  check_trace( 'h004, 'h001 );
  
  check_trace( 'h008, 'x    );
  check_trace( 'h00c, 'x    );
  check_trace( 'h010, 'h001 );
  
  check_trace( 'h014, 'x    );
  check_trace( 'h018, 'x    );
  check_trace( 'h01c, 'h001 );
  
  check_trace( 'h020, 'x    );
  check_trace( 'h024, 'x    );
  check_trace( 'h028, 'h001 );
  
  check_trace( 'h02c, 'x    );
  check_trace( 'h030, 'x    );
  check_trace( 'h034, 'h001 );
  
  check_trace( 'h038, 'x    );
  check_trace( 'h03c, 'x    );
  check_trace( 'h040, 'h001 );

endtask

//==========================================================
// SW: test_addi_sw
//==========================================================

task test_addi_sw();
  t.test_case_begin( "test_addi_sw" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0f0" ); // F D X M W
  asm( 'h004, "sw x1 0(x1)"      ); //   F D X M W       (X-D)

  asm( 'h008, "addi x2 x0 0x0f4" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h010, "sw x2 0(x2)"      ); //     F D X M W     (M-D)

  asm( 'h014, "addi x3 x0 0x0f8" ); // F D X M W
  asm( 'h018, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h01c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h020, "sw x3 0(x3)"      ); //       F D X M W   (W-D)

  asm( 'h024, "addi x4 x0 0x0fc" ); // F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h030, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h034, "sw x4 0(x4)"      ); //         F D X M W

  asm( 'h038, "lw x5 0(x1)"      );
  asm( 'h03c, "lw x6 0(x2)"      );
  asm( 'h040, "lw x7 0(x3)"      );
  asm( 'h044, "lw x8 0(x4)"      );

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0f0 );
  check_trace( 'h004, 'x    );

  check_trace( 'h008, 'h0f4 );
  check_trace( 'h00c, 'h000 );
  check_trace( 'h010, 'x    );

  check_trace( 'h014, 'h0f8 );
  check_trace( 'h018, 'h000 );
  check_trace( 'h01c, 'h000 );
  check_trace( 'h020, 'x    );

  check_trace( 'h024, 'h0fc );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'h000 );
  check_trace( 'h030, 'h000 );
  check_trace( 'h034, 'x    );

  check_trace( 'h038, 'h0f0 );
  check_trace( 'h03c, 'h0f4 );
  check_trace( 'h040, 'h0f8 );
  check_trace( 'h044, 'h0fc );

endtask

//==========================================================
// SW: test_add_sw
//==========================================================

task test_add_sw();
  t.test_case_begin( "test_add_sw" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0f0" ); // F D X M W
  asm( 'h004, "add x1 x0 x1"     ); //   F D X M W
  asm( 'h008, "sw x1 0(x1)"      ); //     F D X M W       (X-D)

  asm( 'h00c, "addi x2 x0 0x0f4" ); // F D X M W
  asm( 'h010, "add x2 x0 x2"     ); //   F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h018, "sw x2 0(x2)"      ); //       F D X M W     (M-D)

  asm( 'h01c, "addi x3 x0 0x0f8" ); // F D X M W
  asm( 'h020, "add x3 x0 x3"     ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h02c, "sw x3 0(x3)"      ); //         F D X M W   (W-D)

  asm( 'h030, "addi x4 x0 0x0fc" ); // F D X M W
  asm( 'h034, "add x4 x0 x4"     ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "sw x4 0(x4)"      ); //           F D X M W

  asm( 'h048, "lw x5 0(x1)"      );
  asm( 'h04c, "lw x6 0(x2)"      );
  asm( 'h050, "lw x7 0(x3)"      );
  asm( 'h054, "lw x8 0(x4)"      );

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0f0 );
  check_trace( 'h004, 'h0f0 );
  check_trace( 'h008, 'x    );

  check_trace( 'h00c, 'h0f4 );
  check_trace( 'h010, 'h0f4 );
  check_trace( 'h014, 'h000 );
  check_trace( 'h018, 'x    );

  check_trace( 'h01c, 'h0f8 );
  check_trace( 'h020, 'h0f8 );
  check_trace( 'h024, 'h000 );
  check_trace( 'h028, 'h000 );
  check_trace( 'h02c, 'x    );

  check_trace( 'h030, 'h0fc );
  check_trace( 'h034, 'h0fc );
  check_trace( 'h038, 'h000 );
  check_trace( 'h03c, 'h000 );
  check_trace( 'h040, 'h000 );
  check_trace( 'h044, 'x    );

  check_trace( 'h048, 'h0f0 );
  check_trace( 'h04c, 'h0f4 );
  check_trace( 'h050, 'h0f8 );
  check_trace( 'h054, 'h0fc );

endtask

//==========================================================
// SW: test_mul_sw
//==========================================================

task test_mul_sw();
  t.test_case_begin( "test_mul_sw" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1"     ); // F D X M W
  asm( 'h004, "addi x2 x0 0x0f0" ); //   F D X M W
  asm( 'h008, "mul x3 x1 x2"     ); //     F D X M W
  asm( 'h00c, "sw x3 0(x3)"      ); //       F D X M W       (X-D)

  asm( 'h010, "addi x1 x0 1"     ); // F D X M W
  asm( 'h014, "addi x2 x0 0x0f4" ); //   F D X M W
  asm( 'h018, "mul x4 x1 x2"     ); //     F D X M W
  asm( 'h01c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h020, "sw x4 0(x4)"      ); //         F D X M W     (M-D)

  asm( 'h024, "addi x1 x0 1"     ); // F D X M W
  asm( 'h028, "addi x2 x0 0x0f8" ); //   F D X M W
  asm( 'h02c, "mul x5 x1 x2"     ); //     F D X M W
  asm( 'h030, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h034, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h038, "sw x5 0(x5)"      ); //           F D X M W   (W-D)

  asm( 'h03c, "addi x1 x0 1"     ); // F D X M W
  asm( 'h040, "addi x2 x0 0x0fc" ); //   F D X M W
  asm( 'h044, "mul x6 x1 x2"     ); //     F D X M W
  asm( 'h048, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h04c, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h050, "add x0 x0 x0"     ); //           F D X M W
  asm( 'h054, "sw x6 0(x6)"      ); //             F D X M W

  asm( 'h058, "lw x7 0(x3)"      );
  asm( 'h05c, "lw x8 0(x4)"      );
  asm( 'h060, "lw x9 0(x5)"      );
  asm( 'h064, "lw x10 0(x6)"     );

  // Check Trace

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h001 );
  check_trace( 'h004, 'h0f0 );
  check_trace( 'h008, 'h0f0 );
  check_trace( 'h00c, 'x    );

  check_trace( 'h010, 'h001 );
  check_trace( 'h014, 'h0f4 );
  check_trace( 'h018, 'h0f4 );
  check_trace( 'h01c, 'h000 );
  check_trace( 'h020, 'x    );

  check_trace( 'h024, 'h001 );
  check_trace( 'h028, 'h0f8 );
  check_trace( 'h02c, 'h0f8 );
  check_trace( 'h030, 'h000 );
  check_trace( 'h034, 'h000 );
  check_trace( 'h038, 'x    );

  check_trace( 'h03c, 'h001 );
  check_trace( 'h040, 'h0fc );
  check_trace( 'h044, 'h0fc );
  check_trace( 'h048, 'h000 );
  check_trace( 'h04c, 'h000 );
  check_trace( 'h050, 'h000 );
  check_trace( 'h054, 'x    );

  check_trace( 'h058, 'h0f0 );
  check_trace( 'h05c, 'h0f4 );
  check_trace( 'h060, 'h0f8 );
  check_trace( 'h064, 'h0fc );

endtask

//==========================================================
// SW: test_lw_sw
//==========================================================

task test_lw_sw();
  t.test_case_begin( "test_lw_sw" );

  // Data Memory

  data( 'h0f0, 'h000 );
  data( 'h0f4, 'h004 );
  data( 'h0f8, 'h008 );
  data( 'h0fc, 'h00c );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0f0" ); // F D X M W
  asm( 'h004, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h008, "sw x2 0(x2)"      ); //     F D D X M W       (M-D)
  asm( 'h00c, "lw x3 0(x2)"      ); //       F F D X M W

  asm( 'h010, "addi x1 x0 0x0f4" ); // F D X M W
  asm( 'h014, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h018, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h01c, "sw x2 0(x2)"      ); //       F D X M W       (M-D)
  asm( 'h020, "lw x3 0(x2)"      ); //         F D X M W

  asm( 'h024, "addi x1 x0 0x0f8" ); // F D X M W
  asm( 'h028, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h030, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h034, "sw x2 0(x2)"      ); //         F D X M W     (W-D)
  asm( 'h038, "lw x3 0(x2)"      ); //           F D X M W

  asm( 'h03c, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h040, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h044, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h048, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h04c, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h050, "sw x2 0(x2)"      ); //           F D X M W
  asm( 'h054, "lw x3 0(x2)"      ); //             F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h0f0 );
  check_trace( 'h004, 'h000 );
  check_trace( 'x,    'x    );
  check_trace( 'h008, 'x    );
  check_trace( 'h00c, 'h000 );

  check_trace( 'h010, 'h0f4 );
  check_trace( 'h014, 'h004 );
  check_trace( 'h018, 'h000 );
  check_trace( 'h01c, 'x    );
  check_trace( 'h020, 'h004 );

  check_trace( 'h024, 'h0f8 );
  check_trace( 'h028, 'h008 );
  check_trace( 'h02c, 'h000 );
  check_trace( 'h030, 'h000 );
  check_trace( 'h034, 'x    );
  check_trace( 'h038, 'h008 );

  check_trace( 'h03c, 'h0fc );
  check_trace( 'h040, 'h00c );
  check_trace( 'h044, 'h000 );
  check_trace( 'h048, 'h000 );
  check_trace( 'h04c, 'h000 );
  check_trace( 'h050, 'x    );
  check_trace( 'h054, 'h00c );

endtask

task test_jal_sw();
  t.test_case_begin( "test_jal_sw" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004" ); // F D X M W
  asm( 'h004, "sw x1 0(x1)"  ); //   F F D X M W       (M-D)
  asm( 'h008, "lw x2 0(x1)"  ); //       F D X M W

  asm( 'h00c, "jal x1 0x018" ); // F D X M W
  asm( 'h010, "add x0 x0 x0" ); //   F - - - -
  asm( 'h014, "add x0 x0 x0" ); //
  asm( 'h018, "sw x1 0(x1)"  ); //     F D X M W       (M-D)
  asm( 'h01c, "lw x2 0(x1)"  ); //       F D X M W

  asm( 'h020, "jal x1 0x02c" ); // F D X M W
  asm( 'h024, "add x0 x0 x0" ); //   F - - - -
  asm( 'h028, "add x0 x0 x0" ); //
  asm( 'h02c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h030, "sw x1 0(x1)"  ); //       F D X M W     (W-D)
  asm( 'h034, "lw x2 0(x1)"  ); //         F D X M W

  asm( 'h038, "jal x1 0x044" ); // F D X M W
  asm( 'h03c, "add x0 x0 x0" ); //   F - - - -
  asm( 'h040, "add x0 x0 x0" ); //
  asm( 'h044, "add x0 x0 x0" ); //     F D X M W
  asm( 'h048, "add x0 x0 x0" ); //       F D X M W
  asm( 'h04c, "sw x1 0(x1)"  ); //         F D X M W
  asm( 'h050, "lw x2 0(x1)"  ); //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h004, 'x    );
  check_trace( 'h008, 'h004 );

  check_trace( 'h00c, 'h010 );
  check_trace( 'x,    'x    );
  check_trace( 'h018, 'x    );
  check_trace( 'h01c, 'h010 );

  check_trace( 'h020, 'h024 );
  check_trace( 'x,    'x    );
  check_trace( 'h02c, 'h000 );
  check_trace( 'h030, 'x    );
  check_trace( 'h034, 'h024 );

  check_trace( 'h038, 'h03c );
  check_trace( 'x,    'x    );
  check_trace( 'h044, 'h000 );
  check_trace( 'h048, 'h000 );
  check_trace( 'h04c, 'x    );
  check_trace( 'h050, 'h03c );

endtask