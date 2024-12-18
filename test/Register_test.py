import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

async def check(dut, rst, en, d, q):
  dut.rst.value = rst
  dut.en.value  = en
  dut.d.value   = d

  await RisingEdge(dut.clk)
  assert dut.q.value == q

@cocotb.test()
async def test_reset(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # test register reset behavior

  await check(dut, 0, 0, 0, x)
  await check(dut, 1, 0, 0, x)
  await check(dut, 0, 0, 0, 0)

@cocotb.test()
async def test_enable(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # test register enable behavior

  await check(dut, 1, 0, 0x00000000, x         )
  await check(dut, 0, 1, 0xabcdabcd, 0x00000000)
  await check(dut, 0, 1, 0xcafe2300, 0xabcdabcd)
  await check(dut, 0, 1, 0xdeadbeef, 0xcafe2300)
  await check(dut, 0, 0, 0xffffffff, 0xdeadbeef)
  await check(dut, 0, 0, 0xffffffff, 0xdeadbeef)

@cocotb.test()
async def test_random(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  q = x

  for t in range(1000000):
    rst = random.randint(0, 1)
    en  = random.randint(0, 1)
    d   = random.randint(0, pow(2,32)-1)

    await check(dut, rst, en, d, q)

    if rst:
      q = 0
    elif en:
      q = d