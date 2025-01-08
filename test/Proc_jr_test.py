#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# JR: test_simple
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x014") # F D X M W
  await asm_write(dut, 0x004, "jr x1"           ) #   F D X M W          (X-D)
  await asm_write(dut, 0x008, "add x0 x0 x0"    ) #     F - - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #
  await asm_write(dut, 0x014, "addi x1 x0 0x000") #       F D X M W
  await asm_write(dut, 0x018, "jr x1"           ) #         F D X M W    (X-D)
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #           F - - - -
  #                            addi x1 x0 0x014   #             F D X M W
  #                                   ...         #                ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x014)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x014)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x014)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

#===========================================================
# JR: test_addi_jr
#===========================================================

@cocotb.test()
async def test_addi_jr(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_jr_test", "test_simple")