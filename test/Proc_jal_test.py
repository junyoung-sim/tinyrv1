from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "jal x0 0x000") # F D X M W
  await asm_write(dut, 0x004, "add x0 x0 x0") #   F - - - -
  #                            jal x0 0x000   #     F D X M W
  #                            add x0 x0 x0   #       F - - - -
  #                                 ...       #          ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)
  await check_trace(dut, 0x004)

@cocotb.test()
async def test_count(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x2 x0 0") # F D X M W
  await asm_write(dut, 0x004, "jal x1 0x00c") #   F D X M W
  await asm_write(dut, 0x008, "addi x2 x2 1") #     F - - - -
  await asm_write(dut, 0x00c, "jr x1"       ) #       F D X M W           (M-D)
  await asm_write(dut, 0x010, "add x0 x0 x0") #         F - - - -
  #                            addi x2 x2 1   #           F D X M W
  #                            jr x1          #             F D X M W
  #                            add x0 x0 x0   #               F - - - -
  #                            addi x2 x2 1   #                 F D X M W (W-D)
  #                                 ...       #                    ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x008)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x002)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x003)
  await check_trace(dut, 0x003)