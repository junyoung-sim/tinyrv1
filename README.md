# Five-Stage Pipelined TinyRV1 Processor

This repository demonstrates an example implementation of the five-stage pipelined microarchitecture for TinyRV1 (a limited subset of RISC-V used in ENGRD/ECE 2300 @ Cornell University) shown below:

![Five-Stage Pipelined TinyRV1 Data Path Diagram](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/Five-Stage%20Pipelined%20TinyRV1%20Datapath%20Diagram.png)

## RTL

This five-stage pipelined TinyRV1 processor was implemented and tested incrementally as reflected in the RTL for `ProcDpath` (Data Path) and `ProcCtrl` (Controller) where data path components and control signal tables are laid out by pipeline stage and instruction. Additionally, `ProcCtrl` includes a "Hazard Management" section where all RAW and control flow hazard signals are generated.

Below is a high-level RTL view of the top-level module `Proc` that contains `ProcDpath` and `ProcCtrl`. Further details can be explored in the `$TINYRV1/hw` and `$TINYRV1/docs` directories.

![RTL Viewer (Proc)](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/RTL%20Viewer%20(Proc).png)

## Verification

For the five-stage pipelined TinyRV1 processor, it is critical to test proper bypassing between all stages, memory load latency stalling, and squashing to prevent RAW and control flow hazards. Thus, test cases for each TinyRV1 instruction focus on all bypass paths between all possible pair of instructions; LW stalling for all possible instructions; and critical cases of jumping and branching (not-taken speculation).

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

Note that test cases are written in `$TINYRV1/test/Proc_*_test_cases.v` and included in `$TINYRV1/test/Proc_*_test.v`. The former includes pipeline diagrams with labeled bypass paths and dynamic assembly sequences, if applicable and appropriate, through comments to indicate the data dependencies and control flows being tested.

## FPGA Synthesis

The following are FPGA synthesis results for the five-stage pipelined TinyRV1 processor. Refer to the `$TINYRV1/docs` directory for more.

