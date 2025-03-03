import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

async def check(
    dut, wen, waddr, wdata, raddr0, rdata0, raddr1, rdata1
):
  dut.wen.value    = wen
  dut.waddr.value  = waddr
  dut.wdata.value  = wdata
  dut.raddr0.value = raddr0
  dut.raddr1.value = raddr1

  await RisingEdge(dut.clk)

  assert dut.rdata0.value == rdata0, "FAILED (rdata0)"
  assert dut.rdata1.value == rdata1, "FAILED (rdata1)"

@cocotb.test()
async def test_read_init(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # read initial register values (undefined except x0)

  for i in range(1, 32):
    await check(dut, 0, 0, 0, 0, 0, i, x)
  
@cocotb.test()
async def test_write_x0(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # attempt to write x0 (should not be overwritten)

  await check(dut, 1, 0, 0xabacadab, 0, 0, 1, x)
  await check(dut, 1, 0, 0xcafe2300, 0, 0, 2, x)
  await check(dut, 1, 0, 0xdeadface, 0, 0, 3, x)

@cocotb.test()
async def test_rw_genreg(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # read/write general registers

  wdata = random.randint(0, pow(2,32-1))
  rdata = 0x00000000

  for i in range(1, 32):
    await check(dut, 1, i, wdata, i-1, rdata, i-1, rdata)

    rdata = wdata
    wdata = random.randint(0, pow(2,32-1))
  
  await check(dut, 0, 0, 0, 31, rdata, 31, rdata)

@cocotb.test()
async def test_random(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # randomly read/write registers

  R = [0, x, x, x, x, x, x, x,
       x, x, x, x, x, x, x, x,
       x, x, x, x, x, x, x, x,
       x, x, x, x, x, x, x, x]

  for t in range(1000000):
    wen    = random.randint(0, 1)
    waddr  = random.randint(0, 31)
    wdata  = random.randint(0, pow(2,32)-1)
    raddr0 = random.randint(0, 31)
    rdata0 = random.randint(0, pow(2,32)-1)
    raddr1 = random.randint(0, 31)
    rdata1 = random.randint(0, pow(2,32)-1)
    
    await check(
      dut, wen, waddr, wdata, raddr0, R[raddr0], raddr1, R[raddr1]
    )

    if wen & (waddr != 0):
      R[waddr] = wdata