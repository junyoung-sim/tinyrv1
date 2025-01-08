#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# SW: test_simple
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x080") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x001") #   F D X M W

  await asm_write(dut, 0x008, "lw x3 -8(x1)"    ) #     F D X M W     (M-D)
  await asm_write(dut, 0x00c, "sw x2 -8(x1)"    ) #       F D X M W   (W-D, M-D)
  await asm_write(dut, 0x010, "lw x3 -8(x1)"    ) #         F D X M W

  await asm_write(dut, 0x014, "lw x3 -4(x1)"    )
  await asm_write(dut, 0x018, "sw x2 -4(x1)"    )
  await asm_write(dut, 0x01c, "lw x3 -4(x1)"    )

  await asm_write(dut, 0x020, "lw x3 0(x1)"     )
  await asm_write(dut, 0x024, "sw x2 0(x1)"     )
  await asm_write(dut, 0x028, "lw x3 0(x1)"     )
  
  await asm_write(dut, 0x02c, "lw x3 4(x1)"     )
  await asm_write(dut, 0x030, "sw x2 4(x1)"     )
  await asm_write(dut, 0x034, "lw x3 4(x1)"     )

  await asm_write(dut, 0x038, "lw x3 8(x1)"     )
  await asm_write(dut, 0x03c, "sw x2 8(x1)"     )
  await asm_write(dut, 0x040, "lw x3 8(x1)"     )

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x080)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x001)
  
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x001)

  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)
  await check_trace(dut, 0x001)

#===========================================================
# SW: test_addi_sw
#===========================================================

@cocotb.test()
async def test_addi_sw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0f0") # F D X M W
  await asm_write(dut, 0x004, "sw x1 0(x1)"     ) #   F D X M W     (X-D)

  await asm_write(dut, 0x008, "addi x2 x0 0x0f4") # F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x010, "sw x2 0(x2)"     ) #     F D X M W   (M-D)

  await asm_write(dut, 0x014, "addi x3 x0 0x0f8") # F D X M W
  await asm_write(dut, 0x018, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x020, "sw x3 0(x3)"     ) #       F D X M W (W-D)

  await asm_write(dut, 0x024, "addi x4 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #   F D X M W
  await asm_write(dut, 0x02c, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x030, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x034, "sw x4 0(x4)"     ) #         F D X M W

  await asm_write(dut, 0x038, "lw x1 0(x1)"     )
  await asm_write(dut, 0x03c, "lw x2 0(x2)"     )
  await asm_write(dut, 0x040, "lw x3 0(x3)"     )
  await asm_write(dut, 0x044, "lw x4 0(x4)"     )

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0f0)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f4)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f8)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f0)
  await check_trace(dut, 0x0f4)
  await check_trace(dut, 0x0f8)
  await check_trace(dut, 0x0fc)

#===========================================================
# SW: test_add_sw
#===========================================================

@cocotb.test()
async def test_add_sw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0f0") # F D X M W
  await asm_write(dut, 0x004, "add x1 x0 x1"    ) #   F D X M W       (X-D)
  await asm_write(dut, 0x008, "sw x1 0(x1)"     ) #     F D X M W     (X-D)

  await asm_write(dut, 0x00c, "addi x2 x0 0x0f4") # F D X M W
  await asm_write(dut, 0x010, "add x2 x0 x2"    ) #   F D X M W       (X-D)
  await asm_write(dut, 0x014, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x018, "sw x2 0(x2)"     ) #       F D X M W   (M-D)

  await asm_write(dut, 0x01c, "addi x3 x0 0x0f8") # F D X M W
  await asm_write(dut, 0x020, "add x3 x0 x3"    ) #   F D X M W       (X-D)
  await asm_write(dut, 0x024, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x02c, "sw x3 0(x3)"     ) #         F D X M W (W-D)

  await asm_write(dut, 0x030, "addi x4 x0 0x0fc") # F D X M W
  await asm_write(dut, 0x034, "add x4 x0 x4"    ) #   F D X M W       (X-D)
  await asm_write(dut, 0x038, "add x0 x0 x0"    ) #     F D X M W
  await asm_write(dut, 0x03c, "add x0 x0 x0"    ) #       F D X M W
  await asm_write(dut, 0x040, "add x0 x0 x0"    ) #         F D X M W
  await asm_write(dut, 0x044, "sw x4 0(x4)"     ) #           F D X M W

  await asm_write(dut, 0x048, "lw x1 0(x1)"     )
  await asm_write(dut, 0x04c, "lw x2 0(x2)"     )
  await asm_write(dut, 0x050, "lw x3 0(x3)"     )
  await asm_write(dut, 0x054, "lw x4 0(x4)"     )

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, 0x0f0)
  await check_trace(dut, 0x0f0)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f4)
  await check_trace(dut, 0x0f4)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f8)
  await check_trace(dut, 0x0f8)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x0fc)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await RisingEdge(dut.clk)

  await check_trace(dut, 0x0f0)
  await check_trace(dut, 0x0f4)
  await check_trace(dut, 0x0f8)
  await check_trace(dut, 0x0fc)

#===========================================================
# SW: test_mul_sw
#===========================================================

@cocotb.test()
async def test_mul_sw(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("Proc_sw_test", "test_simple")
  if (test_case < 0) | (test_case == 1):
    run("Proc_sw_test", "test_addi_sw")
  if (test_case < 0) | (test_case == 2):
    run("Proc_sw_test", "test_add_sw")