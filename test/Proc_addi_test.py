from TinyRV1 import *

#===========================================================
# ADDI
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1" ) # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2" ) #   F D X M W
  await asm_write(dut, 0x008, "addi x3 x0 -1") #     F D X M W
  await asm_write(dut, 0x00c, "addi x4 x0 -2") #       F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000001) #  1
  await check_trace(dut, 0x00000002) #  2
  await check_trace(dut, 0xffffffff) # -1
  await check_trace(dut, 0xfffffffe) # -2

@cocotb.test()
async def test_imm_bound_valid(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2047" ) # F D X M W
  await asm_write(dut, 0x004, "addi x1 x0 -2048") #   F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x000007ff) #  2047
  await check_trace(dut, 0xfffff800) # -2048

@cocotb.test()
async def test_imm_bound_invalid_1(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2048") # F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000800) # 2048 (FAIL)

@cocotb.test()
async def test_imm_bound_invalid_2(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 -2049") # F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0xfffff7ff) # -2049 (FAIL)

@cocotb.test()
async def test_raw_bypass(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2") #   F D X M W
  await asm_write(dut, 0x008, "add x3 x1 x2") #     F D X M W           (M-D, X-D)
  await asm_write(dut, 0x00c, "addi x4 x1 3") #       F D X M W         (W-D)
  await asm_write(dut, 0x010, "addi x5 x1 4") #         F D X M W
  await asm_write(dut, 0x014, "add x6 x2 x4") #           F D X M W     (M-D)
  await asm_write(dut, 0x018, "add x7 x1 x6") #             F D X M W   (X-D)
  await asm_write(dut, 0x01c, "add x8 x3 x5") #               F D X M W (W-D)

  await reset(dut)

  # Check Traces
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000001)
  await check_trace(dut, 0x00000002)
  await check_trace(dut, 0x00000003)
  await check_trace(dut, 0x00000004)
  await check_trace(dut, 0x00000005)
  await check_trace(dut, 0x00000006)
  await check_trace(dut, 0x00000007)
  await check_trace(dut, 0x00000008)
