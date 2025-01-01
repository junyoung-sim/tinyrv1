from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x080, 0xcafe2300)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "lw x2 0(x1)"     ) #   F D X M W (X-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0xcafe2300)

@cocotb.test()
async def test_imm(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x07c, 0xcafe2300)
  await data(dut, 0x080, 0xacedbeef)
  await data(dut, 0x084, 0xdeafface)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M | W
  await asm_write(dut, 0x004, "lw x2 -4(x1)"    ) #   F D X | M W     (X-D)
  await asm_write(dut, 0x008, "lw x2 0(x1)"     ) #     F D | X M W   (M-D)
  await asm_write(dut, 0x00c, "lw x2 4(x1)"     ) #       F | D X M W (W-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0xcafe2300)
  await check_trace(dut, 0xacedbeef)
  await check_trace(dut, 0xdeafface)