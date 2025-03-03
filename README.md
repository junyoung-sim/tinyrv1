# Five-Stage Pipelined TinyRV1 Processor

This repository demonstrates an example implementation of the five-stage pipelined microarchitecture for TinyRV1 (a limited subset of RISC-V used in ENGRD/ECE 2300 @ Cornell University) shown below:

![Five-Stage Pipelined TinyRV1 Data Path Diagram](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/Five-Stage%20Pipelined%20TinyRV1%20Datapath%20Diagram.png)

## RTL

This five-stage pipelined TinyRV1 processor microarchitecture was implemented incrementally as reflected in the RTL for ProcDpath (Data Path) and ProcCtrl (Control Logic) where data path components and control signal tables are laid out by pipeline stage and instruction. Additionally, ProcCtrl includes a "Hazard Management" section where all RAW (read-after-write) and control flow hazard signals are generated.

Below is a high-level RTL view of the top-level module `Proc` that contains `ProcDpath` and `ProcCtrl`. Further details can be explored in the `$TINYRV1/hw` and `$TINYRV1/docs` directories.

![RTL Viewer (Proc)](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/RTL%20Viewer%20(Proc).png)

## Verification

For the five-stage pipelined TinyRV1 processor, it is critical to test proper bypassing between all stages, memory load latency stalling, and squashing to prevent RAW (read-after-write) and control flow hazards. Thus, test cases for each TinyRV1 instruction focus on verifying all bypass paths between all possible pairs of instructions; LW stalling for all possible instructions; and critical cases of jumping and branching (not-taken speculation).

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

## FPGA Emulation

This five-stage pipelined TinyRV1 processor was synthesized on Altera DE0 FPGA (Intel Cyclone III) and Quartus Prime for physical emulation of an accumulator program in TinyRV1 assembly as shown below.

```
asm( 'h000, "csrw out1, x0"      ); // zero the output
asm( 'h004, "csrr x1, in0"       ); // R[x1] <- size
asm( 'h008, "csrr x2, in2"       ); // R[x2] <- go
asm( 'h00c, "addi x3, x0, 1"     ); // R[x3] <- 1
asm( 'h010, "bne  x2, x3, 0x004" ); // stop wait if go=1
asm( 'h014, "csrw out0, x1"      ); // display size
asm( 'h018, "addi x4, x0, 0"     ); // initialize sum
asm( 'h01c, "addi x5, x0, 0x080" ); // initialize array address
asm( 'h020, "lw x6, 0(x5)"       ); // accumulate loop
asm( 'h024, "add x4, x4, x6"     ); // 
asm( 'h028, "addi x5, x5, 4"     ); //
asm( 'h02c, "addi x1, x1, -1"    ); //
asm( 'h030, "bne x0, x1, 0x020"  ); //
asm( 'h034, "csrw out1, x4"      ); // done (assumes result is in x4)
asm( 'h038, "jal  x0, 0x004"     ); // jump to beginning

// Input array
                   //  size result seven_seg
data( 'h080, 36 ); //     1     36  4
data( 'h084, 26 ); //     2     62 30
data( 'h088, 69 ); //     3    131  3
data( 'h08c, 57 ); //     4    188 28
data( 'h090, 11 ); //     5    199  7
data( 'h094, 68 ); //     6    267 11
data( 'h098, 41 ); //     7    308 20
data( 'h09c, 90 ); //     8    398 14
data( 'h0a0, 32 ); //     9    430 14
data( 'h0a4, 76 ); //    10    506 26
data( 'h0a8, 44 ); //    11    550  6
data( 'h0ac, 19 ); //    12    569 25
data( 'h0b0, 17 ); //    13    586 10
data( 'h0b4, 59 ); //    14    645  5
data( 'h0b8, 99 ); //    15    744  8
data( 'h0bc, 49 ); //    16    793 25
data( 'h0c0, 65 ); //    17    858 26
data( 'h0c4, 12 ); //    18    870  6
data( 'h0c8, 55 ); //    19    925 29
data( 'h0cc,  0 ); //    20    925 29
data( 'h0d0, 51 ); //    21    976 16
data( 'h0d4, 42 ); //    22   1018 26
data( 'h0d8, 82 ); //    23   1100 12
data( 'h0dc, 23 ); //    24   1123  3
data( 'h0e0, 21 ); //    25   1144 24
data( 'h0e4, 54 ); //    26   1198 14
data( 'h0e8, 83 ); //    27   1281  1
data( 'h0ec, 31 ); //    28   1312  0
data( 'h0f0, 16 ); //    29   1328 16
data( 'h0f4, 76 ); //    30   1404 28
data( 'h0f8, 21 ); //    31   1425 17
data( 'h0fc,  4 ); //    32   1429 21
```

