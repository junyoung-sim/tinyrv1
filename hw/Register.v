`ifndef REGISTER_V
`define REGISTER_V

module Register
#(
  parameter nbits=32
)(
  input  logic             clk,
  input  logic             rst,
  input  logic             en,
  input  logic [nbits-1:0] d,
  output logic [nbits-1:0] q
);

  always_ff @(posedge clk) begin
    if(rst)
      q <= {nbits{1'b0}};
    else
      q <= (en ? d : q);
  end

endmodule

`endif
