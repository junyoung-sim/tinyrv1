module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Regfile.fst");
    $dumpvars(0, Regfile);
end
endmodule
