//==========================================================
// JAL: test_forward
//==========================================================

task test_forward();
  t.test_case_begin( "test_forward" );

  // Assembly Program

  asm( 'h000, "jal x1 0x010" ); // F D X M W
  asm( 'h004, "addi x2 x0 1" ); //   F - - - -
  asm( 'h008, "addi x3 x2 1" ); //
  asm( 'h00c, "addi x4 x3 1" ); //
  asm( 'h010, "jr x1"        ); //     F D X M W            (M-D)
  asm( 'h014, "add x0 x0 x0" ); //       F - - - -
  //   'h004   addi x2 x0 1     //         F D X M W
  //   'h008   addi x3 x2 1     //           F D X M W      (X-D)
  //   'h00c   addi x4 x3 1     //             F D X M W    (X-D)
  //   'h010   jr x1            //               F D X M W  (X-D)

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h010, 'x    );
  check_trace( 'x,    'x    );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h004, 'h001 );
    check_trace( 'h008, 'h002 );
    check_trace( 'h00c, 'h003 );
    check_trace( 'h010, 'x    );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JAL: test_backward
//==========================================================

task test_backward();
  t.test_case_begin( "test_backward");

  // Assembly Program

  asm( 'h000, "jal x0 0x014" ); // F D X M W
  asm( 'h004, "addi x1 x0 1" ); //   F - - - -
  asm( 'h008, "addi x2 x1 1" ); //
  asm( 'h00c, "addi x3 x2 1" ); //
  asm( 'h010, "jr x4"        ); //
  asm( 'h014, "jal x4 0x004" ); // F D X M W
  //   'h018  addi x1 x0 1      //   F - - - -
  //   'h004  addi x1 x0 1      //     F D X M W
  //   'h008  addi x2 x1 1      //       F D X M W       (X-D)
  //   'h00c  addi x3 x2 1      //         F D X M W     (X-D)
  //   'h010  jr x4             //           F D X M W
  //   'h014  jal x4 0x004      //             F - - - -
  asm( 'h018, "addi x1 x0 1" ); // F D X M W
  asm( 'h01c, "addi x2 x1 1" ); //   F D X M W           (X-D)
  asm( 'h020, "addi x3 x2 1" ); //     F D X M W         (X-D)
  asm( 'h024, "jal x0 0x000" ); //       F D X M W
  asm( 'h028, "add x0 x0 x0" ); //         F - - - -
  //   'h000   jal x0 0x014     //           F D X M W

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h000, 'h004 );
    check_trace( 'x,    'x    );
    check_trace( 'h014, 'h018 );
    check_trace( 'x,    'x    );

    check_trace( 'h004, 'h001 );
    check_trace( 'h008, 'h002 );
    check_trace( 'h00c, 'h003 );
    check_trace( 'h010, 'x    );
    check_trace( 'x,    'x    );

    check_trace( 'h018, 'h001 );
    check_trace( 'h01c, 'h002 );
    check_trace( 'h020, 'h003 );
    check_trace( 'h024, 'h028 );
    check_trace( 'x,    'x    );
  end

endtask

//==========================================================
// JAL/R: test_jal_jr_MD_1
//==========================================================

task test_jal_jr_MD_1();
  t.test_case_begin( "test_jal_jr_MD_1" );

  // Assembly Program

  asm( 'h000, "jal x1 0x004" ); // F D X M W
  asm( 'h004, "jr x1"        ); //   F F D X M W    (M-D)
  asm( 'h008, "add x0 x0 x0" ); //       F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h004, 'x );
    check_trace( 'x,    'x );
  end
  
endtask

//==========================================================
// JAL/R: test_jal_jr_MD_2
//==========================================================

task test_jal_jr_MD_2();
  t.test_case_begin( "test_jal_jr_MD_2" );

  // Assembly Program

  asm( 'h000, "jal x3 0x00c" ); // F D X M W
  asm( 'h004, "addi x1 x0 1" ); //   F - - - -
  asm( 'h008, "addi x2 x1 1" ); //
  asm( 'h00c, "jr x3"        ); //     F D X M W    (M-D)
  asm( 'h010, "add x0 x0 x0" ); //       F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h00c, 'x    );
  check_trace( 'x,    'x    );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h004, 'h001 );
    check_trace( 'h008, 'h002 );
    check_trace( 'h00c, 'x    );
    check_trace( 'x,    'x    );
  end
  
endtask

//==========================================================
// JAL/R: test_jal_jr_WD
//==========================================================

task test_jal_jr_WD();
  t.test_case_begin( "test_jal_jr_WD" );

  // Assembly Program

  asm( 'h000, "jal x3 0x00c" ); // F D X M W
  asm( 'h004, "addi x1 x0 1" ); //   F - - - -
  asm( 'h008, "addi x2 x1 1" ); //
  asm( 'h00c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h010, "jr x3"        ); //       F D X M W    (W-D)
  asm( 'h014, "add x0 x0 x0" ); //         F - - - -

  // Check Traces

  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );
  check_trace( 'x, 'x );

  check_trace( 'h000, 'h004 );
  check_trace( 'x,    'x    );
  check_trace( 'h00c, 'h000 );
  check_trace( 'h010, 'x    );
  check_trace( 'x,    'x    );

  for(int i = 0; i < 3; i++) begin
    check_trace( 'h004, 'h001 );
    check_trace( 'h008, 'h002 );
    check_trace( 'h00c, 'h000 );
    check_trace( 'h010, 'x    );
    check_trace( 'x,    'x    );
  end

endtask