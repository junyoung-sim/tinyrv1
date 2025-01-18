import cocotb
import subprocess
from cocotb.triggers import *
from cocotb.clock import Clock

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#===========================================================
# Instruction Fields
#===========================================================

IMM_J  = 0b11111111111111111111000000000000 # 31:12
IMM_I  = 0b11111111111100000000000000000000 # 31:20
CSR    = 0b11111111111100000000000000000000 # 31:20
FUNCT7 = 0b11111110000000000000000000000000 # 31:25
RS2    = 0b00000001111100000000000000000000 # 24:20
RS1    = 0b00000000000011111000000000000000 # 19:15
FUNCT3 = 0b00000000000000000111000000000000 # 14:12
RD     = 0b00000000000000000000111110000000 # 11:7
OPCODE = 0b00000000000000000000000001111111 #  6:0

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

def get_imm_i(imm):
  if imm.find("0x") != -1:
    imm = int(imm[2:], 16)
  else:
    imm = int(imm, 10)

  imm = (imm & 0b111111111111)

  return (imm << 20) & IMM_I

def get_imm_s(imm):
  if imm.find("0x") != -1:
    imm = int(imm[2:], 16)
  else:
    imm = int(imm, 10)

  imm = (imm & 0b111111111111)

  return get_funct7(imm >> 5) | get_RD(imm & 0b11111)

def get_imm_j(addr, targ):
  if targ.find("0x") != -1:
    targ = int(targ[2:], 16)
  else:
    targ = int(targ, 10)
  
  imm = (targ - addr) & 0b111111111111111111111

  i1 = (imm & 0b100000000000000000000) >> 1
  i2 = (imm & 0b000000000011111111110) << 8
  i3 = (imm & 0b000000000100000000000) >> 3
  i4 = (imm & 0b011111111000000000000) >> 12

  return ((i1 | i2 | i3 | i4) << 12) & IMM_J

def get_imm_b(addr, targ):
  if targ.find("0x") != -1:
    targ = int(targ[2:], 16)
  else:
    targ = int(targ, 10)
  
  imm = (targ - addr) & 0b1111111111111

  i1 = (imm & 0b1000000000000) >> 6
  i2 = (imm & 0b0011111100000) >> 5
  i3 = (imm & 0b0000000011110)
  i4 = (imm & 0b0100000000000) >> 11

  return get_funct7(i1 | i2) | get_RD(i3 | i4)

#===========================================================
# Coprocessor Registers
#===========================================================

CSR_IN0  = (0xfc2 & 0b111111111111)
CSR_IN1  = (0xfc3 & 0b111111111111)
CSR_IN2  = (0xfc4 & 0b111111111111)
CSR_OUT0 = (0x7c2 & 0b111111111111)
CSR_OUT1 = (0x7c3 & 0b111111111111)
CSR_OUT2 = (0x7c4 & 0b111111111111)

def get_csr_num(csr_num):
  return (csr_num << 20) & CSR

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
  imm_i  = get_imm_i(inst_s[3])
  rs1    = get_RS1(int(inst_s[2][1:]))
  funct3 = get_funct3(0b000)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0010011)
  return imm_i | rs1 | funct3 | rd | opcode

# mul rd rs1 rs2
def asm_mul(inst_s):
  funct7 = get_funct7(0b00000001)
  rs2    = get_RS2(int(inst_s[3][1:]))
  rs1    = get_RS1(int(inst_s[2][1:]))
  funct3 = get_funct3(0b000)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0110011)
  return funct7 | rs2 | rs1 | funct3 | rd | opcode

# lw rd imm(rs1)
def asm_lw(inst_s):
  rd_o   = inst_s[2].find("(")
  rd_c   = inst_s[2].find(")")
  imm_i  = get_imm_i(inst_s[2][:rd_o])
  rs1    = get_RS1(int(inst_s[2][rd_o+1:rd_c][1:]))
  funct3 = get_funct3(0b010)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0000011)
  return imm_i | rs1 | funct3 | rd | opcode

# sw rs2 imm(rs1)
def asm_sw(inst_s):
  rs1_o  = inst_s[2].find("(")
  rs1_c  = inst_s[2].find(")")
  imm_s  = get_imm_s(inst_s[2][:rs1_o])
  rs2    = get_RS2(int(inst_s[1][1:]))
  rs1    = get_RS1(int(inst_s[2][rs1_o+1:rs1_c][1:]))
  funct3 = get_funct3(0b010)
  opcode = get_opcode(0b0100011)
  return imm_s | rs2 | rs1 | funct3 | opcode

