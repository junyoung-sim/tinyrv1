#!/usr/bin/env python3

from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 100"  ) #   F D X M W
  await asm_write(dut, 0x008, "sw x2 0(x1)"     ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x014, "lw x3 0(x1)"     ) #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0x00000064)
  await check_trace(dut, 0x00000064)
  await check_trace(dut, 0x00000000)
  await check_trace(dut, 0x00000000)
  await check_trace(dut, 0x00000064)

@cocotb.test()
async def test_imm(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 100"  ) #   F D X M W
  await asm_write(dut, 0x008, "sw x2 -8(x1)"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x00c, "sw x2 -4(x1)"    ) #       F D X M W       (W-D, M-D)
  await asm_write(dut, 0x010, "sw x2 0(x1)"     ) #         F D X M W     (---, W-D)
  await asm_write(dut, 0x014, "sw x2 4(x1)"     ) #           F D X M W
  await asm_write(dut, 0x018, "sw x2 8(x1)"     ) #             F D X M W
  await asm_write(dut, 0x01c, "lw x3 -8(x1)"    ) #               F D X M W
  await asm_write(dut, 0x020, "lw x3 -4(x1)"    ) #                 F D X M W
  await asm_write(dut, 0x024, "lw x3 0(x1)"     ) #                   F D X M W
  await asm_write(dut, 0x028, "lw x3 4(x1)"     ) #                     F D X M W
  await asm_write(dut, 0x02c, "lw x3 8(x1)"     ) #                       F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x00000080)
  await check_trace(dut, 0x00000064)
  await check_trace(dut, 0x00000064) # sw
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) # lw
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #
  await check_trace(dut, 0x00000064) #

if __name__ == "__main__":
  run("Proc_sw_test", "test_simple")
  run("Proc_sw_test", "test_imm")