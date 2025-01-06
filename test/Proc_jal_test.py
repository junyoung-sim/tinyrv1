#!/usr/bin/env python3

from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x0 0x000") # F D X M W
  await asm_write(dut, 0x004, "add x0 x0 x0") #   F - - - -
  #                            jal x0 0x000   #     F D X M W
  #                            add x0 x0 x0   #       F - - - -
  #                                 ...       #          ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)

@cocotb.test()
async def test_forward_jal(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x1 0x00c") # F D X M W
  await asm_write(dut, 0x004, "add x0 x0 x0") #   F - - - -
  await asm_write(dut, 0x008, "addi x2 x0 1")
  await asm_write(dut, 0x00c, "jr x1"       ) #     F D X M W         (M-D)
  await asm_write(dut, 0x010, "add x0 x0 x0") #       F - - - -
  #                            add x0 x0 x0   #         F D X M W
  #                            addi x2 x0 1   #           F D X M W
  #                            jr x1          #             F D X M W
  #                                 ...       #                ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_backward_jal(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x1 0x010") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 1") #   F - - - -
  await asm_write(dut, 0x008, "addi x1 x1 4")
  await asm_write(dut, 0x00c, "jr x1"       )
  await asm_write(dut, 0x010, "jal x1 0x004") #     F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0") #       F - - - -
  await asm_write(dut, 0x018, "addi x2 x0 1")
  #                            addi x2 x0 1   #         F D X M W
  #                            addi x1 x1 4   #           F D X M W      (W-D)
  #                            jr x1          #             F D X M W    (X-D)
  #                            jal x1 0x004   #               F - - - -
  #                            addi x2 x0 1   #                 F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x001)

if __name__ == "__main__":
  run("Proc_jal_test", "test_simple")
  run("Proc_jal_test", "test_forward_jal")
  run("Proc_jal_test", "test_backward_jal")