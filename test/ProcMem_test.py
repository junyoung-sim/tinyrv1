import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

x = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

async def check (
  dut,
  rst,
  imemreq_val,
  imemreq_addr,
  imemresp_data,
  dmemreq_val,
  dmemreq_type,
  dmemreq_addr,
  dmemreq_wdata,
  dmemresp_rdata
):
  dut.rst.value           = rst
  dut.imemreq_val.value   = imemreq_val
  dut.imemreq_addr.value  = imemreq_addr
  dut.dmemreq_val.value   = dmemreq_val
  dut.dmemreq_type.value  = dmemreq_type
  dut.dmemreq_addr.value  = dmemreq_addr
  dut.dmemreq_wdata.value = dmemreq_wdata

  await RisingEdge(dut.clk)
  assert dut.imemresp_data.value  == imemresp_data,  "FAILED (imem)"
  assert dut.dmemresp_rdata.value == dmemresp_rdata, "FAILED (dmem)"

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  #                    -------imem------- ---------------dmem---------------
  #                rst v  addr data        v  t  addr wdata       rdata
  await check(dut, 0,  0, 0,   x,          0, 0, 0,   0,          x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 0,   0xcafe2300, x         )
  await check(dut, 0,  1, 0,   0xcafe2300, 1, 0, 0,   0,          0xcafe2300)

@cocotb.test()
async def test_reset(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  #                    -------imem------- ---------------dmem---------------
  #                rst v  addr data        v  t  addr wdata       rdata
  await check(dut, 1,  0, 0,   x,          0, 0, 0,   0,          x         )
  await check(dut, 0,  1, 0,   0,          1, 0, 0,   0,          0         )
  await check(dut, 0,  1, 1,   0,          1, 0, 1,   0,          0         )
  await check(dut, 0,  1, 2,   0,          1, 0, 2,   0,          0         )

@cocotb.test()
async def test_dmem_imem(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  #                    -------imem------- ---------------dmem---------------
  #                rst v  addr data        v  t  addr wdata       rdata
  await check(dut, 0,  0, 0,   x,          1, 1, 0,   0xcafe2300, x         )
  await check(dut, 0,  0, 0,   x,          0, 1, 0,   0x00000000, x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 4,   0xacedbead, x         )
  await check(dut, 0,  0, 0,   x,          0, 1, 4,   0x00000000, x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 8,   0xdeadface, x         )
  await check(dut, 0,  0, 0,   x,          0, 1, 8,   0x00000000, x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 12,  0xfeedbeef, x         )
  await check(dut, 0,  0, 0,   x,          0, 1, 12,  0x00000000, x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 16,  0xeeceecee, x         )
  await check(dut, 0,  0, 0,   x,          0, 1, 16,  0x00000000, x         )
  await check(dut, 0,  1, 0,   0xcafe2300, 1, 0, 0,   0,          0xcafe2300)
  await check(dut, 0,  1, 4,   0xacedbead, 1, 0, 4,   0,          0xacedbead)
  await check(dut, 0,  1, 8,   0xdeadface, 1, 0, 8,   0,          0xdeadface)
  await check(dut, 0,  1, 12,  0xfeedbeef, 1, 0, 12,  0,          0xfeedbeef)
  await check(dut, 0,  1, 16,  0xeeceecee, 1, 0, 16,  0,          0xeeceecee)

@cocotb.test()
async def test_random(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

