#!/usr/bin/env python3

from TinyRV1 import *

#===========================================================
# MUL
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "mul x2 x0 x1") #   F D X M W   (---, X-D)
  await asm_write(dut, 0x008, "mul x2 x1 x1") #     F D X M W (M-D, M-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 1)

@cocotb.test()
async def test_verify_mul_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 10") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 10") #   F D X M W
  await asm_write(dut, 0x008, "add x3 x1 x2" ) #     F D X M W           (M-D, X-D)
  await asm_write(dut, 0x00c, "addi x2 x0 2" ) #       F D X M W
  await asm_write(dut, 0x010, "mul x4 x1 x2" ) #         F D X M W       (---, X-D)
  await asm_write(dut, 0x014, "addi x1 x0 -1") #           F D X M W
  await asm_write(dut, 0x018, "mul x3 x1 x3" ) #             F D X M W   (X-D, ---)
  await asm_write(dut, 0x01c, "add x3 x3 x4" ) #               F D X M W (X-D, W-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x0000000a) # 10
  await check_trace(dut, 0x0000000a) # 10
  await check_trace(dut, 0x00000014) # 10 + 10 = 20
  await check_trace(dut, 0x00000002) # 2
  await check_trace(dut, 0x00000014) # 10 x 2 = 20
  await check_trace(dut, 0xffffffff) # -1
  await check_trace(dut, 0xffffffec) # -1 x 20 = -20
  await check_trace(dut, 0x00000000) # -20 + 20 = 0

@cocotb.test()
async def test_overflow_pos(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2047") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2047") #   F D X M W
  await asm_write(dut, 0x008, "mul x1 x1 x2"   ) #     F D X M W   (M-D, X-D)
  await asm_write(dut, 0x00c, "mul x1 x1 x2"   ) #       F D X M W (X-D, M-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x000007ff)
  await check_trace(dut, 0x000007ff)
  await check_trace(dut, 0x003ff001)
  await check_trace(dut, 0xff4017ff) # truncated

@cocotb.test()
async def test_overflow_neg(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 -2048") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2047" ) #   F D X M W
  await asm_write(dut, 0x008, "mul x1 x1 x2"    ) #     F D X M W   (M-D, X-D)
  await asm_write(dut, 0x00c, "mul x1 x1 x2"    ) #       F D X M W (X-D, M-D)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0xfffff800)
  await check_trace(dut, 0x000007ff)
  await check_trace(dut, 0xffc00800)
  await check_trace(dut, 0x007ff800) # truncated

if __name__ == "__main__":
  run("Proc_mul_test", "test_simple")
  run("Proc_mul_test", "test_verify_mul_add")
  run("Proc_mul_test", "test_overflow_pos")
  run("Proc_mul_test", "test_overflow_neg")