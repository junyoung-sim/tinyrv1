import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, in0, in1, prod):
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(10, units="ns")
  assert dut.prod.value == prod

@cocotb.test()
async def test_simple(dut):
  
  # test simple multiplication

  await check(dut, 0, 1, 0)
  await check(dut, 1, 1, 1)
  await check(dut, 1, 2, 2)

@cocotb.test()
async def test_random(dut):

  # test multiplication with random inputs

  for t in range(1000000):
    in0  = random.randint(0, pow(2,32)-1)
    in1  = random.randint(0, pow(2,32)-1)
    prod = (in0 * in1) & 0xffffffff

    await check(dut, in0, in1, prod)