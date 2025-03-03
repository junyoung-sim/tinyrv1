//==========================================================
// JR: test_jr_simple
//==========================================================

task test_jr_simple();
  t.test_case_begin( "test_jr_simple" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x014" ); // F D X M W
  asm( 'h004, "jr x1"            ); //   F D X M W           (X-D)
  asm( 'h008, "add x0 x0 x0"     ); //     F - - - -
  asm( 'h00c, "add x0 x0 x0"     ); //
  asm( 'h010, "add x0 x0 x0"     ); //
  asm( 'h014, "addi x1 x0 0x000" ); //       F D X M W
  asm( 'h018, "jr x1"            ); //         F D X M W     (X-D)
  asm( 'h01c, "add x0 x0 x0"     ); //           F - - - -
  //           addi x1 x0 0x014     //             F D X M W
  //                   ...          //                ...

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h014 );
    check_trace( 'h004, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JR: test_addi_jr
//==========================================================

task test_addi_jr();
  t.test_case_begin( "test_addi_jr" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x010" ); // F D X M W
  asm( 'h004, "jr x1"            ); //   F D X M W           (X-D)
  asm( 'h008, "add x0 x0 x0"     ); //     F - - - -
  asm( 'h00c, "add x0 x0 x0"     ); //

  asm( 'h010, "addi x1 x0 0x024" ); // F D X M W
  asm( 'h014, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h018, "jr x1"            ); //     F D X M W         (M-D)
  asm( 'h01c, "add x0 x0 x0"     ); //       F - - - -
  asm( 'h020, "add x0 x0 x0"     ); //

  asm( 'h024, "addi x1 x0 0x03c" ); // F D X M W
  asm( 'h028, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h030, "jr x1"            ); //       F D X M W       (W-D)
  asm( 'h034, "add x0 x0 x0"     ); //         F - - - -
  asm( 'h038, "add x0 x0 x0"     ); //

  asm( 'h03c, "addi x1 x0 0x000" ); // F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //   F D X M W
  asm( 'h044, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h048, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h04c, "jr x1"            ); //         F D X M W
  asm( 'h050, "add x0 x0 x0"     ); //           F - - - -
  //           addi x1 x0 0x010     //             F D X M W
  //                   ...          //                ...

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h010 );
    check_trace( 'h004, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h010, 'h024 );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h024, 'h03c );
    check_trace( 'h028, 'h000 );
    check_trace( 'h02c, 'h000 );
    check_trace( 'h030, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h03c, 'h000 );
    check_trace( 'h040, 'h000 );
    check_trace( 'h044, 'h000 );
    check_trace( 'h048, 'h000 );
    check_trace( 'h04c, 'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JR: test_add_jr
//==========================================================

task test_add_jr();
  t.test_case_begin( "test_add_jr" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x014" ); // F D X M W
  asm( 'h004, "add x1 x0 x1"     ); //   F D X M W             (X-D)
  asm( 'h008, "jr x1"            ); //     F D X M W           (X-D)
  asm( 'h00c, "add x0 x0 x0"     ); //       F - - - -
  asm( 'h010, "add x0 x0 x0"     ); //

  asm( 'h014, "addi x1 x0 0x02c" ); // F D X M W
  asm( 'h018, "add x1 x0 x1"     ); //   F D X M W             (X-D)
  asm( 'h01c, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h020, "jr x1"            ); //       F D X M W         (M-D)
  asm( 'h024, "add x0 x0 x0"     ); //         F - - - -
  asm( 'h028, "add x0 x0 x0"     ); //

  asm( 'h02c, "addi x1 x0 0x048" ); // F D X M W
  asm( 'h030, "add x1 x0 x1"     ); //   F D X M W             (X-D)
  asm( 'h034, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h038, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h03c, "jr x1"            ); //         F D X M W       (W-D)
  asm( 'h040, "add x0 x0 x0"     ); //           F - - - -
  asm( 'h044, "add x0 x0 x0"     ); //

  asm( 'h048, "addi x1 x0 0x000" ); // F D X M W
  asm( 'h04c, "add x1 x0 x1"     ); //   F D X M W             (X-D)
  asm( 'h050, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h054, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h058, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h05c, "jr x1"            ); //           F D X M W
  asm( 'h060, "add x0 x0 x0"     ); //             F - - - -
  //           addi x1 x0 0x014     //               F D X M W
  //                 ...            //                  ...

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h014 );
    check_trace( 'h004, 'h014 );
    check_trace( 'h008, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h014, 'h02c );
    check_trace( 'h018, 'h02c );
    check_trace( 'h01c, 'h000 );
    check_trace( 'h020, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h02c, 'h048 );
    check_trace( 'h030, 'h048 );
    check_trace( 'h034, 'h000 );
    check_trace( 'h038, 'h000 );
    check_trace( 'h03c, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h048, 'h000 );
    check_trace( 'h04c, 'h000 );
    check_trace( 'h050, 'h000 );
    check_trace( 'h054, 'h000 );
    check_trace( 'h058, 'h000 );
    check_trace( 'h05c, 'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JR: test_mul_jr
//==========================================================

task test_mul_jr();
  t.test_case_begin( "test_mul_jr" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h004, "addi x2 x0 0x018" ); //   F D X M W
  asm( 'h008, "mul x1 x1 x2"     ); //     F D X M W    (M-D, X-D)
  asm( 'h00c, "jr x1"            ); //       F D X M W       (X-D)
  asm( 'h010, "add x0 x0 x0"     ); //         F - - - -
  asm( 'h014, "add x0 x0 x0"     ); //

  asm( 'h018, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h01c, "addi x2 x0 0x034" ); //   F D X M W
  asm( 'h020, "mul x1 x1 x2"     ); //     F D X M W    (M-D, X-D)
  asm( 'h024, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h028, "jr x1"            ); //         F D X M W     (M-D)
  asm( 'h02c, "add x0 x0 x0"     ); //           F - - - -
  asm( 'h030, "add x0 x0 x0"     ); //

  asm( 'h034, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h038, "addi x2 x0 0x054" ); //   F D X M W
  asm( 'h03c, "mul x1 x1 x2"     ); //     F D X M W    (M-D, X-D)
  asm( 'h040, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h044, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h048, "jr x1"            ); //           F D X M W   (W-D)
  asm( 'h04c, "add x0 x0 x0"     ); //             F - - - -
  asm( 'h050, "add x0 x0 x0"     ); //

  asm( 'h054, "addi x1 x0 0x001" ); // F D X M W
  asm( 'h058, "addi x2 x0 0x000" ); //   F D X M W
  asm( 'h05c, "mul x1 x1 x2"     ); //     F D X M W    (M-D, X-D)
  asm( 'h060, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h064, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h068, "add x0 x0 x0"     ); //           F D X M W
  asm( 'h06c, "jr x1"            ); //             F D X M W
  asm( 'h070, "add x0 x0 x0"     ); //               F - - - -
  //          addi x1 x0 0x001      //                 F D X M W
  //          addi x2 x0 0x018      //                   F D X M W
  //                    ...         //                      ...

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h001 );
    check_trace( 'h004, 'h018 );
    check_trace( 'h008, 'h018 );
    check_trace( 'h00c, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h018, 'h001 );
    check_trace( 'h01c, 'h034 );
    check_trace( 'h020, 'h034 );
    check_trace( 'h024, 'h000 );
    check_trace( 'h028, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h034, 'h001 );
    check_trace( 'h038, 'h054 );
    check_trace( 'h03c, 'h054 );
    check_trace( 'h040, 'h000 );
    check_trace( 'h044, 'h000 );
    check_trace( 'h048, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h054, 'h001 );
    check_trace( 'h058, 'h000 );
    check_trace( 'h05c, 'h000 );
    check_trace( 'h060, 'h000 );
    check_trace( 'h064, 'h000 );
    check_trace( 'h068, 'h000 );
    check_trace( 'h06c, 'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JR: test_lw_jr
//==========================================================

task test_lw_jr();
  t.test_case_begin( "test_lw_jr" );

  // Data Memory

  data( 'h0f0, 'h020 );
  data( 'h0f4, 'h00c );
  data( 'h0f8, 'h030 );
  data( 'h0fc, 'h000 );
  
  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0f0" ); // F D X M W
  asm( 'h004, "lw x2 0(x1)"      ); //   F D X M W            (X-D)
  asm( 'h008, "jr x2"            ); //     F D D X M W        (M-D)
  //   'h00c   addi x1 x0 0x0f8     //       F F - - - -
  //   'h020   addi x1 x0 0x0f4     //           F D X M W

  asm( 'h00c, "addi x1 x0 0x0f8" ); // F D X M W
  asm( 'h010, "lw x2 0(x1)"      ); //   F D X M W            (X-D)
  asm( 'h014, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h018, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h01c, "jr x2"            ); //         F D X M W      (W-D)
  //   'h020   addi x1 x0 0x0f4     //           F - - - -
  //   'h030   addi x1 x0 0x0fc     //             F D X M W

  asm( 'h020, "addi x1 x0 0x0f4" ); // F D X M W
  asm( 'h024, "lw x2 0(x1)"      ); //   F D X M W            (X-D)
  asm( 'h028, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h02c, "jr x2"            ); //       F D X M W        (M-D)
  //   'h030   addi x1 x0 0x0fc     //         F - - - -
  //   'h00c   addi x1 x0 0x0f8     //           F D X M W

  asm( 'h030, "addi x1 x0 0x0fc" ); // F D X M W
  asm( 'h034, "lw x2 0(x1)"      ); //   F D X M W            (X-D)
  asm( 'h038, "add x0 x0 x0"     ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"     ); //       F D X M W
  asm( 'h040, "add x0 x0 x0"     ); //         F D X M W
  asm( 'h044, "jr x2"            ); //           F D X M W
  asm( 'h048, "add x0 x0 x0"     ); //             F - - - -
  //   'h000   addi x1 x0 0x0f0     //               F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h0f0 );
    check_trace( 'h004, 'h020 );
    check_trace( 'x,    'x    );
    check_trace( 'h008, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h020, 'h0f4 );
    check_trace( 'h024, 'h00c );
    check_trace( 'h028, 'h000 );
    check_trace( 'h02c, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h00c, 'h0f8 );
    check_trace( 'h010, 'h030 );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'h000 );
    check_trace( 'h01c, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h030, 'h0fc );
    check_trace( 'h034, 'h000 );
    check_trace( 'h038, 'h000 );
    check_trace( 'h03c, 'h000 );
    check_trace( 'h040, 'h000 );
    check_trace( 'h044, 'x    );
    check_trace( 'x,    'x    );
  end

endtask