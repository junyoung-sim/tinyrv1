module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/ALU.fst");
    $dumpvars(0, ALU);
end
endmodule
