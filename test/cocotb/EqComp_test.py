import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, in0, in1, eq):
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(10, units="ns")
  assert dut.eq.value == eq

@cocotb.test()
async def test_simple(dut):

  # test simple equality comparison

  await check(dut, 0xbeefcafe, 0xfeedbeef, 0)
  await check(dut, 0xcafe2300, 0xcafe2300, 1)

@cocotb.test()
async def test_random(dut):

  # randomly choose if in0 and in1 are equal
  # set in0 and in1 accordingly and check equality

  for t in range(1000000):
    eq  = random.randint(0, 1)
    in0 = random.randint(0, pow(2,32)-1)
    in1 = in0
    
    while (eq == 0) & (in0 == in1):
      in1 = random.randint(0, pow(2,32)-1)
    
    await check(dut, in0, in1, eq)