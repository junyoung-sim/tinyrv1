//==========================================================
// ADD: test_simple
//==========================================================

task test_simple();
  t.test_case_begin( "test_simple" );

  asm( 'h000, "addi x1, x0, 2" ); // F D X M W
  asm( 'h004, "add x1, x1, x1" ); //   F D X M W

  check_trace( 'x,    'x         );
  check_trace( 'x,    'x         );
  check_trace( 'x,    'x         );
  check_trace( 'x,    'x         );
  check_trace( 'h000, 'h00000002 );
  check_trace( 'h004, 'h00000004 );

endtask