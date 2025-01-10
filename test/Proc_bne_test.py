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
# BNE: test_branch_squashed
#===========================================================

@cocotb.test()
async def test_branch_squashed(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x008") #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "jal x0 0x014"   ) #     F D - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"   ) #       F - - - -
  #                    0x008   jal x0 0x014      #         F D X M W
  #                    0x00c   add x0 x0 x0      #           F - - - -

  await asm_write(dut, 0x010, "add x0 x0 x0"   ) #
  await asm_write(dut, 0x014, "bne x0 x1 0x01c") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0"   ) #   F D - - -
  await asm_write(dut, 0x01c, "jal x0 0x000"   ) #     F F D X M W
  await asm_write(dut, 0x020, "add x0 x0 x0"   ) #         F - - - -
  #                    0x000   addi x1 x0 1      #           F D X M W
  #                                 ...          #              ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 1)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x00c)
    await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await check_trace(dut, 0x020)
    await RisingEdge(dut.clk)

#===========================================================
# BNE: test_addi_bne
#===========================================================

@cocotb.test()
async def test_addi_bne(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0"   ) #   F D X M W
  await asm_write(dut, 0x008, "bne x1 x2 0x000") #     F D X M W       (M-D, X-D)

  await asm_write(dut, 0x00c, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x010, "addi x2 x0 0"   ) #   F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x018, "bne x1 x2 0x000") #       F D X M W     (W-D, M-D)

  await asm_write(dut, 0x01c, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x020, "addi x2 x0 0"   ) #   F D X M W
  await asm_write(dut, 0x024, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x02c, "bne x1 x2 0x000") #         F D X M W   (---, W-D)

  await asm_write(dut, 0x030, "addi x2 x0 1"   ) #   F D X M W
  await asm_write(dut, 0x034, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x03c, "addi x1 x0 0"   ) #         F D X M W
  await asm_write(dut, 0x040, "bne x1 x2 0x000") #           F D X M W (X-D, ---)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 1)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# BNE: test_add_bne
#===========================================================

@cocotb.test()
async def test_add_bne(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "add x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x004, "add x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x008, "bne x1 x2 0x000") #     F D X M W       (M-D, X-D)

  await asm_write(dut, 0x00c, "add x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x010, "add x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x018, "bne x1 x2 0x000") #       F D X M W     (W-D, M-D)

  await asm_write(dut, 0x01c, "add x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x020, "add x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x024, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x02c, "bne x1 x2 0x000") #         F D X M W   (---, W-D)

  await asm_write(dut, 0x030, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x034, "add x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x040, "add x1 x0 x1"   ) #         F D X M W
  await asm_write(dut, 0x044, "bne x1 x2 0x000") #           F D X M W (X-D, ---)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 1)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 1)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# BNE: test_mul_bne
#===========================================================

@cocotb.test()
async def test_mul_bne(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "mul x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x004, "mul x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x008, "bne x1 x2 0x000") #     F D X M W       (M-D, X-D)

  await asm_write(dut, 0x00c, "mul x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x010, "mul x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x018, "bne x1 x2 0x000") #       F D X M W     (W-D, M-D)

  await asm_write(dut, 0x01c, "mul x1 x0 x0"   ) # F D X M W
  await asm_write(dut, 0x020, "mul x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x024, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x02c, "bne x1 x2 0x000") #         F D X M W   (---, W-D)

  await asm_write(dut, 0x030, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x034, "mul x2 x0 x0"   ) #   F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0"   ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x040, "mul x1 x1 x1"   ) #         F D X M W
  await asm_write(dut, 0x044, "bne x1 x2 0x000") #           F D X M W (X-D, ---)

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await RisingEdge(dut.clk)

    await check_trace(dut, 1)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 0)
    await check_trace(dut, 1)
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
  if (test_case < 0) | (test_case == 3):
    run("Proc_bne_test", "test_branch_squashed")
  if (test_case < 0) | (test_case == 4):
    run("Proc_bne_test", "test_addi_bne")
  if (test_case < 0) | (test_case == 5):
    run("Proc_bne_test", "test_add_bne")
  if (test_case < 0) | (test_case == 6):
    run("Proc_bne_test", "test_mul_bne")