The following are synthesis results concerning the microarchitecture’s performance and area usage. Refer to the `$TINYRV1/docs` directory for more.

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

This critical path (14.499 ns) begins at the multiplier’s output port, takes the X-D bypass path, and ends at the input port of the second operand register in stage D. This path is taken when there is an instruction that depends on the result of a preceding `MUL` instruction.

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

## Physical Design Flow

OpenLane Caravel is an open-source digital ASIC tool that hardens RTL into physical designs for manufacturing custom chips using Skywater 130 nm (SKY130 PDK). The following image shows the GDS of this five-stage pipelined TinyRV1 processor after pushing its top-level module `Proc` through the OpenLane flow (600 um x 600 um).

![Proc Physical Design](https://github.com/junyoung-sim/tinyrv1/blob/main/docs/Proc.png)

Below is the critical path report for the physical layout of the five-stage pipelined TinyRV1 processor (17.72 ns). Comparing this report to wires in the synthesized top-level module indicates that the beginning and end of the path is the ALU’s adder output port and the PC input port, respectively. Assuming that the path does not enter the control logic, this path is most likely taken when the X-D bypass path is used between `?` and `JR` where `?` is an instruction that requires addition (`ADD`, `ADDI`, `LW`, `SW`, `JAL`).

```
===========================================================================
report_checks -path_delay max (Setup)
============================================================================
======================= Typical Corner ===================================

Startpoint: _15206_ (rising edge-triggered flip-flop clocked by clk)
Endpoint: _14453_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max

Fanout     Cap    Slew   Delay    Time   Description
-----------------------------------------------------------------------------
                          0.00    0.00   clock clk (rise edge)
                          5.57    5.57   clock source latency
                  0.61    0.00    5.57 ^ clk (in)
     2    0.09                           clk (net)
                  0.62    0.01    5.58 ^ clkbuf_0_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.23    0.42    6.00 ^ clkbuf_0_clk/X (sky130_fd_sc_hd__clkbuf_16)
     8    0.22                           clknet_0_clk (net)
                  0.23    0.01    6.01 ^ clkbuf_2_1_0_clk/A (sky130_fd_sc_hd__clkbuf_8)
                  0.27    0.37    6.38 ^ clkbuf_2_1_0_clk/X (sky130_fd_sc_hd__clkbuf_8)
     8    0.15                           clknet_2_1_0_clk (net)
                  0.27    0.00    6.38 ^ clkbuf_4_4__f_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.28    0.39    6.77 ^ clkbuf_4_4__f_clk/X (sky130_fd_sc_hd__clkbuf_16)
    34    0.27                           clknet_4_4__leaf_clk (net)
                  0.28    0.01    6.78 ^ clkbuf_leaf_19_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.06    0.22    7.00 ^ clkbuf_leaf_19_clk/X (sky130_fd_sc_hd__clkbuf_16)
     8    0.03                           clknet_leaf_19_clk (net)
                  0.06    0.00    7.01 ^ _15206_/CLK (sky130_fd_sc_hd__dfxtp_1)
                  0.37    0.57    7.57 ^ _15206_/Q (sky130_fd_sc_hd__dfxtp_1)
     2    0.04                           dpath.alu.adder.in0[9] (net)
                  0.37    0.00    7.58 ^ fanout615/A (sky130_fd_sc_hd__buf_6)
                  0.33    0.38    7.96 ^ fanout615/X (sky130_fd_sc_hd__buf_6)
    28    0.17                           net615 (net)
                  0.33    0.00    7.96 ^ fanout613/A (sky130_fd_sc_hd__buf_6)
                  0.26    0.33    8.29 ^ fanout613/X (sky130_fd_sc_hd__buf_6)
    32    0.13                           net613 (net)
                  0.26    0.01    8.30 ^ _09170_/C (sky130_fd_sc_hd__nand4_4)
                  0.13    0.17    8.47 v _09170_/Y (sky130_fd_sc_hd__nand4_4)
     3    0.02                           _03372_ (net)
                  0.13    0.00    8.47 v _09172_/B2 (sky130_fd_sc_hd__a22o_1)
                  0.08    0.28    8.75 v _09172_/X (sky130_fd_sc_hd__a22o_1)
     2    0.01                           _03374_ (net)
                  0.08    0.00    8.75 v _09174_/A2 (sky130_fd_sc_hd__a21o_1)
                  0.07    0.23    8.98 v _09174_/X (sky130_fd_sc_hd__a21o_1)
     2    0.01                           _03376_ (net)
                  0.07    0.00    8.98 v _09176_/A2 (sky130_fd_sc_hd__a21o_1)
                  0.07    0.23    9.21 v _09176_/X (sky130_fd_sc_hd__a21o_1)
     3    0.01                           _03378_ (net)
                  0.07    0.00    9.21 v _09177_/C (sky130_fd_sc_hd__and3_1)
                  0.08    0.24    9.45 v _09177_/X (sky130_fd_sc_hd__and3_1)
     2    0.01                           _03379_ (net)
                  0.08    0.00    9.45 v _09180_/B1 (sky130_fd_sc_hd__a211o_2)
                  0.09    0.39    9.85 v _09180_/X (sky130_fd_sc_hd__a211o_2)
     4    0.02                           _03382_ (net)
                  0.09    0.00    9.85 v _09183_/A1 (sky130_fd_sc_hd__a211o_1)
                  0.07    0.32   10.16 v _09183_/X (sky130_fd_sc_hd__a211o_1)
     2    0.01                           _03385_ (net)
                  0.07    0.00   10.16 v _09185_/A2 (sky130_fd_sc_hd__a21o_1)
                  0.05    0.21   10.37 v _09185_/X (sky130_fd_sc_hd__a21o_1)
     2    0.01                           _03387_ (net)
                  0.05    0.00   10.37 v _09186_/C (sky130_fd_sc_hd__and3_1)
                  0.09    0.24   10.62 v _09186_/X (sky130_fd_sc_hd__and3_1)
     4    0.02                           _03388_ (net)
                  0.09    0.00   10.62 v _09189_/A1 (sky130_fd_sc_hd__o211a_1)
                  0.05    0.26   10.87 v _09189_/X (sky130_fd_sc_hd__o211a_1)
     2    0.00                           _03391_ (net)
                  0.05    0.00   10.88 v _09190_/C (sky130_fd_sc_hd__or3_2)
                  0.12    0.50   11.37 v _09190_/X (sky130_fd_sc_hd__or3_2)
     5    0.02                           _03392_ (net)
                  0.12    0.00   11.37 v _09324_/A (sky130_fd_sc_hd__or3_1)
                  0.09    0.45   11.82 v _09324_/X (sky130_fd_sc_hd__or3_1)
     2    0.01                           _03525_ (net)
                  0.09    0.00   11.82 v _09326_/B1 (sky130_fd_sc_hd__o211a_1)
                  0.10    0.21   12.03 v _09326_/X (sky130_fd_sc_hd__o211a_1)
     4    0.02                           _03527_ (net)
                  0.10    0.00   12.03 v _09468_/A2 (sky130_fd_sc_hd__o211a_1)
                  0.10    0.30   12.34 v _09468_/X (sky130_fd_sc_hd__o211a_1)
     5    0.02                           _03668_ (net)
                  0.10    0.00   12.34 v _09471_/B (sky130_fd_sc_hd__or3_1)
                  0.09    0.41   12.75 v _09471_/X (sky130_fd_sc_hd__or3_1)
     2    0.01                           _03671_ (net)
                  0.09    0.00   12.75 v _09473_/B1 (sky130_fd_sc_hd__o211a_1)
                  0.08    0.19   12.94 v _09473_/X (sky130_fd_sc_hd__o211a_1)
     4    0.01                           _03673_ (net)
                  0.08    0.00   12.94 v _09759_/A_N (sky130_fd_sc_hd__and4bb_1)
                  0.06    0.27   13.20 ^ _09759_/X (sky130_fd_sc_hd__and4bb_1)
     1    0.00                           _03957_ (net)
                  0.06    0.00   13.21 ^ _09762_/D_N (sky130_fd_sc_hd__or4b_2)
                  0.15    0.71   13.91 v _09762_/X (sky130_fd_sc_hd__or4b_2)
     3    0.02                           _03960_ (net)
                  0.15    0.00   13.91 v _10264_/A2 (sky130_fd_sc_hd__a211o_1)
                  0.13    0.44   14.35 v _10264_/X (sky130_fd_sc_hd__a211o_1)
     2    0.02                           _04458_ (net)
                  0.13    0.00   14.35 v _10959_/A1 (sky130_fd_sc_hd__a211o_1)
                  0.10    0.37   14.72 v _10959_/X (sky130_fd_sc_hd__a211o_1)
     2    0.02                           _05149_ (net)
                  0.10    0.00   14.72 v _11100_/A1 (sky130_fd_sc_hd__a21oi_4)
                  0.19    0.23   14.94 ^ _11100_/Y (sky130_fd_sc_hd__a21oi_4)
     4    0.02                           _05290_ (net)
                  0.19    0.00   14.94 ^ _11281_/B (sky130_fd_sc_hd__nor2_1)
                  0.06    0.08   15.03 v _11281_/Y (sky130_fd_sc_hd__nor2_1)
     1    0.01                           _05470_ (net)
                  0.06    0.00   15.03 v _11282_/B (sky130_fd_sc_hd__xnor2_1)
                  0.05    0.13   15.16 v _11282_/Y (sky130_fd_sc_hd__xnor2_1)
     1    0.00                           _05471_ (net)
                  0.05    0.00   15.16 v _11283_/A1 (sky130_fd_sc_hd__mux2_1)
                  0.05    0.30   15.46 v _11283_/X (sky130_fd_sc_hd__mux2_1)
     1    0.00                           _05472_ (net)
                  0.05    0.00   15.46 v _11287_/A0 (sky130_fd_sc_hd__mux2_2)
                  0.17    0.42   15.88 v _11287_/X (sky130_fd_sc_hd__mux2_2)
     4    0.06                           _05476_ (net)
                  0.17    0.00   15.88 v hold2780/A (sky130_fd_sc_hd__clkbuf_2)
                  0.10    0.23   16.11 v hold2780/X (sky130_fd_sc_hd__clkbuf_2)
     2    0.03                           net3675 (net)
                  0.10    0.00   16.11 v _11288_/A2 (sky130_fd_sc_hd__a21oi_4)
                  0.71    0.63   16.74 ^ _11288_/Y (sky130_fd_sc_hd__a21oi_4)
     6    0.10                           _05477_ (net)
                  0.71    0.01   16.75 ^ _11289_/B (sky130_fd_sc_hd__nor2_1)
                  0.13    0.13   16.88 v _11289_/Y (sky130_fd_sc_hd__nor2_1)
     1    0.01                           _05478_ (net)
                  0.13    0.00   16.88 v _11300_/B1 (sky130_fd_sc_hd__o221a_1)
                  0.04    0.26   17.15 v _11300_/X (sky130_fd_sc_hd__o221a_1)
     1    0.00                           _00665_ (net)
                  0.04    0.00   17.15 v hold2597/A (sky130_fd_sc_hd__dlygate4sd3_1)
                  0.05    0.57   17.72 v hold2597/X (sky130_fd_sc_hd__dlygate4sd3_1)
     1    0.00                           net3492 (net)
                  0.05    0.00   17.72 v _14453_/D (sky130_fd_sc_hd__dfxtp_2)
                                 17.72   data arrival time

                         25.00   25.00   clock clk (rise edge)
                          4.65   29.65   clock source latency
                  0.61    0.00   29.65 ^ clk (in)
     2    0.09                           clk (net)
                  0.62    0.01   29.66 ^ clkbuf_0_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.23    0.38   30.04 ^ clkbuf_0_clk/X (sky130_fd_sc_hd__clkbuf_16)
     8    0.22                           clknet_0_clk (net)
                  0.23    0.01   30.05 ^ clkbuf_2_1_0_clk/A (sky130_fd_sc_hd__clkbuf_8)
                  0.27    0.33   30.38 ^ clkbuf_2_1_0_clk/X (sky130_fd_sc_hd__clkbuf_8)
     8    0.15                           clknet_2_1_0_clk (net)
                  0.27    0.00   30.39 ^ clkbuf_4_4__f_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.28    0.35   30.73 ^ clkbuf_4_4__f_clk/X (sky130_fd_sc_hd__clkbuf_16)
    34    0.27                           clknet_4_4__leaf_clk (net)
                  0.28    0.01   30.74 ^ clkbuf_leaf_16_clk/A (sky130_fd_sc_hd__clkbuf_16)
                  0.05    0.20   30.94 ^ clkbuf_leaf_16_clk/X (sky130_fd_sc_hd__clkbuf_16)
     9    0.03                           clknet_leaf_16_clk (net)
                  0.05    0.00   30.94 ^ _14453_/CLK (sky130_fd_sc_hd__dfxtp_2)
                         -0.25   30.69   clock uncertainty
                          1.03   31.73   clock reconvergence pessimism
                         -0.11   31.61   library setup time
                                 31.61   data required time
-----------------------------------------------------------------------------
                                 31.61   data required time
                                -17.72   data arrival time
-----------------------------------------------------------------------------
                                 13.90   slack (MET)
```

## Acknowledgements

I appreciate Professor Christoper Batten and student members of Cornell Custom Silicon Systems for their instruction and feedback that made this project possible.