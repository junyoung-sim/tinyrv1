module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/EqComp.fst");
    $dumpvars(0, EqComp);
end
endmodule
