from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x078, 0xdeadbeef)
  await data(dut, 0x07c, 0xcafe2300)
  await data(dut, 0x080, 0xacedbeef)
  await data(dut, 0x084, 0xdeafface)
  await data(dut, 0x088, 0xabacadab)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "lw x2 -8(x1)"    ) #   F D X M W       (X-D)
  await asm_write(dut, 0x008, "lw x2 -4(x1)"    ) #     F D X M W     (M-D)
  await asm_write(dut, 0x00c, "lw x2 0(x1)"     ) #       F D X M W   (W-D)
  await asm_write(dut, 0x010, "lw x2 4(x1)"     ) #         F D X M W
  await asm_write(dut, 0x014, "lw x2 8(x1)"     ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0xdeadbeef)
  await check_trace(dut, 0xcafe2300)
  await check_trace(dut, 0xacedbeef)
  await check_trace(dut, 0xdeafface)
  await check_trace(dut, 0xabacadab)

@cocotb.test()
async def test_stall(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x080, 0x0000000a)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "lw x2 0(x1)"     ) #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "addi x2 x2 1"    ) #     F D D X M W     (M-D)
  await asm_write(dut, 0x00c, "addi x3 x2 1"    ) #       F F D X M W   (X-D)
  await asm_write(dut, 0x010, "addi x4 x3 1"    ) #           F D X M W (X-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0x0000000a)
  await check_trace(dut, 0x0000000a) # stalled trace
  await check_trace(dut, 0x0000000b)
  await check_trace(dut, 0x0000000c)
  await check_trace(dut, 0x0000000d)