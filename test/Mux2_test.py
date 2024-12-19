import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def check(dut, sel, in0, in1, out):
  dut.sel.value = sel
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(10, units="ns")
  assert dut.out.value == out

@cocotb.test()
async def test_simple(dut):

  # simple input selection

  await check(dut, 0, 0xbeefcafe, 0xfeedbeef, 0xbeefcafe)
  await check(dut, 1, 0xbeefcafe, 0xfeedbeef, 0xfeedbeef)

@cocotb.test()
async def test_random(dut):

  # randomly select random inputs

  for t in range(1000000):
    sel = random.randint(0, 1)
    in0 = random.randint(0, pow(2,32)-1)
    in1 = random.randint(0, pow(2,32)-1)

    out = in0

    if sel:
      out = in1

    await check(dut, sel, in0, in1, out)