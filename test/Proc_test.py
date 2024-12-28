import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#===========================================================
# Test Memory
#===========================================================

memsize = pow(2,6)

mem = []
for i in range(memsize):
  mem.append(x)

def data(addr, val):
  mem[addr >> 2] = val

def dump_mem():
  for i in range(memsize):
    addr = format(i << 2, "#005x")
    try:
      print("[{}] {}" .format(addr, format(mem[i], "#010x")))
    except:
      print("[{}] 0x????????" .format(addr))

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

def asm_add(inst_s):
  funct7 = get_funct7(0b0000000)
  rs2    = get_RS2(int(inst_s[3][1:]))
  rs1    = get_RS1(int(inst_s[2][1:]))
  funct3 = get_funct3(0b000)
  rd     = get_RD(int(inst_s[1][1:]))
  opcode = get_opcode(0b0110011)
  return funct7 | rs2 | rs1 | funct3 | rd | opcode

def asm(addr, inst_s):
  inst_s = inst_s.split()

  if inst_s[0] == "add":
    inst = asm_add(inst_s)
  
  data(addr, inst)

if __name__ == "__main__":
  asm( 0x000, "add x4 x4 x6" )

  dump_mem()