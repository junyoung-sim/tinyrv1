import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

async def write(dut, wen, waddr, wdata):
  dut.wen.value   = wen
  dut.waddr.value = waddr
  dut.wdata.value = wdata

  await RisingEdge(dut.clk)

async def read(dut, raddr0, rdata0, raddr1, rdata1):
  dut.raddr0.value = raddr0
  dut.raddr1.value = raddr1

  await RisingEdge(dut.clk)

  assert dut.rdata0.value == rdata0, "FAILED (rdata0)"
  assert dut.rdata1.value == rdata1, "FAILED (rdata1)"

@cocotb.test()
async def test_read_init(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  for i in range(1, 32):
    await read(dut, 0, 0, i, x)