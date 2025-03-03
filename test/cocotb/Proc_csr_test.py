#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# CSRR: test_simple_csrr
#===========================================================

@cocotb.test()
async def test_simple_csrr(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Initial I/O

  proc_in(dut, 1, 1, 1)

  # Assembly Program

  await asm_write(dut, 0x000, "csrr x1 in0" ) # F D X M W
  await asm_write(dut, 0x004, "csrr x2 in1" ) #   F D X M W
  await asm_write(dut, 0x008, "csrr x3 in2" ) #     F D X M W
  await asm_write(dut, 0x00c, "add x1 x1 x2") #       F D X M W
  await asm_write(dut, 0x010, "add x1 x1 x3") #         F D X M W

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

#===========================================================
# CSRW: test_simple_csrw
#===========================================================

@cocotb.test()
async def test_simple_csrw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "csrw out0 x1") #   F D X M W
  await asm_write(dut, 0x008, "csrw out1 x1") #     F D X M W
  await asm_write(dut, 0x00c, "csrw out2 x1") #       F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 1)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  # Check Outputs

  await check_proc_out(dut, 1, 1, 1)

#===========================================================
# CSRR/W: test_escape_loop
#===========================================================

@cocotb.test()
async def test_escape_loop(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Initial I/O

  proc_in(dut, 0, 0, 0)

  # Assembly Program

  await asm_write(dut, 0x000, "csrw out0 x0"   ) # F D X M W     | <------ ESC
  await asm_write(dut, 0x004, "csrr x1 in0"    ) #   F D X M W   |
  await asm_write(dut, 0x008, "addi x2 x0 1"   ) #     F D X M W |
  await asm_write(dut, 0x00c, "bne x1 x2 0x004") #       F D X M | W
  await asm_write(dut, 0x010, "csrw out0 x1"   ) #         F D - | - -
  await asm_write(dut, 0x014, "jal x0 0x014"   ) #           F - | - - -
  #                    0x004   csrr x1 in0       #             F | D X M W
  
  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await RisingEdge(dut.clk)
  await check_trace(dut, 0)
  await check_trace(dut, 1)

  proc_in(dut, 1, 0, 0) # ESC

  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

  await check_trace(dut, 1)
  await check_trace(dut, 1)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x018)
  await RisingEdge(dut.clk)

  # Check Outputs

  await check_proc_out(dut, 1, 0, 0)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_csr_test", "test_simple_csrr")
  if (test_case < 0) | (test_case == 1):
    run("Proc_csr_test", "test_simple_csrw")
  if (test_case < 0) | (test_case == 2):
    run("Proc_csr_test", "test_escape_loop")