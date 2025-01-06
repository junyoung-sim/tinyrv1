from TinyRV1 import *

@cocotb.test()
async def test_forward_not_taken(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 0"   ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x018") #   F D X M W          (X-D)
  await asm_write(dut, 0x008, "addi x2 x0 0"   ) #     F D X M W
  await asm_write(dut, 0x00c, "add x0 x0 x0"   ) #       F D X M W
  await asm_write(dut, 0x010, "add x0 x0 x0"   ) #         F D X M W
  await asm_write(dut, 0x014, "jal x0 0x014"   ) #           F D X M W
  await asm_write(dut, 0x018, "addi x2 x0 1"   ) #             F - - - -
  await asm_write(dut, 0x01c, "add x0 x0 x0"   )
  await asm_write(dut, 0x020, "add x0 x0 x0"   )
  await asm_write(dut, 0x024, "jal x0 0x024"   )
  await asm_write(dut, 0x028, "add x0 x0 x0"   )

  await reset(dut)

  # Check Traces
  
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)
  await check_trace(dut, 0x018)

@cocotb.test()
async def test_forward_taken(dut):
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start(start_high=False))

  # Assembly Program

  await asm_write(dut, 0x000, "addi x1 x0 1"   ) # F D X M W
  await asm_write(dut, 0x004, "bne x0 x1 0x018") #   F D X M W         (X-D)
  await asm_write(dut, 0x008, "addi x2 x0 0"   ) #     F D - - -
  await asm_write(dut, 0x00c, "add x0 x0 x0"   ) #       F - - - -
  await asm_write(dut, 0x010, "add x0 x0 x0"   )
  await asm_write(dut, 0x014, "jal x0 0x014"   )
  await asm_write(dut, 0x018, "addi x2 x0 1"   ) #         F D X M W
  await asm_write(dut, 0x01c, "add x0 x0 x0"   ) #           F D X M W
  await asm_write(dut, 0x020, "add x0 x0 x0"   ) #             F D X M W
  await asm_write(dut, 0x024, "jal x0 0x024"   ) #               F D X M W
  await asm_write(dut, 0x028, "add x0 x0 x0"   ) #                 F - - - -

  await reset(dut)

  # Check Traces

  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, x)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x001)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x000)
  await check_trace(dut, 0x028)
  await check_trace(dut, 0x028)
  await check_trace(dut, 0x028)
  await check_trace(dut, 0x028)
  await check_trace(dut, 0x028)