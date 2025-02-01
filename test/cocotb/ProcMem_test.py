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

  # test simple memory read/write

  #                    -------imem------- ---------------dmem---------------
  #                rst v  addr data        v  t  addr wdata       rdata
  await check(dut, 0,  0, 0,   x,          0, 0, 0,   0,          x         )
  await check(dut, 0,  0, 0,   x,          1, 1, 0,   0xcafe2300, x         )
  await check(dut, 0,  1, 0,   0xcafe2300, 1, 0, 0,   0,          0xcafe2300)

@cocotb.test()
async def test_reset(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # test memory reset behavior

  #                    -------imem------- ---------------dmem---------------
  #                rst v  addr data        v  t  addr wdata       rdata
  await check(dut, 1,  0, 0,   x,          0, 0, 0,   0,          x         )
  await check(dut, 0,  1, 0,   0,          1, 0, 0,   0,          0         )
  await check(dut, 0,  1, 4,   0,          1, 0, 4,   0,          0         )
  await check(dut, 0,  1, 8,   0,          1, 0, 8,   0,          0         )

@cocotb.test()
async def test_dmem_imem(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # test memory write via dmem with varying val signal
  # test memory read via both imem and dmem

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

  # randomly read/write memory

  memsize = pow(2,6)

  M = []
  for i in range(memsize):
    M.append(random.randint(0, pow(2,32)-1))
    await check(dut, 0, 0, 0, x, 1, 1, i << 2, M[i], x)
  
  for t in range(1000000):
    rst    = 0
    ival   = random.randint(0, 1)           # imemreq_val
    iaddr  = random.randint(0, memsize-1)   # imemreq_addr
    dval   = random.randint(0, 1)           # dmemreq_val
    dtype  = random.randint(0, 1)           # dmemreq_type
    daddr  = random.randint(0, memsize-1)   # dmemreq_addr
    dwdata = random.randint(0, pow(2,32)-1) # dmemreq_wdata

    irdata = x # imemresp_data
    drdata = x # dmemresp_rdata

    if ival:
      irdata = M[iaddr]
    if dval & (dtype == 0):
      drdata = M[daddr]
    
    await check (
      dut, rst, ival, iaddr << 2, irdata, 
      dval, dtype, daddr << 2, dwdata, drdata
    )

    if dval & (dtype == 1):
      M[daddr] = dwdata