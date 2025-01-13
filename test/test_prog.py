#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# Dot Product
#===========================================================

@cocotb.test()
async def dot_product(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  A = [1, 2, 3, 4]
  B = [1, 2, 3, 4]

  await data(dut, 0x0a0, A[0]) # A
  await data(dut, 0x0a4, A[1]) #
  await data(dut, 0x0a8, A[2]) #
  await data(dut, 0x0ac, A[3]) #
  await data(dut, 0x0b0, B[0]) # B
  await data(dut, 0x0b4, B[1]) #
  await data(dut, 0x0b8, B[2]) #
  await data(dut, 0x0bc, B[3]) #

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0a0")
  await asm_write(dut, 0x004, "addi x2 x0 0x0b0")
  await asm_write(dut, 0x008, "addi x3 x0 4"    )
  await asm_write(dut, 0x00c, "addi x4 x0 0"    )
  await asm_write(dut, 0x010, "lw x5 0(x1)"     )
  await asm_write(dut, 0x014, "lw x6 0(x2)"     )
  await asm_write(dut, 0x018, "mul x5 x5 x6"    )
  await asm_write(dut, 0x01c, "add x4 x4 x5"    )
  await asm_write(dut, 0x020, "addi x1 x1 0x004")
  await asm_write(dut, 0x024, "addi x2 x2 0x004")
  await asm_write(dut, 0x028, "addi x3 x3 -1"   )
  await asm_write(dut, 0x02c, "bne x0 x3 0x010" )
  await asm_write(dut, 0x030, "sw x4 0(x2)"     )
  await asm_write(dut, 0x034, "lw x4 0(x2)"     )
  await asm_write(dut, 0x038, "jal x0 0x038"    )

  await reset(dut)

  # Check Traces

  addr_A = 0x0a0
  addr_B = 0x0b0
  size   = 0x004
  dot    = 0x000

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, addr_A)
  await check_trace(dut, addr_B)
  await check_trace(dut, size)
  await check_trace(dut, dot)

  for i in range(4):
    await check_trace(dut, A[i])
    await check_trace(dut, B[i])
    await RisingEdge(dut.clk)
    await check_trace(dut, A[i] * B[i])

    dot    += A[i] * B[i]
    addr_A += 0x004
    addr_B += 0x004
    size   -= 1

    await check_trace(dut, dot)
    await check_trace(dut, addr_A)
    await check_trace(dut, addr_B)
    await check_trace(dut, size)

    await RisingEdge(dut.clk)
    if (i != 3):
      await RisingEdge(dut.clk)
      await RisingEdge(dut.clk)
  
  await RisingEdge(dut.clk)
  await check_trace(dut, dot)
  
  for i in range(3):
    await check_trace(dut, 0x03c)
    await RisingEdge(dut.clk)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("test_prog", "dot_product")