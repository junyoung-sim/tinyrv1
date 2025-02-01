import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, op, in0, in1, out):
  dut.op.value  = op
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(10, units="ns")
  assert dut.out.value == out

@cocotb.test()
async def test_simple_add(dut):

  # test adder

  await check(dut, 0, 0, 0, 0)
  await check(dut, 0, 0, 1, 1)

@cocotb.test()
async def test_simple_eq_comp(dut):

  # test equality comparator

  await check(dut, 1, 0, 0, 1)
  await check(dut, 1, 0, 1, 0)

@cocotb.test()
async def test_random(dut):

  # randomly choose ALU function and inputs

  for t in range(1000000):
    op  = random.randint(0, 1)
    in0 = random.randint(0, pow(2,32)-1)

    if op == 0:
      in1 = random.randint(0, pow(2,32)-1)
      out = (in0 + in1) & 0xffffffff

    elif op == 1:
      eq  = random.randint(0, 1)
      in1 = in0
      while (eq == 0) & (in0 == in1):
        in1 = random.randint(0, pow(2,32)-1)
      out = eq
    
    await check(dut, op, in0, in1, out)
