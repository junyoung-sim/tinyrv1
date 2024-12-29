import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#===========================================================
# Instruction Fields
#===========================================================

IMM_J  = 0b11111111111111111111000000000000 # 31:12
IMM_I  = 0b11111111111100000000000000000000 # 31:20
FUNCT7 = 0b11111110000000000000000000000000 # 31:25
RS2    = 0b00000001111100000000000000000000 # 24:20
RS1    = 0b00000000000011111000000000000000 # 19:15
FUNCT3 = 0b00000000000000000111000000000000 # 14:12
RD     = 0b00000000000000000000111110000000 # 11:7
OPCODE = 0b00000000000000000000000001111111 #  6:0

def get_imm_i(imm):
  return ((imm & 0b111111111111) << 20) & IMM_I

def get_funct7(funct7):
  return (funct7 << 25) & FUNCT7

def get_RS2(rs2):
  return (rs2 << 20) & RS2

def get_RS1(rs1):
  return (rs1 << 15) & RS1

def get_funct3(funct3):
  return (funct3 << 12) & FUNCT3

def get_RD(rd):
  return (rd << 7) & RD

def get_opcode(opcode):
  return opcode & OPCODE

#===========================================================
# Instruction Assembly
#===========================================================

# add rd rs1 rs2
def asm_add(inst_s):
  funct7 = get_funct7(0b0000000)
  rs2    = get_RS2(int(inst_s[3][1:]))
  rs1    = get_RS1(int(inst_s[2][1:]))
  funct3 = get_funct3(0b000)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0110011)
  return funct7 | rs2 | rs1 | funct3 | rd | opcode

# addi rd rs1 imm
def asm_addi(inst_s):
  imm_i  = get_imm_i(int(inst_s[3]))
  rs1    = get_RS1(int(inst_s[2][1:]))
  funct3 = get_funct3(0b000)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0010011)
  return imm_i | rs1 | funct3 | rd | opcode

def asm(inst_s):
  inst_s = inst_s.split()

  if inst_s[0] == "add":
    inst = asm_add(inst_s)
  elif inst_s[0] == "addi":
    inst = asm_addi(inst_s)
  
  return inst

#===========================================================
# DUT Access
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
# ADD
#===========================================================

@cocotb.test()
async def test_add_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "add x1 x0 x0")

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0)

@cocotb.test()
async def test_add_raw_bypass(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "add x1 x0 x0") # F D X M W
  await asm_write(dut, 0x004, "add x2 x1 x0") #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "add x3 x1 x2") #     F D X M W       (M-D, X-D)
  await asm_write(dut, 0x00c, "add x0 x0 x0") #       F D X M W
  await asm_write(dut, 0x010, "add x4 x2 x0") #         F D X M W   (W-D)
  await asm_write(dut, 0x014, "add x5 x1 x1") #           F D X M W

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)
  await check_trace(dut, 0)

#===========================================================
# ADDI
#===========================================================

@cocotb.test()
async def test_addi_simple(dut):
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
async def test_addi_imm_bound_valid(dut):
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
async def test_addi_imm_bound_invalid_1(dut):
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
async def test_addi_imm_bound_invalid_2(dut):
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
async def test_addi_raw_bypass(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 2") #   F D X M W
  await asm_write(dut, 0x008, "add x3 x1 x2") #     F D X M W     (M-D, X-D)
  await asm_write(dut, 0x00c, "addi x4 x1 3") #       F D X M W   (W-D)
  await asm_write(dut, 0x010, "addi x5 x1 4") #         F D X M W

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