import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, sel, in0, in1, in2, in3, out):
  dut.sel.value = sel
  dut.in0.value = in0
  dut.in1.value = in1
  dut.in2.value = in2
  dut.in3.value = in3

  await Timer(10, units="ns")
  assert dut.out.value == out

@cocotb.test()
async def test_random(dut):

  # randomly select random inputs

  for t in range(1000000):
    sel = random.randint(0, 1)
    in0 = random.randint(0, pow(2,32)-1)
    in1 = random.randint(0, pow(2,32)-1)
    in2 = random.randint(0, pow(2,32)-1)
    in3 = random.randint(0, pow(2,32)-1)

    if sel == 0:
      out = in0
    elif sel == 1:
      out = in1
    elif sel == 2:
      out = in2
    elif sel == 3:
      out = in3

    await check(dut, sel, in0, in1, out)