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
  assert dut.imemresp_data.value == imemresp_data, "FAILED (imem)"
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