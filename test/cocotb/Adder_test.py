import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, in0, in1, sum):
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(10, units="ns")
  assert dut.sum.value == sum

@cocotb.test()
async def test_simple(dut):
  
  # test simple addition

  await check(dut, 0, 0, 0)
  await check(dut, 1, 1, 2)
  await check(dut, 1, 2, 3)

@cocotb.test()
async def test_random(dut):

  # test addition with random inputs

  for t in range(1000000):
    in0 = random.randint(0, pow(2,32)-1)
    in1 = random.randint(0, pow(2,32)-1)
    sum = (in0 + in1) & 0xffffffff

    await check(dut, in0, in1, sum)