# jr rs1
def asm_jr(inst_s):
  rs1    = get_RS1(int(inst_s[1][1:]))
  opcode = get_opcode(0b1100111)
  return rs1 | opcode

# jal rd targ
def asm_jal(addr, inst_s):
  targ   = inst_s[2]
  imm_j  = get_imm_j(addr, targ)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b1101111)
  return imm_j | rd | opcode

# bne rs1 rs2 targ
def asm_bne(addr, inst_s):
  targ = inst_s[3]
  imm_b  = get_imm_b(addr, targ)
  rs1    = get_RS1(int(inst_s[1][1:]))
  rs2    = get_RS2(int(inst_s[2][1:]))
  funct3 = get_funct3(0b001)
  opcode = get_opcode(0b1100011)
  return imm_b | rs1 | rs2 | funct3 | opcode

# csrr rd csr
def asm_csrr(addr, inst_s):
  if (inst_s[2] == "in0"):
    csr_num = CSR_IN0
  elif (inst_s[2] == "in1"):
    csr_num = CSR_IN1
  elif (inst_s[2] == "in2"):
    csr_num = CSR_IN2
  else:
    csr_num = int(inst_s[2], 16)
  
  csr_num = get_csr_num(csr_num)
  rs1     = get_RS1(0b00000)
  funct3  = get_funct3(0b010)
  rd      = get_RD(int(inst_s[1][1:]))
  opcode  = get_opcode(0b1110011)
  return csr_num | rs1 | funct3 | rd | opcode

# csrw csr rs1
def asm_csrw(addr, inst_s):
  if (inst_s[1] == "out0"):
    csr_num = CSR_OUT0
  elif (inst_s[1] == "out1"):
    csr_num = CSR_OUT1
  elif (inst_s[1] == "out2"):
    csr_num = CSR_OUT2
  else:
    csr_num = int(inst_s[1], 16)
  
  csr_num = get_csr_num(csr_num)
  rs1     = get_RS1(int(inst_s[2][1:]))
  funct3  = get_funct3(0b001)
  rd      = get_RD(0b00000)
  opcode  = get_opcode(0b1110011)
  return csr_num | rs1 | funct3 | rd | opcode

def asm(addr, inst_s):
  inst_s = inst_s.split()

  if inst_s[0] == "add":
    inst = asm_add(inst_s)
  elif inst_s[0] == "addi":
    inst = asm_addi(inst_s)
  elif inst_s[0] == "mul":
    inst = asm_mul(inst_s)
  elif inst_s[0] == "lw":
    inst = asm_lw(inst_s)
  elif inst_s[0] == "sw":
    inst = asm_sw(inst_s)
  elif inst_s[0] == "jr":
    inst = asm_jr(inst_s)
  elif inst_s[0] == "jal":
    inst = asm_jal(addr, inst_s)
  elif inst_s[0] == "bne":
    inst = asm_bne(addr, inst_s)
  elif inst_s[0] == "csrr":
    inst = asm_csrr(addr, inst_s)
  elif inst_s[0] == "csrw":
    inst = asm_csrw(addr, inst_s)
  
  return inst

#===========================================================
# Processor Interface
#===========================================================

async def data(dut, addr, wdata):
  dut.ext_dmemreq_val.value   = 1
  dut.ext_dmemreq_type.value  = 1
  dut.ext_dmemreq_addr.value  = addr
  dut.ext_dmemreq_wdata.value = wdata
  await RisingEdge(dut.clk)

async def asm_write(dut, addr, inst_s):
  dut.ext_dmemreq_val.value   = 1
  dut.ext_dmemreq_type.value  = 1
  dut.ext_dmemreq_addr.value  = addr
  dut.ext_dmemreq_wdata.value = asm(addr, inst_s)
  await RisingEdge(dut.clk)

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

def proc_in(dut, in0, in1, in2):
  dut.in0.value = in0
  dut.in1.value = in1
  dut.in2.value = in2

async def check_proc_out(dut, out0, out1, out2):
  await RisingEdge(dut.clk)
  assert dut.out0.value == out0, "FAILED (out0)"
  assert dut.out1.value == out1, "FAILED (out1)"
  assert dut.out2.value == out2, "FAILED (out2)"

#===========================================================
# Test Call
#===========================================================

def run(module, testcase):
  subprocess.run([
    "make",
    "TOPLEVEL=Proc",
    "MODULE=" + module,
    "TESTCASE=" + testcase
  ])