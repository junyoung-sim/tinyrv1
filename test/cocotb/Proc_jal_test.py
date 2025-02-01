#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# JAL: test_forward
#===========================================================

@cocotb.test()
async def test_forward(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x1 0x010") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 1") #   F - - - -
  await asm_write(dut, 0x008, "addi x3 x2 1") #
  await asm_write(dut, 0x00c, "addi x4 x3 1") #
  await asm_write(dut, 0x010, "jr x1"       ) #     F D X M W           (M-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #       F - - - -
  #                    0x004   addi x2 x0 1   #         F D X M W
  #                    0x008   addi x3 x2 1   #           F D X M W     (X-D)
  #                    0x00c   addi x4 x3 1   #             F D X M W   (X-D)
  #                    0x010   jr x1          #               F D X M W (X-D)
  #                                 ...       #                  ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x004)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  for i in range(3):
    await check_trace(dut, 0x001)
    await check_trace(dut, 0x002)
    await check_trace(dut, 0x003)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# JAL: test_backward
#===========================================================

@cocotb.test()
async def test_backward(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x0 0x014") # F D X M W
  await asm_write(dut, 0x004, "addi x1 x0 1") #   F - - - -
  await asm_write(dut, 0x008, "addi x2 x1 1") #
  await asm_write(dut, 0x00c, "addi x3 x2 1") #
  await asm_write(dut, 0x010, "jr x4"       ) #
  await asm_write(dut, 0x014, "jal x4 0x004") #     F D X M W
  #                    0x018  addi x1 x0 1    #       F - - - -
  #                    0x004  addi x1 x0 1    #         F D X M W
  #                    0x008  addi x2 x1 1    #           F D X M W       (X-D)
  #                    0x00c  addi x3 x2 1    #             F D X M W     (X-D)
  #                    0x010  jr x4           #               F D X M W
  #                    0x014  jal x4 0x004    #                 F - - - -
  await asm_write(dut, 0x018, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x01c, "addi x2 x1 1") #   F D X M W               (X-D)
  await asm_write(dut, 0x020, "addi x3 x2 1") #     F D X M W             (X-D)
  await asm_write(dut, 0x024, "jal x0 0x000") #       F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0") #         F - - - -
  #                    0x000   jal x0 0x014   #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x004)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x018)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x001)
    await check_trace(dut, 0x002)
    await check_trace(dut, 0x003)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x001)
    await check_trace(dut, 0x002)
    await check_trace(dut, 0x003)
    await check_trace(dut, 0x028)
    await RisingEdge(dut.clk)

#===========================================================
# JAL/R: test_jal_jr_MD_1
#===========================================================

@cocotb.test()
async def test_jal_jr_MD_1(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x1 0x004") # F D X M W
  await asm_write(dut, 0x004, "jr x1"       ) #   F F D X M W   (M-D)
  await asm_write(dut, 0x008, "add x0 x0 x0") #       F - - - -

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(10):
    await check_trace(dut, 0x004)

#===========================================================
# JAL/R: test_jal_jr_MD_2
#===========================================================

@cocotb.test()
async def test_jal_jr_MD_2(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x3 0x00c") # F D X M W
  await asm_write(dut, 0x004, "addi x1 x0 1") #   F - - - -
  await asm_write(dut, 0x008, "addi x2 x1 1") #
  await asm_write(dut, 0x00c, "jr x3"       ) #     F D X M W   (M-D)
  await asm_write(dut, 0x010, "add x0 x0 x0") #       F - - - -

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x004)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  for i in range(3):
    await check_trace(dut, 1)
    await check_trace(dut, 2)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# JAL/R: test_jal_jr_WD
#===========================================================

@cocotb.test()
async def test_jal_jr_WD(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x3 0x00c") # F D X M W
  await asm_write(dut, 0x004, "addi x1 x0 1") #   F - - - -
  await asm_write(dut, 0x008, "addi x2 x1 1") #
  await asm_write(dut, 0x00c, "add x0 x0 x0") #     F D X M W
  await asm_write(dut, 0x010, "jr x3"       ) #       F D X M W   (W-D)
  await asm_write(dut, 0x014, "add x0 x0 x0") #         F - - - -

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x004)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  for i in range(3):
    await check_trace(dut, 1)
    await check_trace(dut, 2)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_jal_test", "test_forward")
  if (test_case < 0) | (test_case == 1):
    run("Proc_jal_test", "test_backward")
  if (test_case < 0) | (test_case == 2):
    run("Proc_jal_test", "test_jal_jr_MD_1")
  if (test_case < 0) | (test_case == 3):
    run("Proc_jal_test", "test_jal_jr_MD_2")
  if (test_case < 0) | (test_case == 4):
    run("Proc_jal_test", "test_jal_jr_WD")