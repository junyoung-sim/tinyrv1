module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Mux4.fst");
    $dumpvars(0, Mux4);
end
endmodule
