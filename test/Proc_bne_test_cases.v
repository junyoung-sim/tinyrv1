//==========================================================
// BNE: test_forward
//==========================================================

task test_forward();
  t.test_case_begin( "test_forward" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0"    ); // F D X M W
  asm( 'h004, "bne x0 x1 0x024" ); //   F D X M W              (X-D)
  asm( 'h008, "addi x1 x0 1"    ); //     F D X M W
  asm( 'h00c, "bne x0 x1 0x024" ); //       F D X M W          (X-D)
  asm( 'h010, "add x0 x0 x0"    ); //         F D - - -
  asm( 'h014, "add x0 x0 x0"    ); //           F - - - -
  asm( 'h018, "add x0 x0 x0"    ); //
  asm( 'h01c, "add x0 x0 x0"    ); //
  asm( 'h020, "add x0 x0 x0"    ); //
  asm( 'h024, "jal x0 0x000"    ); //             F D X M W
  asm( 'h028, "add x0 x0 x0"    ); //               F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h000 );
    check_trace( 'h004, 'x    );
    check_trace( 'h008, 'h001 );
    check_trace( 'h00c, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
    check_trace( 'h024, 'h028 );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_backward
//==========================================================

task test_backward();
  t.test_case_begin( "test_backward" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0"    ); // F D X M W
  asm( 'h004, "bne x0 x1 0x000" ); //   F D X M W          (X-D)
  asm( 'h008, "addi x1 x0 1"    ); //     F D X M W
  asm( 'h00c, "bne x0 x1 0x000" ); //       F D X M W      (X-D)
  asm( 'h010, "add x0 x0 x0"    ); //         F D - - -
  asm( 'h014, "add x0 x0 x0"    ); //           F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h000 );
    check_trace( 'h004, 'x    );
    check_trace( 'h008, 'h001 );
    check_trace( 'h00c, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_squash_jump
//==========================================================

task test_squash_jump();
  t.test_case_begin( "test_squash_jump" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1"     ); // F D X M W
  asm( 'h004, "bne x0 x1 0x018"  ); //   F D X M W                (X-D)
  asm( 'h008, "jal x0 0x008"     ); //     F D - - -
  asm( 'h00c, "add x0 x0 x0"     ); //       F - - - -
  asm( 'h010, "add x0 x0 x0"     ); //
  asm( 'h014, "add x0 x0 x0"     ); //
  asm( 'h018, "addi x1 x0 1"     ); //         F D X M W
  asm( 'h01c, "addi x2 x0 0x024" ); //           F D X M W
  asm( 'h020, "bne x0 x1 0x000"  ); //             F D X M W      (X-D)
  asm( 'h024, "jr x2"            ); //               F D - - -
  asm( 'h028, "add x0 x0 x0"     ); //                 F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h001 );
    check_trace( 'h004, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
    check_trace( 'h018, 'h001 );
    check_trace( 'h01c, 'h024 );
    check_trace( 'h020, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_branch_squashed
//==========================================================

task test_branch_squashed();
  t.test_case_begin( "test_branch_squashed" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1"    ); // F D X M W
  asm( 'h004, "bne x0 x1 0x008" ); //   F D X M W         (X-D)
  asm( 'h008, "jal x0 0x014"    ); //     F D - - -
  asm( 'h00c, "add x0 x0 x0"    ); //       F - - - -
  //   0x008   jal x0 0x014        //         F D X M W
  //   0x00c   add x0 x0 x0        //           F - - - -

  asm( 'h010, "add x0 x0 x0"    ); //
  asm( 'h014, "bne x0 x1 0x01c" ); // F D X M W
  asm( 'h018, "add x0 x0 x0"    ); //   F D - - -
  asm( 'h01c, "jal x0 0x000"    ); //     F F D X M W
  asm( 'h020, "add x0 x0 x0"    ); //         F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h001 );
    check_trace( 'h004, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
    check_trace( 'h008, 'h00c );
    check_trace( 'x,    'x    );
    check_trace( 'h014, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
    check_trace( 'h01c, 'h020 );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_addi_bne
//==========================================================

task test_addi_bne();
  t.test_case_begin( "test_addi_bne" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0"    ); // F D X M W
  asm( 'h004, "addi x2 x0 0"    ); //   F D X M W
  asm( 'h008, "bne x1 x2 0x000" ); //     F D X M W      (M-D, X-D)

  asm( 'h00c, "addi x1 x0 0"    ); // F D X M W
  asm( 'h010, "addi x2 x0 0"    ); //   F D X M W
  asm( 'h014, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h018, "bne x1 x2 0x000" ); //       F D X M W    (W-D, M-D)

  asm( 'h01c, "addi x1 x0 0"    ); // F D X M W
  asm( 'h020, "addi x2 x0 0"    ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h02c, "bne x1 x2 0x000" ); //         F D X M W  (---, W-D)

  asm( 'h030, "addi x2 x0 1"    ); // F D X M W
  asm( 'h034, "add x0 x0 x0"    ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h03c, "addi x1 x0 0"    ); //       F D X M W
  asm( 'h040, "bne x1 x2 0x000" ); //         F D X M W  (X-D, ---)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h000 );
    check_trace( 'h004, 'h000 );
    check_trace( 'h008, 'x    );

    check_trace( 'h00c, 'h000 );
    check_trace( 'h010, 'h000 );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'x    );

    check_trace( 'h01c, 'h000 );
    check_trace( 'h020, 'h000 );
    check_trace( 'h024, 'h000 );
    check_trace( 'h028, 'h000 );
    check_trace( 'h02c, 'x    );

    check_trace( 'h030, 'h001 );
    check_trace( 'h034, 'h000 );
    check_trace( 'h038, 'h000 );
    check_trace( 'h03c, 'h000 );
    check_trace( 'h040, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_add_bne
//==========================================================

task test_add_bne();
  t.test_case_begin( "test_add_bne" );

  // Assembly Program

  asm( 'h000, "add x1 x0 x0"    ); // F D X M W
  asm( 'h004, "add x2 x0 x0"    ); //   F D X M W
  asm( 'h008, "bne x1 x2 0x000" ); //     F D X M W        (M-D, X-D)

  asm( 'h00c, "add x1 x0 x0"    ); // F D X M W
  asm( 'h010, "add x2 x0 x0"    ); //   F D X M W
  asm( 'h014, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h018, "bne x1 x2 0x000" ); //       F D X M W      (W-D, M-D)

  asm( 'h01c, "add x1 x0 x0"    ); // F D X M W
  asm( 'h020, "add x2 x0 x0"    ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h02c, "bne x1 x2 0x000" ); //         F D X M W    (---, W-D)

  asm( 'h030, "addi x1 x0 1"    ); // F D X M W
  asm( 'h034, "add x2 x0 x0"    ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h040, "add x1 x0 x1"    ); //         F D X M W
  asm( 'h044, "bne x1 x2 0x000" ); //           F D X M W  (X-D, ---)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h000 );
    check_trace( 'h004, 'h000 );
    check_trace( 'h008, 'x    );

    check_trace( 'h00c, 'h000 );
    check_trace( 'h010, 'h000 );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'x    );

    check_trace( 'h01c, 'h000 );
    check_trace( 'h020, 'h000 );
    check_trace( 'h024, 'h000 );
    check_trace( 'h028, 'h000 );
    check_trace( 'h02c, 'x    );

    check_trace( 'h030, 'h001 );
    check_trace( 'h034, 'h000 );
    check_trace( 'h038, 'h000 );
    check_trace( 'h03c, 'h000 );
    check_trace( 'h040, 'h001 );
    check_trace( 'h044, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_mul_bne
//==========================================================

task test_mul_bne();
  t.test_case_begin( "test_mul_bne" );

  asm( 'h000, "mul x1 x0 x0"    ); // F D X M W
  asm( 'h004, "mul x2 x0 x0"    ); //   F D X M W
  asm( 'h008, "bne x1 x2 0x000" ); //     F D X M W        (M-D, X-D)

  asm( 'h00c, "mul x1 x0 x0"    ); // F D X M W
  asm( 'h010, "mul x2 x0 x0"    ); //   F D X M W
  asm( 'h014, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h018, "bne x1 x2 0x000" ); //       F D X M W      (W-D, M-D)

  asm( 'h01c, "mul x1 x0 x0"    ); // F D X M W
  asm( 'h020, "mul x2 x0 x0"    ); //   F D X M W
  asm( 'h024, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h028, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h02c, "bne x1 x2 0x000" ); //         F D X M W    (---, W-D)

  asm( 'h030, "addi x1 x0 1"    ); // F D X M W
  asm( 'h034, "mul x2 x0 x0"    ); //   F D X M W
  asm( 'h038, "add x0 x0 x0"    ); //     F D X M W
  asm( 'h03c, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h040, "mul x1 x1 x1"    ); //         F D X M W
  asm( 'h044, "bne x1 x2 0x000" ); //           F D X M W  (X-D, ---)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h000 );
    check_trace( 'h004, 'h000 );
    check_trace( 'h008, 'x    );

    check_trace( 'h00c, 'h000 );
    check_trace( 'h010, 'h000 );
    check_trace( 'h014, 'h000 );
    check_trace( 'h018, 'x    );

    check_trace( 'h01c, 'h000 );
    check_trace( 'h020, 'h000 );
    check_trace( 'h024, 'h000 );
    check_trace( 'h028, 'h000 );
    check_trace( 'h02c, 'x    );

    check_trace( 'h030, 'h001 );
    check_trace( 'h034, 'h000 );
    check_trace( 'h038, 'h000 );
    check_trace( 'h03c, 'h000 );
    check_trace( 'h040, 'h001 );
    check_trace( 'h044, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_lw_bne
//==========================================================

task test_lw_bne();
  t.test_case_begin( "test_lw_bne" );

  // Data Memory

  data( 'h0a0, 'h000 );
  data( 'h0b0, 'h001 );

  // Assembly Program

  asm( 'h000, "addi x1 x0 0x0a0" ); // F D X M W
  asm( 'h004, "lw x2 0(x1)"      ); //   F D X M W
  asm( 'h008, "lw x3 0(x1)"      ); //     F D X M W
  asm( 'h00c, "bne x2 x3 0x000"  ); //       F D D X M W         (W-D, M-D)

  asm( 'h010, "addi x1 x0 0x0a0" ); // F F D X M W
  asm( 'h014, "addi x2 x0 0x0b0" ); //     F D X M W
  asm( 'h018, "lw x4 0(x2)"      ); //       F D X M W
  asm( 'h01c, "lw x3 0(x1)"      ); //         F D X M W
  asm( 'h020, "bne x3 x4 0x000"  ); //           F D D X M W     (M-D, W-D)
  asm( 'h024, "add x0 x0 x0"     ); //             F F D - - -
  asm( 'h028, "add x0 x0 x0"     ); //                 F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h0a0 );
    check_trace( 'h004, 'h000 );
    check_trace( 'h008, 'h000 );
    check_trace( 'x,    'x    );
    check_trace( 'h00c, 'x    );

    check_trace( 'h010, 'h0a0 );
    check_trace( 'h014, 'h0b0 );
    check_trace( 'h018, 'h001 );
    check_trace( 'h01c, 'h000 );
    check_trace( 'x,    'x    );
    check_trace( 'h020, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// BNE: test_jal_bne
//==========================================================

task test_jal_bne();
  t.test_case_begin( "test_jal_bne" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004"    ); // F D X M W
  asm( 'h004, "bne x1 x1 0x000" ); //   F F D X M W     (M-D)

  asm( 'h008, "jal x2 0x00c"    ); // F D X M W
  asm( 'h00c, "add x0 x0 x0"    ); //   F F D X M W
  asm( 'h010, "bne x2 x2 0x000" ); //       F D X M W   (W-D)

  asm( 'h014, "jal x3 0x018"    ); // F D X M W
  asm( 'h018, "add x0 x0 x0"    ); //   F F D X M W
  asm( 'h01c, "add x0 x0 x0"    ); //       F D X M W
  asm( 'h020, "bne x3 x3 0x000" ); //         F D X M W

  asm( 'h024, "bne x0 x3 0x000" ); // F D X M W
  asm( 'h028, "add x0 x0 x0"    ); //   F D - - -
  asm( 'h02c, "add x0 x0 x0"    ); //     F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h004 );
    check_trace( 'x,    'x    );
    check_trace( 'h004, 'x    );

    check_trace( 'h008, 'h00c );
    check_trace( 'x,    'x    );
    check_trace( 'h00c, 'h000 );
    check_trace( 'h010, 'x    );

    check_trace( 'h014, 'h018 );
    check_trace( 'x,    'x    );
    check_trace( 'h018, 'h000 );
    check_trace( 'h01c, 'h000 );
    check_trace( 'h020, 'x    );

    check_trace( 'h024, 'x    );
    check_trace( 'x,    'x    );
    check_trace( 'x,    'x    );
  end

endtask