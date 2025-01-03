from TinyRV1 import *

@cocotb.test()
async def test_simple(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly

  await asm_write(dut, 0x000, "addi x1 x0 0x008") # F D X M W
  await asm_write(dut, 0x004, "addi x2 x0 0x000") #   F D X M W
  await asm_write(dut, 0x008, "addi x2 x2 0x001") #     F D X M W               (X-D)
  await asm_write(dut, 0x00c, "jr x1"           ) #       F D X M W             (W-D)
  await asm_write(dut, 0x010, "add x0 x0 x0"    ) #         F - - - -
  #                            addi x2 x2 1                   F D X M W         (W-D)
  #                            jr x1                            F D X M W
  #                            add x0 x0 x0                       F - - - -
  #                            addi x2 x2 1                         F D X M W   (W-D)
  #                            jr x1                                  F D X M W
  #                            ...

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x008) # addi x1 x0 0x008
  await check_trace(dut, 0x000) # addi x2 x0 0x000
  await check_trace(dut, 0x001) # addi x2 x2 0x001
  await check_trace(dut, 0x001) # jr x1
  await check_trace(dut, 0x001) # add x0 x0 x0
  await check_trace(dut, 0x002) # addi x2 x2 1
  await check_trace(dut, 0x002) # jr x1
  await check_trace(dut, 0x002) # addi x0 x0 x0
  await check_trace(dut, 0x003) # addi x2 x2 1
  await check_trace(dut, 0x003) # jr x1
  await check_trace(dut, 0x003) # addi x0 x0 x0
  await check_trace(dut, 0x004) # addi x2 x2 1
  await check_trace(dut, 0x004) # jr x1
  await check_trace(dut, 0x004) # addi x0 x0 x0