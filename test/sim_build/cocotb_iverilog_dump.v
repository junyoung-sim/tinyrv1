module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Register.fst");
    $dumpvars(0, Register);
end
endmodule
