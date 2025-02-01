#!/usr/bin/env python3

import sys
from TinyRV1 import *

#===========================================================
# Dot Product
#===========================================================

@cocotb.test()
async def dot(dut):
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
  await asm_write(dut, 0x034, "jal x0 0x034"    )

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

  for i in range(size):
    await check_trace(dut, A[i])
    await check_trace(dut, B[i])
    await RisingEdge(dut.clk)
    await check_trace(dut, A[i] * B[i])

    dot    += A[i] * B[i]
    addr_A += 0x004
    addr_B += 0x004
    size   -= 0x001

    await check_trace(dut, dot)
    await check_trace(dut, addr_A)
    await check_trace(dut, addr_B)
    await check_trace(dut, size)

    await RisingEdge(dut.clk)
    if (i != 3):
      await RisingEdge(dut.clk)
      await RisingEdge(dut.clk)
  
  await RisingEdge(dut.clk)

  for i in range(3):
    await check_trace(dut, 0x038)
    await RisingEdge(dut.clk)

#===========================================================
# Addition
#===========================================================

@cocotb.test()
async def add(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  A = [1, 2, 3, 4]
  B = [1, 2, 3, 4]
  C = [0, 0, 0, 0]

  await data(dut, 0x0a0, A[0]) # A
  await data(dut, 0x0a4, A[1]) #
  await data(dut, 0x0a8, A[2]) #
  await data(dut, 0x0ac, A[3]) #
  await data(dut, 0x0b0, B[0]) # B
  await data(dut, 0x0b4, B[1]) #
  await data(dut, 0x0b8, B[2]) #
  await data(dut, 0x0bc, B[3]) #
  await data(dut, 0x0c0, C[0]) # C = A + B
  await data(dut, 0x0c4, C[1]) #
  await data(dut, 0x0c8, C[2]) #
  await data(dut, 0x0cc, C[3]) #

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0a0")
  await asm_write(dut, 0x004, "addi x2 x0 0x0b0")
  await asm_write(dut, 0x008, "addi x3 x0 0x0c0")
  await asm_write(dut, 0x00c, "addi x4 x0 4"    )
  await asm_write(dut, 0x010, "lw x5 0(x1)"     )
  await asm_write(dut, 0x014, "lw x6 0(x2)"     )
  await asm_write(dut, 0x018, "add x5 x5 x6"    )
  await asm_write(dut, 0x01c, "sw x5 0(x3)"     )
  await asm_write(dut, 0x020, "addi x1 x1 0x004")
  await asm_write(dut, 0x024, "addi x2 x2 0x004")
  await asm_write(dut, 0x028, "addi x3 x3 0x004")
  await asm_write(dut, 0x02c, "addi x4 x4 -1"   )
  await asm_write(dut, 0x030, "bne x0 x4 0x010" )
  await asm_write(dut, 0x034, "jal x0 0x034"    )

  await reset(dut)

  # Check Traces

  addr_A = 0x0a0
  addr_B = 0x0b0
  addr_C = 0x0c0
  size   = 0x004

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, addr_A)
  await check_trace(dut, addr_B)
  await check_trace(dut, addr_C)
  await check_trace(dut, size)

  for i in range(size):
    await check_trace(dut, A[i])
    await check_trace(dut, B[i])
    await RisingEdge(dut.clk)

    C[i] = A[i] + B[i]

    await check_trace(dut, C[i])
    await RisingEdge(dut.clk)

    addr_A += 0x004
    addr_B += 0x004
    addr_C += 0x004
    size   -= 0x001

    await check_trace(dut, addr_A)
    await check_trace(dut, addr_B)
    await check_trace(dut, addr_C)
    await check_trace(dut, size)

    await RisingEdge(dut.clk)
    if (i != 3):
      await RisingEdge(dut.clk)
      await RisingEdge(dut.clk)
  
  for i in range(3):
    await check_trace(dut, 0x038)
    await RisingEdge(dut.clk)

#===========================================================
# Subtraction
#===========================================================

@cocotb.test()
async def sub(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Data Memory

  A = [1, 2, 3, 4]
  B = [1, 2, 3, 4]
  C = [0, 0, 0, 0]

  await data(dut, 0x0a0, A[0]) # A
  await data(dut, 0x0a4, A[1]) #
  await data(dut, 0x0a8, A[2]) #
  await data(dut, 0x0ac, A[3]) #
  await data(dut, 0x0b0, B[0]) # B
  await data(dut, 0x0b4, B[1]) #
  await data(dut, 0x0b8, B[2]) #
  await data(dut, 0x0bc, B[3]) #
  await data(dut, 0x0c0, C[0]) # C = A - B
  await data(dut, 0x0c4, C[1]) #
  await data(dut, 0x0c8, C[2]) #
  await data(dut, 0x0cc, C[3]) #

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0x0a0")
  await asm_write(dut, 0x004, "addi x2 x0 0x0b0")
  await asm_write(dut, 0x008, "addi x3 x0 0x0c0")
  await asm_write(dut, 0x00c, "addi x4 x0 4"    )
  await asm_write(dut, 0x010, "lw x5 0(x1)"     )
  await asm_write(dut, 0x014, "lw x6 0(x2)"     )
  await asm_write(dut, 0x018, "addi x7 x0 -1"   )
  await asm_write(dut, 0x01c, "mul x6 x6 x7"    )
  await asm_write(dut, 0x020, "add x5 x5 x6"    )
  await asm_write(dut, 0x024, "sw x5 0(x3)"     )
  await asm_write(dut, 0x028, "addi x1 x1 0x004")
  await asm_write(dut, 0x02c, "addi x2 x2 0x004")
  await asm_write(dut, 0x030, "addi x3 x3 0x004")
  await asm_write(dut, 0x034, "addi x4 x4 -1"   )
  await asm_write(dut, 0x038, "bne x0 x4 0x010" )
  await asm_write(dut, 0x03c, "jal x0 0x03c"    )

  await reset(dut)

  # Check Trace

  addr_A = 0x0a0
  addr_B = 0x0b0
  addr_C = 0x0c0
  size   = 0x004

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)

  await check_trace(dut, addr_A)
  await check_trace(dut, addr_B)
  await check_trace(dut, addr_C)
  await check_trace(dut, size)

  for i in range(size):
    await check_trace(dut, A[i])
    await check_trace(dut, B[i])
    
    await check_trace(dut, 0xffffffff)
    await check_trace(dut, -B[i] % (1<<32))

    C[i] = A[i] - B[i]

    await check_trace(dut, C[i])
    await RisingEdge(dut.clk)

    addr_A += 0x004
    addr_B += 0x004
    addr_C += 0x004
    size   -= 0x001

    await check_trace(dut, addr_A)
    await check_trace(dut, addr_B)
    await check_trace(dut, addr_C)
    await check_trace(dut, size)

    await RisingEdge(dut.clk)
    if (i != 3):
      await RisingEdge(dut.clk)
      await RisingEdge(dut.clk)
  
  for i in range(3):
    await check_trace(dut, 0x040)
    await RisingEdge(dut.clk)

#===========================================================

if __name__ == "__main__":
  test_case = int(sys.argv[1])
  if (test_case < 0) | (test_case == 0):
    run("test_prog", "dot")
  if (test_case < 0) | (test_case == 1):
    run("test_prog", "add")
  if (test_case < 0) | (test_case == 2):
    run("test_prog", "sub")