# Five-Stage Pipelined TinyRV1 Processor

This repository demonstrates an example implementation of a five-stage pipelined microarchitecture for TinyRV1 (a limited subset of RISC-V used in ENGRD/ECE 2300 @ Cornell University) shown below:

![Five-Stage Pipelined TinyRV1 Data Path Diagram](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/Five-Stage%20Pipelined%20TinyRV1%20Datapath%20Diagram.png)

## RTL

This five-stage pipelined TinyRV1 processor was implemented and tested incrementally as reflected in the RTL for `ProcDpath` (Data Path) and `ProcCtrl` (Controller) where data path components and control signal tables are laid out by pipeline stage and instruction. Additionally, `ProcCtrl` includes a "Hazard Management" section where all RAW and control flow hazard signals are generated.

Below is a high-level RTL view of the top-level module `Proc` that contains `ProcDpath` and `ProcCtrl`. Further details can be explored in the `$TINYRV1/hw` directory. FPGA synthesis results via Quartus can be found in `$TINYRV1/docs`.

![RTL Viewer (Proc)](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/RTL%20Viewer%20(Proc).png)

## Verification

For the five-stage pipelined TinyRV1 processor, it is critical to test proper bypassing between all stages, memory load latency stalling, and squashing to prevent RAW and control flow hazards. Thus, test cases for each TinyRV1 instruction focus on all bypass paths between all possible pair of instructions; LW stalling for all possible instructions; and critical cases of jumping and branching.

Use the following steps to build and run tests:

```
# Setup TINYRV1 path variable and test script (one-time)
% vim ~/.bashrc
    export TINYRV1=/path/to/tinyrv1
% source ~/.bashrc
% cd $TINYRV1/test
% chmod +x test.sh

# Build tests in $TINYRV1/test
% cd $TINYRV1/test
% make clean                         # Ensures any changes to RTL and test cases are reflected
% make                               # Builds tests for all TinyRV1 instructions
% make Proc_*_test                   # Builds tests for a specific TinyRV1 instruction (*)

# Run tests in $TINYRV1/test
% cd $TINYRV1/test
% ./Proc_*_test                      # Run all test cases for a specific TinyRV1 instruction (*)
% ./Proc_*_test +test-case=?         # Run test case number (?) for a specific TinyRV1 instruction (*)
% ./Proc_*_test +dump-vcd=waves.vcd  # Waveforms saved in waves.vcd (use vscode extension surfer)

# Build and run all tests
% ./test.sh
```

Note that test cases are written in `$TINYRV1/test/Proc_*_test_cases.v` and included in `$TINYRV1/test/Proc_*_test.v`. The former includes pipeline diagrams with labeled bypass paths and dynamic assembly sequences, if applicable and appropriate, through comments to indicate the dependencies and control flows being tested.