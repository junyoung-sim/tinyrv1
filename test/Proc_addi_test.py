import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

from TinyRV1 import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#===========================================================
# Processor Interface
#===========================================================

async def asm_write(dut, addr, inst_s):
  dut.ext_dmemreq_val.value   = 1
  dut.ext_dmemreq_type.value  = 1
  dut.ext_dmemreq_addr.value  = addr
  dut.ext_dmemreq_wdata.value = asm(inst_s)

  await RisingEdge(dut.clk)
  assert dut.ext_dmemreq_rdata.value == x

async def reset(dut):
  dut.rst.value = 1
  dut.ext_dmemreq_val.value   = 0
  dut.ext_dmemreq_type.value  = 0
  dut.ext_dmemreq_addr.value  = 0
  dut.ext_dmemreq_wdata.value = 0
  await RisingEdge(dut.clk)
  
  dut.rst.value = 0
  await RisingEdge(dut.clk)

async def check_trace(dut, trace_data):
  await RisingEdge(dut.clk)
  assert dut.trace_data.value == trace_data

#===========================================================
# ADDI
#===========================================================

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2") #   F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 1)
  await check_trace(dut, 2)

@cocotb.test()
async def test_imm_bound_valid(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2047" ) # F D X M W
  await asm_write(dut, 0x004, "addi x1 x0 -2048") #   F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut,  2047 & 0xffffffff)
  await check_trace(dut, -2048 & 0xffffffff)

@cocotb.test()
async def test_imm_bound_invalid_1(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 2048") # F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 2048) # FAIL

@cocotb.test()
async def test_imm_bound_invalid_2(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 -2049") # F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, -2049) # FAIL

@cocotb.test()
async def test_raw_bypass(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2") #   F D X M W
  await asm_write(dut, 0x008, "add x3 x1 x2") #     F D X M W           (M-D, X-D)
  await asm_write(dut, 0x00c, "addi x4 x1 3") #       F D X M W         (W-D)
  await asm_write(dut, 0x010, "addi x5 x1 4") #         F D X M W
  await asm_write(dut, 0x014, "add x6 x2 x4") #           F D X M W     (M-D)
  await asm_write(dut, 0x018, "add x7 x1 x6") #             F D X M W   (X-D)
  await asm_write(dut, 0x01c, "add x8 x3 x5") #               F D X M W (W-D)


  await reset(dut)

  # Check Traces
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 1)
  await check_trace(dut, 2)
  await check_trace(dut, 3)
  await check_trace(dut, 4)
  await check_trace(dut, 5)
  await check_trace(dut, 6)
  await check_trace(dut, 7)
  await check_trace(dut, 8)
