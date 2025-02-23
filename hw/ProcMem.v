`ifndef PROCMEM_V
`define PROCMEM_V

module ProcMem
(
  input  logic        clk,
  input  logic        rst,

  input  logic        imemreq_val,
  input  logic [31:0] imemreq_addr,
  output logic [31:0] imemresp_data,

  input  logic        dmemreq_val,
  input  logic        dmemreq_type,
  input  logic [31:0] dmemreq_addr,
  input  logic [31:0] dmemreq_wdata,
  output logic [31:0] dmemresp_rdata
);

  localparam memsize = 2**6;

  logic [31:0] mem [memsize];

  // Unused

  logic [31:0] imemreq_addr_unused;
  assign imemreq_addr_unused = imemreq_addr;

  logic [31:0] dmemreq_addr_unused;
  assign dmemreq_addr_unused = dmemreq_addr;

  // Write

  always_ff @(posedge clk) begin
    if(rst) begin
      //
      // write default instruction and data memory
      //
    end
    else if(dmemreq_val && (dmemreq_type == 1)) begin
      mem[dmemreq_addr[$clog2(memsize)+1:2]] <= dmemreq_wdata;
    end
  end

  // Read

  always_comb begin
    if(imemreq_val)
      imemresp_data = mem[imemreq_addr[$clog2(memsize)+1:2]];
    else
      imemresp_data = 32'bx;
    if(dmemreq_val && (dmemreq_type == 0))
      dmemresp_rdata = mem[dmemreq_addr[$clog2(memsize)+1:2]];
    else
      dmemresp_rdata = 32'bx;
  end

endmodule

`endif
