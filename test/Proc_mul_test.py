#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# MUL
#===========================================================

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
async def test_addi_mul(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x004, "mul x2 x1 x1") #   F D X M W       (X-D)
  
  await asm_write(dut, 0x008, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x010, "mul x2 x1 x1") #     F D X M W     (M-D)
  
  await asm_write(dut, 0x014, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x020, "mul x2 x1 x1") #       F D X M W   (W-D)

  await asm_write(dut, 0x024, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x034, "mul x2 x1 x1") #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 3)
  await check_trace(dut, 9)

  await check_trace(dut, 3)
  await check_trace(dut, 0)
  await check_trace(dut, 9)

  await check_trace(dut, 3)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 9)

  await check_trace(dut, 3)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 9)

@cocotb.test()
async def test_add_mul(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x004, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x008, "mul x2 x1 x1") #     F D X M W     (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x010, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "mul x2 x1 x1") #       F D X M W   (M-D)
  
  await asm_write(dut, 0x01c, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x020, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "mul x2 x1 x1") #         F D X M W (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x034, "add x1 x1 x1") #   F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "mul x2 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

@cocotb.test()
async def test_mul_mul(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x004, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "mul x2 x1 x1") #     F D X M W      (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x010, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "mul x2 x1 x1") #       F D X M W    (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x020, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "mul x2 x1 x1") #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 2") # F D X M W
  await asm_write(dut, 0x034, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "mul x2 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x010)

@cocotb.test()
async def test_lw_mul(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x003)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "mul x2 x1 x1"    ) #     F D D X M W    (M-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0x0fc") # F F D X M W
  await asm_write(dut, 0x010, "lw x1 0(x1)"     ) #     F D X M W      (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x018, "mul x2 x1 x1"    ) #         F D X M W  (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x020, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "mul x2 x1 x1"    ) #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "mul x2 x1 x1"    ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x009)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x009)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x009)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x009)


if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_mul_test", "test_verify_mul_add")
  if (test_case < 0) | (test_case == 1):
    run("Proc_mul_test", "test_addi_mul")
  if (test_case < 0) | (test_case == 2):
    run("Proc_mul_test", "test_add_mul")
  if (test_case < 0) | (test_case == 3):
    run("Proc_mul_test", "test_mul_mul")
  if (test_case < 0) | (test_case == 4):
    run("Proc_mul_test", "test_lw_mul")