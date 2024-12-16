`ifndef REGISTER_V
`define REGISTER_V

module Register
#(
  parameter nbits=32
)(
  (* keep=1 *) input  logic             clk,
  (* keep=1 *) input  logic             rst,
  (* keep=1 *) input  logic             en,
  (* keep=1 *) input  logic [nbits-1:0] d,
  (* keep=1 *) output logic [nbits-1:0] q
);

  always_ff @(posedge clk) begin
    if(rst)
      q <= {nbits{1'b0}};
    else
      q <= (en ? d : q);
  end

endmodule

`endif