#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# CSRR: test_simple
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # I/O Interface

  await proc_in(dut, 1, 1, 1)

  # Assembly Program

  await asm_write(dut, 0x000, "csrr x1 in0" )
  await asm_write(dut, 0x004, "csrr x2 in1" )
  await asm_write(dut, 0x008, "csrr x3 in2" )
  await asm_write(dut, 0x00c, "add x1 x1 x2")
  await asm_write(dut, 0x010, "add x1 x1 x3")

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 3)

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_csrr_test", "test_simple")