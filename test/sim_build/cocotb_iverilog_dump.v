module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Mux2.fst");
    $dumpvars(0, Mux2);
end
endmodule
