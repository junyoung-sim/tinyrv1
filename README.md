## RTL



## Verification

For the five-stage pipelined TinyRV1 processor, it is critical to test proper bypassing between all stages, memory load latency stalling, and squashing to prevent RAW (read-after-write) and control flow hazards. Thus, test cases for each TinyRV1 instruction focus on bypass paths between all possible pair of instructions; LW stalling for all possible instructions; and critical cases of jumping and branching.

Use the following steps to build and run tests:

```
# Add TINYRV1 path variable to ~/.bashrc (first step; one-time)
% vim ~/.bashrc
    export TINYRV1=/path/to/tinyrv1
% source ~/.bashrc

# Build tests in $TINYRV1/test
% cd $TINYRV1/test
% make clean                         # Ensures any changes to RTL and test cases are reflected
% make                               # Builds tests for all TinyRV1 instructions
% make Proc_*_test                   # Builds tests for a specific TinyRV1 instruction (*)

# Run tests in $TINYRV1/test
% cd $TINYRV1/test
% ./Proc_*_test
% ./Proc_*_test +test-case=?         # Run test case number (?) for a specific TinyRV1 instruction (*)
% ./Proc_*_test +dump-vcd=waves.vcd  # Waveforms saved in waves.vcd (use vscode extension surfer)

# Build and run all tests
% cd $TINYRV1/test
% chmod +x test.sh                   # one-time
% ./test.sh
```

Note that test cases are written in `$TINYRV1/test/Proc_*_test_cases.v` and included in `$TINYRV1/test/Proc_*_test.v`. The former includes pipeline diagrams with labeled bypass paths and dynamic assembly sequences, if applicable, through comments to indicate the dependencies and control flows being tested.