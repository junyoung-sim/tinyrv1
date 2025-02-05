## RTL
`./hw` contains Verilog files in development. `./fpga` contains a copy of those files modified for synthesis in Quartus.

## Verification
```
cd test
iverilog -Wall -g2012 -o Proc_xxxx_test Proc_xxxx_test.v
./Proc_xxxx_test.v +test-case= +dump-vcd=waves.vcd
```
Replace `xxxx` with TinyRV1 instruction. All test cases will run unless a particular test case number follows `+test-case=`. Waveforms are dumped by `+dump-vcd=waves.vcd`.

## Documentation
Contains TinyRV1 notes and FPGA synthesis results from Quartus.
