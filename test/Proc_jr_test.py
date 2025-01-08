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

  await asm_write(dut, 0x000, "addi x1 x0 0x010") # F D X M W
  await asm_write(dut, 0x004, "jr x1"           ) #   F D X M W      (X-D)
  await asm_write(dut, 0x008, "add x0 x0 x0"    ) #     F - - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x010, "addi x1 x0 0x024") # F D X M W
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x018, "jr x1"           ) #     F D X M W    (M-D)
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #       F - - - -
  await asm_write(dut, 0x020, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x024, "addi x1 x0 0x03c") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x030, "jr x1"           ) #       F D X M W  (W-D)
  await asm_write(dut, 0x034, "add x0 x0 x0"    ) #         F - - - -
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x03c, "addi x1 x0 0x000") # F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x044, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x048, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x04c, "jr x1"           ) #         F D X M W
  await asm_write(dut, 0x050, "add x0 x0 x0"    ) #           F - - - -
  #                            addi x1 x0 0x010   #             F D X M W
  #                                   ...         #                ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x010)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x024)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x03c)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# JR: test_add_jr
#===========================================================

@cocotb.test()
async def test_add_jr(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x014") # F D X M W
  await asm_write(dut, 0x004, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "jr x1"           ) #     F D X M W       (X-D)
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #       F - - - -
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x014, "addi x1 x0 0x02c") # F D X M W
  await asm_write(dut, 0x018, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x020, "jr x1"           ) #       F D X M W     (M-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #         F - - - -
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x02c, "addi x1 x0 0x048") # F D X M W
  await asm_write(dut, 0x030, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x034, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x03c, "jr x1"           ) #         F D X M W   (W-D)
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #           F - - - -
  await asm_write(dut, 0x044, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x048, "addi x1 x0 0x000") # F D X M W
  await asm_write(dut, 0x04c, "add x1 x0 x1"    ) #   F D X M W         (X-D)
  await asm_write(dut, 0x050, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x054, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x058, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x05c, "jr x1"           ) #           F D X M W
  await asm_write(dut, 0x060, "add x0 x0 x0"    ) #             F - - - -
  #                            addi x1 x0 0x014   #               F D X M W
  #                                   ...         #                  ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x014)
    await check_trace(dut, 0x014)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x02c)
    await check_trace(dut, 0x02c)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x048)
    await check_trace(dut, 0x048)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================
# JR: test_mul_jr
#===========================================================

@cocotb.test()
async def test_mul_jr(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x018") #   F D X M W
  await asm_write(dut, 0x008, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x00c, "jr x1"           ) #       F D X M W       (X-D)
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #         F - - - -
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x018, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x01c, "addi x2 x0 0x034") #   F D X M W
  await asm_write(dut, 0x020, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x028, "jr x1"           ) #         F D X M W     (M-D)
  await asm_write(dut, 0x02c, "add x0 x0 x0"    ) #           F - - - -
  await asm_write(dut, 0x030, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x034, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x038, "addi x2 x0 0x054") #   F D X M W
  await asm_write(dut, 0x03c, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x044, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x048, "jr x1"           ) #           F D X M W   (W-D)
  await asm_write(dut, 0x04c, "add x0 x0 x0"    ) #             F - - - -
  await asm_write(dut, 0x050, "add x0 x0 x0"    ) #

  await asm_write(dut, 0x054, "addi x1 x0 0x001") # F D X M W
  await asm_write(dut, 0x058, "addi x2 x0 0x000") #   F D X M W
  await asm_write(dut, 0x05c, "mul x1 x1 x2"    ) #     F D X M W         (M-D, X-D)
  await asm_write(dut, 0x060, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x064, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x068, "add x0 x0 x0"    ) #           F D X M W
  await asm_write(dut, 0x06c, "jr x1"           ) #             F D X M W
  await asm_write(dut, 0x070, "add x0 x0 x0"    ) #               F - - - -
  #                            addi x1 x0 0x001   #                 F D X M W
  #                            addi x2 x0 0x018   #                   F D X M W
  #                                   ...         #                      ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x001)
    await check_trace(dut, 0x018)
    await check_trace(dut, 0x018)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x001)
    await check_trace(dut, 0x034)
    await check_trace(dut, 0x034)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x001)
    await check_trace(dut, 0x054)
    await check_trace(dut, 0x054)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x001)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
  
#===========================================================
# JR: test_lw_jr
#===========================================================

@cocotb.test()
async def test_lw_jr(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  await data(dut, 0x0f0, 0x020)
  await data(dut, 0x0f4, 0x00c)
  await data(dut, 0x0f8, 0x030)
  await data(dut, 0x0fc, 0x000)
  
  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0f0") # F D X M W
  await asm_write(dut, 0x004, "lw x2 0(x1)"     ) #   F D X M W          (X-D)
  await asm_write(dut, 0x008, "jr x2"           ) #     F D D X M W      (M-D)
  #                    0x00c   addi x1 x0 0x0f8   #       F F - - - -
  #                    0x020   addi x1 x0 0x0f4   #           F D X M W
  #                                  ...          #              ...

  await asm_write(dut, 0x00c, "addi x1 x0 0x0f8") # F D X M W
  await asm_write(dut, 0x010, "lw x2 0(x1)"     ) #   F D X M W          (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x01c, "jr x2"           ) #         F D X M W    (W-D)
  #                    0x020   addi x1 x0 0x0f4   #           F - - - -
  #                    0x030   addi x1 x0 0x0fc   #             F D X M W
  #                                  ...          #                ...

  await asm_write(dut, 0x020, "addi x1 x0 0x0f4") # F D X M W
  await asm_write(dut, 0x024, "lw x2 0(x1)"     ) #   F D X M W          (X-D)
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x02c, "jr x2"           ) #       F D X M W      (M-D)
  #                    0x030   addi x1 x0 0x0fc   #         F - - - -
  #                    0x00c   addi x1 x0 0x0f8   #           F D X M W
  #                                  ...          #              ...

  await asm_write(dut, 0x030, "addi x1 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "lw x2 0(x1)"     ) #   F D X M W          (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "jr x2"           ) #           F D X M W
  await asm_write(dut, 0x048, "add x0 x0 x0"    ) #             F - - - -
  #                    0x000   addi x1 x0 0x0f0   #               F D X M W
  #                                  ...          #                  ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  for i in range(3):
    await check_trace(dut, 0x0f0)
    await check_trace(dut, 0x020)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x0f4)
    await check_trace(dut, 0x00c)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x0f8)
    await check_trace(dut, 0x030)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await check_trace(dut, 0x0fc)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await check_trace(dut, 0x000)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_jr_test", "test_simple")
  if (test_case < 0) | (test_case == 1):
    run("Proc_jr_test", "test_addi_jr")
  if (test_case < 0) | (test_case == 2):
    run("Proc_jr_test", "test_add_jr")
  if (test_case < 0) | (test_case == 3):
    run("Proc_jr_test", "test_mul_jr")
  if (test_case < 0) | (test_case == 4):
    run("Proc_jr_test", "test_lw_jr")