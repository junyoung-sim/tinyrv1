#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# LW
#===========================================================

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
async def test_addi_lw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "lw x1 0(x1)"     ) #   F D X M W     (X-D)

  await asm_write(dut, 0x008, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x010, "lw x1 0(x1)"     ) #     F D X M W   (M-D)

  await asm_write(dut, 0x014, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x020, "lw x1 0(x1)"     ) #       F D X M W (W-D)

  await asm_write(dut, 0x024, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x034, "lw x1 0(x1)"     ) #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)
  
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_add_lw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "lw x1 0(x1)"     ) #     F D X M W       (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x010, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x018, "lw x1 0(x1)"     ) #       F D X M W     (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x020, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "lw x1 0(x1)"     ) #         F D X M W   (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "lw x1 0(x1)"     ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_mul_lw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x0fc") #   F D X M W
  await asm_write(dut, 0x008, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x00c, "lw x1 0(x1)"     ) #       F D X M W       (X-D)

  await asm_write(dut, 0x010, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x014, "addi x2 x0 0x0fc") #   F D X M W
  await asm_write(dut, 0x018, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x020, "lw x1 0(x1)"     ) #         F D X M W     (M-D)

  await asm_write(dut, 0x024, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x028, "addi x2 x0 0x0fc") #   F D X M W
  await asm_write(dut, 0x02c, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x030, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x034, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x038, "lw x1 0(x1)"     ) #           F D X M W   (W-D)

  await asm_write(dut, 0x03c, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x040, "addi x2 x0 0x0fc") #   F D X M W
  await asm_write(dut, 0x044, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x048, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x04c, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x050, "add x0 x0 x0"    ) #           F D X M W
  await asm_write(dut, 0x054, "lw x1 0(x1)"     ) #             F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x001)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x001)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x001)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x001)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_lw_lw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fb, 0x0fc)
  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fb") # F D X M W
  await asm_write(dut, 0x004, "lw x2 0(x1)"     ) #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "lw x3 0(x2)"     ) #     F D D X M W     (M-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0x0fb") # F F D X M W
  await asm_write(dut, 0x010, "lw x2 0(x1)"     ) #     F D X M W       (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x018, "lw x3 0(x2)"     ) #         F D X M W   (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0x0fb") # F D X M W
  await asm_write(dut, 0x020, "lw x2 0(x1)"     ) #   F D X M W         (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "lw x3 0(x2)"     ) #         F D X M W   (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 0x0fb") # F D X M W
  await asm_write(dut, 0x034, "lw x2 0(x1)"     ) #   F D X M W         (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "lw x3 0(x2)"     ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fb)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fb)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fb)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x0fb)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_sw_lw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x001") #   F D X M W
  await asm_write(dut, 0x008, "lw x3 0(x1)"     ) #     F D X M W     (M-D)
  await asm_write(dut, 0x00c, "sw x2 0(x1)"     ) #       F D X M W   (W-D, M-D)
  await asm_write(dut, 0x010, "lw x3 0(x1)"     ) #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_lw_test", "test_simple")
  if (test_case < 0) | (test_case == 1):
    run("Proc_lw_test", "test_addi_lw")
  if (test_case < 0) | (test_case == 2):
    run("Proc_lw_test", "test_add_lw")
  if (test_case < 0) | (test_case == 3):
    run("Proc_lw_test", "test_mul_lw")
  if (test_case < 0) | (test_case == 4):
    run("Proc_lw_test", "test_lw_lw")
  if (test_case < 0) | (test_case == 5):
    run("Proc_lw_test", "test_sw_lw")