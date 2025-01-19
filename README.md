## RTL
`./hw` contains Verilog hardware files in development. `./fpga` contains a copy of those files modified for synthesis in Quartus.

## Testing (Cocotb)
### Processor
```
cd test
chmod +x Proc_xxxx_test.py (replace xxxx with TinyRV1 instruction)
make clean_all (makes sure RTL changes are applied)
./Proc_xxxx_test.py N (replace N with an integer for specific test cases)
```
Similarly, run the same commands for mixed instruction tests and kernels in `test_prog.py`.
### Building Blocks
```
cd test
make TOPLEVEL=xxxx MODULE=xxxx_test TESTCASE=???? (replace xxxx with hardware name and ???? with test case name)
```

## Documentation
Contains TinyRV1 notes and FPGA synthesis results from Quartus.
