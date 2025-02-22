#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# ADDI: test_immediate
#===========================================================

@cocotb.test()
async def test_immediate(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2047" )
  await asm_write(dut, 0x004, "addi x1 x0 -2048")

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x000007ff)
  await check_trace(dut, 0xfffff800)

#===========================================================
# ADDI: test_addi_addi
#===========================================================

@cocotb.test()
async def test_addi_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x1 1") #   F D X M W       (X-D)
  
  await asm_write(dut, 0x008, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x010, "addi x2 x1 1") #     F D X M W     (M-D)
  
  await asm_write(dut, 0x014, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x020, "addi x2 x1 1") #       F D X M W   (W-D)

  await asm_write(dut, 0x024, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x034, "addi x2 x1 1") #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

#===========================================================
# ADDI: test_add_addi
#===========================================================

@cocotb.test()
async def test_add_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x008, "addi x1 x1 1") #     F D X M W     (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x010, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "addi x1 x1 1") #       F D X M W   (M-D)
  
  await asm_write(dut, 0x01c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x020, "add x1 x1 x1") #   F D X M W       (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "addi x1 x1 1") #         F D X M W (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x034, "add x1 x1 x1") #   F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "addi x1 x1 1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 3)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 3)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 3)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 3)

#===========================================================
# ADDI: test_mul_addi
#===========================================================

@cocotb.test()
async def test_mul_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x004, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "addi x1 x1 9") #     F D X M W      (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x010, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "addi x1 x1 9") #       F D X M W    (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x020, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "addi x1 x1 9") #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 3") # F D X M W
  await asm_write(dut, 0x034, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "addi x1 x1 9") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x003)
  await check_trace(dut, 0x009)
  await check_trace(dut, 0x012)

  await check_trace(dut, 0x003)
  await check_trace(dut, 0x009)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x012)

  await check_trace(dut, 0x003)
  await check_trace(dut, 0x009)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x012)

  await check_trace(dut, 0x003)
  await check_trace(dut, 0x009)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x012)

#===========================================================
# ADDI: test_lw_addi
#===========================================================

@cocotb.test()
async def test_lw_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "addi x1 x1 1"    ) #     F D D X M W    (M-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0x0fc") # F F D X M W
  await asm_write(dut, 0x010, "lw x1 0(x1)"     ) #     F D X M W      (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x018, "addi x1 x1 1"    ) #         F D X M W  (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x020, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "addi x1 x1 1"    ) #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "addi x1 x1 1"    ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x002)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x002)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x002)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x002)

#===========================================================
# ADDI: test_jal_addi
#===========================================================

@cocotb.test()
async def test_jal_addi(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x1 0x004") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x1 4") #   F F D X M W     (M-D)

  await asm_write(dut, 0x008, "jal x1 0x014") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x010, "add x0 x0 x0") #
  await asm_write(dut, 0x014, "addi x2 x1 4") #     F D X M W     (M-D)

  await asm_write(dut, 0x018, "jal x1 0x024") # F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x020, "add x0 x0 x0") #
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "addi x2 x1 4") #       F D X M W   (W-D)

  await asm_write(dut, 0x02c, "jal x1 0x038") # F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x034, "add x0 x0 x0") #
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "addi x2 x1 4") #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x004)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x008)

  await check_trace(dut, 0x00c)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x010)

  await check_trace(dut, 0x01c)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x020)

  await check_trace(dut, 0x030)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x034)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_addi_test", "test_immediate")
  if (test_case < 0) | (test_case == 1):
    run("Proc_addi_test", "test_addi_addi")
  if (test_case < 0) | (test_case == 2):
    run("Proc_addi_test", "test_add_addi")
  if (test_case < 0) | (test_case == 3):
    run("Proc_addi_test", "test_mul_addi")
  if (test_case < 0) | (test_case == 4):
    run("Proc_addi_test", "test_lw_addi")
  if (test_case < 0) | (test_case == 5):
    run("Proc_addi_test", "test_jal_addi")