module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Register_RTL.fst");
    $dumpvars(0, Register_RTL);
end
endmodule