**Timing Analysis (Setup)**
```
+------------------------------------------------------------------------------------------------------------------+
; Data Arrival Path                                                                                                ;
+----------+---------+----+------+--------+----------------------+-------------------------------------------------+
; Total    ; Incr    ; RF ; Type ; Fanout ; Location             ; Element                                         ;
+----------+---------+----+------+--------+----------------------+-------------------------------------------------+
; 0.000    ; 0.000   ;    ;      ;        ;                      ; launch edge time                                ;
; 3.656    ; 3.656   ;    ;      ;        ;                      ; clock path                                      ;
;   0.000  ;   0.000 ;    ;      ;        ;                      ; source latency                                  ;
;   0.000  ;   0.000 ;    ;      ; 1      ; PIN_M9               ; CLOCK_50                                        ;
;   0.000  ;   0.000 ; RR ; IC   ; 1      ; IOIBUF_X22_Y0_N1     ; CLOCK_50~input|i                                ;
;   0.746  ;   0.746 ; RR ; CELL ; 1      ; IOIBUF_X22_Y0_N1     ; CLOCK_50~input|o                                ;
;   1.056  ;   0.310 ; RR ; IC   ; 1      ; CLKCTRL_G4           ; CLOCK_50~inputCLKENA0|inclk                     ;
;   1.373  ;   0.317 ; RR ; CELL ; 3730   ; CLKCTRL_G4           ; CLOCK_50~inputCLKENA0|outclk                    ;
;   3.104  ;   1.731 ; RR ; IC   ; 1      ; FF_X34_Y5_N38        ; proc|dpath|op1_DX|q[28]|clk                     ;
;   3.656  ;   0.552 ; RR ; CELL ; 1      ; FF_X34_Y5_N38        ; Proc:proc|ProcDpath:dpath|Register:op1_DX|q[28] ;
; 14.499   ; 10.843  ;    ;      ;        ;                      ; data path                                       ;
;   3.656  ;   0.000 ;    ; uTco ; 1      ; FF_X34_Y5_N38        ; Proc:proc|ProcDpath:dpath|Register:op1_DX|q[28] ;
;   3.656  ;   0.000 ; FF ; CELL ; 3      ; FF_X34_Y5_N38        ; proc|dpath|op1_DX|q[28]|q                       ;
;   5.099  ;   1.443 ; FF ; IC   ; 14     ; DSP_X33_Y9_N0        ; proc|dpath|mul|Mult0~387|ax[10]                 ;
;   8.874  ;   3.775 ; FF ; CELL ; 1      ; DSP_X33_Y9_N0        ; proc|dpath|mul|Mult0~387|resulta[3]             ;
;   9.959  ;   1.085 ; FF ; IC   ; 2      ; MLABCELL_X34_Y9_N9   ; proc|dpath|mul|Mult0~356|datac                  ;
;   10.848 ;   0.889 ; FF ; CELL ; 1      ; MLABCELL_X34_Y9_N9   ; proc|dpath|mul|Mult0~356|cout                   ;
;   10.848 ;   0.000 ; FF ; IC   ; 2      ; MLABCELL_X34_Y9_N12  ; proc|dpath|mul|Mult0~360|cin                    ;
;   10.894 ;   0.046 ; FF ; CELL ; 1      ; MLABCELL_X34_Y9_N12  ; proc|dpath|mul|Mult0~360|cout                   ;
;   10.894 ;   0.000 ; FF ; IC   ; 2      ; MLABCELL_X34_Y9_N15  ; proc|dpath|mul|Mult0~364|cin                    ;
;   10.894 ;   0.000 ; FF ; CELL ; 1      ; MLABCELL_X34_Y9_N15  ; proc|dpath|mul|Mult0~364|cout                   ;
;   10.894 ;   0.000 ; FF ; IC   ; 2      ; MLABCELL_X34_Y9_N18  ; proc|dpath|mul|Mult0~344|cin                    ;
;   11.255 ;   0.361 ; FF ; CELL ; 3      ; MLABCELL_X34_Y9_N18  ; proc|dpath|mul|Mult0~344|sumout                 ;
;   12.191 ;   0.936 ; FF ; IC   ; 1      ; MLABCELL_X34_Y12_N30 ; proc|dpath|op2_bypass_mux|Mux7~9|dataf          ;
;   12.273 ;   0.082 ; FF ; CELL ; 1      ; MLABCELL_X34_Y12_N30 ; proc|dpath|op2_bypass_mux|Mux7~9|combout        ;
;   12.488 ;   0.215 ; FF ; IC   ; 1      ; MLABCELL_X34_Y12_N54 ; proc|dpath|op2_bypass_mux|Mux7~10|datad         ;
;   13.002 ;   0.514 ; FF ; CELL ; 2      ; MLABCELL_X34_Y12_N54 ; proc|dpath|op2_bypass_mux|Mux7~10|combout       ;
;   13.903 ;   0.901 ; FF ; IC   ; 1      ; FF_X37_Y9_N22        ; proc|dpath|op2_DX|q[24]|asdata                  ;
;   14.499 ;   0.596 ; FF ; CELL ; 1      ; FF_X37_Y9_N22        ; Proc:proc|ProcDpath:dpath|Register:op2_DX|q[24] ;
+----------+---------+----+------+--------+----------------------+-------------------------------------------------+
```

**Resources**
```
Combinational ALUT usage for logic	3,347	
-- 7 input functions	17	
-- 6 input functions	2,579	
-- 5 input functions	237	
-- 4 input functions	165	
-- <=3 input functions	349	
Combinational ALUT usage for route-throughs	809	
 	 	
Dedicated logic registers	3,728	
-- By type:	 	
-- Primary logic registers	3,486 / 36,960	9 %
-- Secondary logic registers	242 / 36,960	< 1 %
-- By function:	 	
-- Design implementation registers	3,514	
-- Routing optimization registers	214	
```
