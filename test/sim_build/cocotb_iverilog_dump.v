module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/ProcMem.fst");
    $dumpvars(0, ProcMem);
end
endmodule
