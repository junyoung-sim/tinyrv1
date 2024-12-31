from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0a0, 100)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0a0") # F D X M W
  await asm_write(dut, 0x004, "lw x2 0(x1)"     ) #   F D X M W (X-D)

  await reset(dut)

  # Check Trace

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x000000a0)
  await check_trace(dut, 0x00000064)