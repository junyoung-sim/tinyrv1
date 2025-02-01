//==========================================================
// ADD: test_addi_add
//==========================================================

task test_addi_add();
  t.test_case_begin( "test_addi_add" );

  // Assembly Program

  asm( 'h000, "addi x1 x0 1" ); // F D X M W
  asm( 'h004, "add x2 x1 x1" ); //   F D X M W       (X-D)
  
  asm( 'h008, "addi x1 x0 1" ); // F D X M W
  asm( 'h00c, "add x0 x0 x0" ); //   F D X M W
  asm( 'h010, "add x2 x1 x1" ); //     F D X M W     (M-D)
  
  asm( 'h014, "addi x1 x0 1" ); // F D X M W
  asm( 'h018, "add x0 x0 x0" ); //   F D X M W
  asm( 'h01c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h020, "add x2 x1 x1" ); //       F D X M W   (W-D)

  asm( 'h024, "addi x1 x0 1" ); // F D X M W
  asm( 'h028, "add x0 x0 x0" ); //   F D X M W
  asm( 'h02c, "add x0 x0 x0" ); //     F D X M W
  asm( 'h030, "add x0 x0 x0" ); //       F D X M W
  asm( 'h034, "add x2 x1 x1" ); //         F D X M W

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

/*

//===========================================================
// ADD: test_add_add
//===========================================================

@cocotb.test()
async def test_add_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "addi x1 x0 1") // F D X M W
  asm( 0x004, "add x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x008, "add x1 x1 x1") //     F D X M W      (X-D)

  asm( 0x00c, "addi x1 x0 1") // F D X M W
  asm( 0x010, "add x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x014, "add x0 x0 x0") //     F D X M W
  asm( 0x018, "add x1 x1 x1") //       F D X M W    (M-D)

  asm( 0x01c, "addi x1 x0 1") // F D X M W
  asm( 0x020, "add x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "add x0 x0 x0") //       F D X M W
  asm( 0x02c, "add x1 x1 x1") //         F D X M W  (W-D)

  asm( 0x030, "addi x1 x0 1") // F D X M W
  asm( 0x034, "add x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "add x0 x0 x0") //         F D X M W
  asm( 0x044, "add x1 x1 x1") //           F D X M W

  reset(dut)

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 1)
  check_trace( 2)
  check_trace( 4)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 4)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 0)
  check_trace( 4)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 0)
  check_trace( 0)
  check_trace( 4)

//===========================================================
// ADD: test_mul_add
//===========================================================

@cocotb.test()
async def test_mul_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "addi x1 x0 3") // F D X M W
  asm( 0x004, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x008, "add x1 x1 x1") //     F D X M W      (X-D)

  asm( 0x00c, "addi x1 x0 3") // F D X M W
  asm( 0x010, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x014, "add x0 x0 x0") //     F D X M W
  asm( 0x018, "add x1 x1 x1") //       F D X M W    (M-D)

  asm( 0x01c, "addi x1 x0 3") // F D X M W
  asm( 0x020, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "add x0 x0 x0") //       F D X M W
  asm( 0x02c, "add x1 x1 x1") //         F D X M W  (W-D)

  asm( 0x030, "addi x1 x0 3") // F D X M W
  asm( 0x034, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "add x0 x0 x0") //         F D X M W
  asm( 0x044, "add x1 x1 x1") //           F D X M W

  reset(dut)

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 0x003)
  check_trace( 0x009)
  check_trace( 0x012)

  check_trace( 0x003)
  check_trace( 0x009)
  check_trace( 0x000)
  check_trace( 0x012)

  check_trace( 0x003)
  check_trace( 0x009)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x012)

  check_trace( 0x003)
  check_trace( 0x009)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x012)

//===========================================================
// ADD: test_lw_add
//===========================================================

@cocotb.test()
async def test_lw_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Data Memory

  data( 0x0fc, 0x001)

  // Assembly Program

  asm( 0x000, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x004, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x008, "add x1 x1 x1"    ) //     F D D X M W    (M-D)

  asm( 0x00c, "addi x1 x0 0x0fc") // F F D X M W
  asm( 0x010, "lw x1 0(x1)"     ) //     F D X M W      (X-D)
  asm( 0x014, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x018, "add x1 x1 x1"    ) //         F D X M W  (M-D)

  asm( 0x01c, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x020, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x024, "add x0 x0 x0"    ) //     F D X M W
  asm( 0x028, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x02c, "add x1 x1 x1"    ) //         F D X M W  (W-D)

  asm( 0x030, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x034, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x038, "add x0 x0 x0"    ) //     F D X M W
  asm( 0x03c, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x040, "add x0 x0 x0"    ) //         F D X M W
  asm( 0x044, "add x1 x1 x1"    ) //           F D X M W

  reset(dut)

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 0x0fc)
  check_trace( 0x001)
  RisingEdge(dut.clk)
  check_trace( 0x002)

  check_trace( 0x0fc)
  check_trace( 0x001)
  check_trace( 0x000)
  check_trace( 0x002)

  check_trace( 0x0fc)
  check_trace( 0x001)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x002)

  check_trace( 0x0fc)
  check_trace( 0x001)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x002)

//===========================================================
// ADD: test_jal_add
//===========================================================

@cocotb.test()
async def test_jal_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "jal x1 0x004") // F D X M W
  asm( 0x004, "add x2 x1 x1") //   F F D X M W     (M-D)

  asm( 0x008, "jal x1 0x014") // F D X M W
  asm( 0x00c, "add x0 x0 x0") //   F - - - -
  asm( 0x010, "add x0 x0 x0") //
  asm( 0x014, "add x2 x1 x1") //     F D X M W     (M-D)

  asm( 0x018, "jal x1 0x024") // F D X M W
  asm( 0x01c, "add x0 x0 x0") //   F - - - -
  asm( 0x020, "add x0 x0 x0") //
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "add x2 x1 x1") //       F D X M W   (W-D)

  asm( 0x02c, "jal x1 0x038") // F D X M W
  asm( 0x030, "add x0 x0 x0") //   F - - - -
  asm( 0x034, "add x0 x0 x0") //
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "add x2 x1 x1") //         F D X M W

  reset(dut)

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 0x004)
  RisingEdge(dut.clk)
  check_trace( 0x008)

  check_trace( 0x00c)
  RisingEdge(dut.clk)
  check_trace( 0x018)

  check_trace( 0x01c)
  RisingEdge(dut.clk)
  check_trace( 0x000)
  check_trace( 0x038)

  check_trace( 0x030)
  RisingEdge(dut.clk)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x060)
  
*/