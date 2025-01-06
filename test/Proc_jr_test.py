#!/usr/bin/env python3

from TinyRV1 import *

@cocotb.test()
async def test_forward_jump(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly

  await asm_write(dut, 0x000, "addi x1 x0 0x014") # F D X M W
  await asm_write(dut, 0x004, "jr x1"           ) #   F D X M W    (X-D)
  await asm_write(dut, 0x008, "add x0 x0 x0"    ) #     F - - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"    )
  await asm_write(dut, 0x010, "add x0 x0 x0"    )
  await asm_write(dut, 0x014, "addi x1 x0 1"    ) #       F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x014)
  await check_trace(dut, 0x001)

@cocotb.test()
async def test_backward_jump(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly

  await asm_write(dut, 0x000, "addi x1 x0 0x018") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x010") #   F D X M W
  await asm_write(dut, 0x008, "jr x1"           ) #     F D X M W                (M-D)
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #       F - - - -
  await asm_write(dut, 0x010, "addi x1 x1 1"    )
  await asm_write(dut, 0x014, "addi x1 x1 1"    )
  await asm_write(dut, 0x018, "addi x1 x0 1"    ) #         F D X M W
  await asm_write(dut, 0x01c, "jr x2"           ) #           F D X M W
  await asm_write(dut, 0x020, "add x0 x0 x0"    ) #             F - - - -
  #                            addi x1 x1 1       #               F D X M W      (W-D)
  #                            addi x1 x1 1       #                 F D X M W    (X-D)
  #                            addi x1 x0 1       #                   F D X M W
  #                            jr x2              #                     F D X M W
  #                            add x0 x0 x0       #                       F - - - -
  #                                 ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x010)
  await check_trace(dut, 0x010)
  await check_trace(dut, 0x010)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x003)
  
if __name__ == "__main__":
  run("Proc_jr_test", "test_forward_jump")
  run("Proc_jr_test", "test_backward_jump")