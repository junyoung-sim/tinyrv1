#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# BNE: test_forward
#===========================================================

@cocotb.test()
async def test_forward(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x024") #   F D X M W          (X-D)
  await asm_write(dut, 0x008, "addi x1 x0 1"   ) #     F D X M W
  await asm_write(dut, 0x00c, "bne x0 x1 0x024") #       F D X M W      (X-D)
  await asm_write(dut, 0x010, "add x0 x0 x0"   ) #         F D - - -
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #           F - - - -
  await asm_write(dut, 0x018, "add x0 x0 x0"   ) #
  await asm_write(dut, 0x01c, "add x0 x0 x0"   ) #
  await asm_write(dut, 0x020, "add x0 x0 x0"   ) #
  await asm_write(dut, 0x024, "jal x0 0x000"   ) #             F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"   ) #               F - - - -
  #                    0x000   addi x1 x0 0      #                 F D X M W
  #                                 ...          #                    ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x001)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x028)
    await RisingEdge(dut.clk)

#===========================================================
# BNE: test_backward
#===========================================================

@cocotb.test()
async def test_backward(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x000") #   F D X M W           (X-D)
  await asm_write(dut, 0x008, "addi x1 x0 1"   ) #     F D X M W
  await asm_write(dut, 0x00c, "bne x0 x1 0x000") #       F D X M W       (X-D)
  await asm_write(dut, 0x010, "add x0 x0 x0"   ) #         F D - - -
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #           F - - - -
  #                    0x000   addi x1 x0 0      #             F D X M W
  #                                 ...          #                ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)
    await check_trace(dut, 1)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# BNE: test_squash_jump
#===========================================================

@cocotb.test()
async def test_squash_jump(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1"    ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x018" ) #   F D X M W                (X-D)
  await asm_write(dut, 0x008, "jal x0 0x008"    ) #     F D - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #       F - - - -
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #
  await asm_write(dut, 0x018, "addi x1 x0 1"    ) #         F D X M W
  await asm_write(dut, 0x01c, "addi x2 x0 0x024") #           F D X M W
  await asm_write(dut, 0x020, "bne x0 x1 0x000" ) #             F D X M W      (X-D)
  await asm_write(dut, 0x024, "jr x2"           ) #               F D - - -
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #                 F - - - -
  #                    0x000   addi x1 x0 1       #                   F D X M W
  #                                 ...           #                      ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x001)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x001)
    await check_trace(dut, 0x024)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_bne_test", "test_forward")
  if (test_case < 0) | (test_case == 1):
    run("Proc_bne_test", "test_backward")
  if (test_case < 0) | (test_case == 2):
    run("Proc_bne_test", "test_squash_jump")