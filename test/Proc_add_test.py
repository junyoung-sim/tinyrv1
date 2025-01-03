from TinyRV1 import *

#===========================================================
# ADD
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "add x1 x0 x0")

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0)

@cocotb.test()
async def test_raw_bypass(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "add x1 x0 x0") # F D X M W
  await asm_write(dut, 0x004, "add x2 x1 x0") #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "add x3 x1 x2") #     F D X M W       (M-D, X-D)
  await asm_write(dut, 0x00c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x010, "add x4 x2 x0") #         F D X M W   (W-D)
  await asm_write(dut, 0x014, "add x5 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)