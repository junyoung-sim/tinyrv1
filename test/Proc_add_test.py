#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# ADD
#===========================================================

@cocotb.test()
async def test_addi_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "add x2 x1 x1") #   F D X M W       (X-D)
  
  await asm_write(dut, 0x008, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x010, "add x2 x1 x1") #     F D X M W     (M-D)
  
  await asm_write(dut, 0x014, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x020, "add x2 x1 x1") #       F D X M W   (W-D)

  await asm_write(dut, 0x024, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x034, "add x2 x1 x1") #         F D X M W

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

@cocotb.test()
async def test_add_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "add x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "add x1 x1 x1") #     F D X M W      (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x010, "add x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "add x1 x1 x1") #       F D X M W    (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x020, "add x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "add x1 x1 x1") #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x034, "add x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "add x1 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 4)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 4)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 4)

  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 4)

@cocotb.test()
async def test_mul_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "add x1 x1 x1") #     F D X M W      (X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x010, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x018, "add x1 x1 x1") #       F D X M W    (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x020, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x02c, "add x1 x1 x1") #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x034, "mul x1 x1 x1") #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0") #         F D X M W
  await asm_write(dut, 0x044, "add x1 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 2)

@cocotb.test()
async def test_lw_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0fc, 0x001)

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x004, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x008, "add x1 x1 x1"    ) #     F D D X M W    (M-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x010, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x018, "add x1 x1 x1"    ) #       F D X M W    (M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x020, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "add x1 x1 x1"    ) #         F D X M W  (W-D)

  await asm_write(dut, 0x030, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "lw x1 0(x1)"     ) #   F D X M W        (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "add x1 x1 x1"    ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
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

@cocotb.test()
async def test_sw_add(dut):
  pass

@cocotb.test()
async def test_jr_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x014") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x001") #   F D X M W
  await asm_write(dut, 0x008, "jr x1"           ) #     F D X M W        (M-D)
  await asm_write(dut, 0x00c, "add x2 x2 x2"    ) #       F - - - -
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #
  await asm_write(dut, 0x014, "add x2 x2 x2"    ) #         F D X M W    (W-D)
  await asm_write(dut, 0x018, "jr x1"           ) #           F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #             F - - - -

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x014)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x008)

@cocotb.test()
async def test_jal_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x0 0x00c") # F D X M W
  await asm_write(dut, 0x004, "add x2 x1 x1") #   F - - - -
  await asm_write(dut, 0x008, "jr x1"       ) #
  await asm_write(dut, 0x00c, "jal x1 0x004") #     F D X M W
  #                            jal x0 0x020   #       F - - - -
  #                            add x2 x1 x1   #         F D X M W     (M-D)
  #                            jr x1          #           F D X M W   (W-D)
  #                            jal x1 0x004   #             F - - - -

  await asm_write(dut, 0x010, "jal x0 0x020") # F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x018, "add x2 x1 x1") #
  await asm_write(dut, 0x01c, "jr x1"       ) #
  await asm_write(dut, 0x020, "jal x1 0x014") #     F D X M W
  #                            jal x0 0x038   #       F - - - -
  #                            add x0 x0 x0   #         F D X M W
  #                            add x2 x1 x1   #           F D X M W     (W-D)
  #                            jr x1          #             F D X M W
  #                            jal x1 0x014   #               F - - - -

  await asm_write(dut, 0x024, "jal x0 0x038") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x02c, "add x0 x0 x0") #
  await asm_write(dut, 0x030, "add x2 x1 x1") #
  await asm_write(dut, 0x034, "jr x1"       ) #
  await asm_write(dut, 0x038, "jal x1 0x028") #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0") #       F - - - -
  #                            add x0 x0 x0   #         F D X M W
  #                            add x0 x0 x0   #           F D X M W
  #                            add x2 x1 x1   #             F D X M W
  #                            jr x1          #               F D X M W
  #                            jal x1 0x028   #                 F - - - -
  #                            add x0 x0 x0   #                   F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x010)
  await check_trace(dut, 0x010)
  await check_trace(dut, 0x020)
  await check_trace(dut, 0x020)
  await check_trace(dut, 0x020)

  await check_trace(dut, 0x014)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x024)
  await check_trace(dut, 0x024)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x048)
  await check_trace(dut, 0x048)
  await check_trace(dut, 0x048)

  await check_trace(dut, 0x028)
  await check_trace(dut, 0x028)
  await check_trace(dut, 0x03c)
  await check_trace(dut, 0x03c)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x078)
  await check_trace(dut, 0x078)
  await check_trace(dut, 0x078)
  await check_trace(dut, 0x000)

@cocotb.test()
async def test_bne_add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 1"   ) #   F D X M W
  await asm_write(dut, 0x008, "bne x0 x1 0x018") #     F D X M W     (M-D)
  await asm_write(dut, 0x00c, "add x2 x2 x2"   ) #       F D - - -   (M-D)
  await asm_write(dut, 0x010, "add x2 x2 x2"   ) #         F - - - -
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #

  await asm_write(dut, 0x018, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x01c, "addi x2 x0 1"   ) #   F D X M W
  await asm_write(dut, 0x020, "bne x0 x1 0x028") #     F D X M W       (M-D)
  await asm_write(dut, 0x024, "add x2 x2 x2"   ) #       F D - - -     (M-D)
  await asm_write(dut, 0x028, "add x2 x2 x2"   ) #         F F D X M W

  await asm_write(dut, 0x02c, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x030, "addi x2 x0 1"   ) #   F D X M W
  await asm_write(dut, 0x034, "bne x0 x1 0x000") #     F D X M W     (M-D)
  await asm_write(dut, 0x038, "add x2 x2 x2"   ) #       F D X M W   (M-D)
  await asm_write(dut, 0x03c, "add x0 x0 x0"   ) #         F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 2)

  await check_trace(dut, 0)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 0)

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_add_test", "test_addi_add")
  if (test_case < 0) | (test_case == 1):
    run("Proc_add_test", "test_add_add")
  if (test_case < 0) | (test_case == 2):
    run("Proc_add_test", "test_mul_add")
  if (test_case < 0) | (test_case == 3):
    run("Proc_add_test", "test_lw_add")
  if (test_case < 0) | (test_case == 4):
    run("Proc_add_test", "test_sw_add")
  if (test_case < 0) | (test_case == 5):
    run("Proc_add_test", "test_jr_add")
  if (test_case < 0) | (test_case == 6):
    run("Proc_add_test", "test_jal_add")
  if (test_case < 0) | (test_case == 7):
    run("Proc_add_test", "test_bne_add")