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

/*
//===========================================================
// ADDI: test_addi_addi
//===========================================================

@cocotb.test()
async def test_addi_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "addi x1 x0 1") // F D X M W
  asm( 0x004, "addi x2 x1 1") //   F D X M W       (X-D)
  
  asm( 0x008, "addi x1 x0 1") // F D X M W
  asm( 0x00c, "add x0 x0 x0") //   F D X M W
  asm( 0x010, "addi x2 x1 1") //     F D X M W     (M-D)
  
  asm( 0x014, "addi x1 x0 1") // F D X M W
  asm( 0x018, "add x0 x0 x0") //   F D X M W
  asm( 0x01c, "add x0 x0 x0") //     F D X M W
  asm( 0x020, "addi x2 x1 1") //       F D X M W   (W-D)

  asm( 0x024, "addi x1 x0 1") // F D X M W
  asm( 0x028, "add x0 x0 x0") //   F D X M W
  asm( 0x02c, "add x0 x0 x0") //     F D X M W
  asm( 0x030, "add x0 x0 x0") //       F D X M W
  asm( 0x034, "addi x2 x1 1") //         F D X M W

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 1)
  check_trace( 2)

  check_trace( 1)
  check_trace( 0)
  check_trace( 2)

  check_trace( 1)
  check_trace( 0)
  check_trace( 0)
  check_trace( 2)

  check_trace( 1)
  check_trace( 0)
  check_trace( 0)
  check_trace( 0)
  check_trace( 2)

//===========================================================
// ADDI: test_add_addi
//===========================================================

@cocotb.test()
async def test_add_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "addi x1 x0 1") // F D X M W
  asm( 0x004, "add x1 x1 x1") //   F D X M W       (X-D)
  asm( 0x008, "addi x1 x1 1") //     F D X M W     (X-D)

  asm( 0x00c, "addi x1 x0 1") // F D X M W
  asm( 0x010, "add x1 x1 x1") //   F D X M W       (X-D)
  asm( 0x014, "add x0 x0 x0") //     F D X M W
  asm( 0x018, "addi x1 x1 1") //       F D X M W   (M-D)
  
  asm( 0x01c, "addi x1 x0 1") // F D X M W
  asm( 0x020, "add x1 x1 x1") //   F D X M W       (X-D)
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "add x0 x0 x0") //       F D X M W
  asm( 0x02c, "addi x1 x1 1") //         F D X M W (W-D)

  asm( 0x030, "addi x1 x0 1") // F D X M W
  asm( 0x034, "add x1 x1 x1") //   F D X M W
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "add x0 x0 x0") //         F D X M W
  asm( 0x044, "addi x1 x1 1") //           F D X M W

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 1)
  check_trace( 2)
  check_trace( 3)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 3)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 0)
  check_trace( 3)

  check_trace( 1)
  check_trace( 2)
  check_trace( 0)
  check_trace( 0)
  check_trace( 0)
  check_trace( 3)

//===========================================================
// ADDI: test_mul_addi
//===========================================================

@cocotb.test()
async def test_mul_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "addi x1 x0 3") // F D X M W
  asm( 0x004, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x008, "addi x1 x1 9") //     F D X M W      (X-D)

  asm( 0x00c, "addi x1 x0 3") // F D X M W
  asm( 0x010, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x014, "add x0 x0 x0") //     F D X M W
  asm( 0x018, "addi x1 x1 9") //       F D X M W    (M-D)

  asm( 0x01c, "addi x1 x0 3") // F D X M W
  asm( 0x020, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "add x0 x0 x0") //       F D X M W
  asm( 0x02c, "addi x1 x1 9") //         F D X M W  (W-D)

  asm( 0x030, "addi x1 x0 3") // F D X M W
  asm( 0x034, "mul x1 x1 x1") //   F D X M W        (X-D)
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "add x0 x0 x0") //         F D X M W
  asm( 0x044, "addi x1 x1 9") //           F D X M W

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
// ADDI: test_lw_addi
//===========================================================

@cocotb.test()
async def test_lw_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Data Memory

  data( 0x0fc, 0x001)

  // Assembly Program

  asm( 0x000, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x004, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x008, "addi x1 x1 1"    ) //     F D D X M W    (M-D)

  asm( 0x00c, "addi x1 x0 0x0fc") // F F D X M W
  asm( 0x010, "lw x1 0(x1)"     ) //     F D X M W      (X-D)
  asm( 0x014, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x018, "addi x1 x1 1"    ) //         F D X M W  (M-D)

  asm( 0x01c, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x020, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x024, "add x0 x0 x0"    ) //     F D X M W
  asm( 0x028, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x02c, "addi x1 x1 1"    ) //         F D X M W  (W-D)

  asm( 0x030, "addi x1 x0 0x0fc") // F D X M W
  asm( 0x034, "lw x1 0(x1)"     ) //   F D X M W        (X-D)
  asm( 0x038, "add x0 x0 x0"    ) //     F D X M W
  asm( 0x03c, "add x0 x0 x0"    ) //       F D X M W
  asm( 0x040, "add x0 x0 x0"    ) //         F D X M W
  asm( 0x044, "addi x1 x1 1"    ) //           F D X M W

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
// ADDI: test_jal_addi
//===========================================================

@cocotb.test()
async def test_jal_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  // Assembly Program

  asm( 0x000, "jal x1 0x004") // F D X M W
  asm( 0x004, "addi x2 x1 4") //   F F D X M W     (M-D)

  asm( 0x008, "jal x1 0x014") // F D X M W
  asm( 0x00c, "add x0 x0 x0") //   F - - - -
  asm( 0x010, "add x0 x0 x0") //
  asm( 0x014, "addi x2 x1 4") //     F D X M W     (M-D)

  asm( 0x018, "jal x1 0x024") // F D X M W
  asm( 0x01c, "add x0 x0 x0") //   F - - - -
  asm( 0x020, "add x0 x0 x0") //
  asm( 0x024, "add x0 x0 x0") //     F D X M W
  asm( 0x028, "addi x2 x1 4") //       F D X M W   (W-D)

  asm( 0x02c, "jal x1 0x038") // F D X M W
  asm( 0x030, "add x0 x0 x0") //   F - - - -
  asm( 0x034, "add x0 x0 x0") //
  asm( 0x038, "add x0 x0 x0") //     F D X M W
  asm( 0x03c, "add x0 x0 x0") //       F D X M W
  asm( 0x040, "addi x2 x1 4") //         F D X M W

  // Check Traces

  check_trace( x)
  check_trace( x)
  check_trace( x)

  check_trace( 0x004)
  RisingEdge(dut.clk)
  check_trace( 0x008)

  check_trace( 0x00c)
  RisingEdge(dut.clk)
  check_trace( 0x010)

  check_trace( 0x01c)
  RisingEdge(dut.clk)
  check_trace( 0x000)
  check_trace( 0x020)

  check_trace( 0x030)
  RisingEdge(dut.clk)
  check_trace( 0x000)
  check_trace( 0x000)
  check_trace( 0x034)
*/