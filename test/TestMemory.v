`ifndef TEST_MEMORY_V
`define TEST_MEMORY_V

`include "../hw/TinyRV1.v"

module TestMemory
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

  // Unused Signals

  logic rst_unused;
  assign rst_unused = rst;

  logic [31:0] imemreq_addr_unused;
  assign imemreq_addr_unused = imemreq_addr;

  logic [31:0] dmemreq_addr_unused;
  assign dmemreq_addr_unused = dmemreq_addr;

  // Memory

  logic [31:0] m [2**14];

  // Write

  always_ff @( posedge clk ) begin
    if ( dmemreq_val && (dmemreq_type == 1) )
      m[dmemreq_addr] <= dmemreq_wdata;
  end

  // Read

  always_comb begin

    if ( imemreq_val )
      imemresp_data = m[imemreq_addr];
    else
      imemresp_data = 'x;

    if ( dmemreq_val && (dmemreq_type == 0) )
      dmemresp_rdata = m[dmemreq_addr];
    else
      dmemresp_rdata = 'x;

  end

  // Test Interface

  TinyRV1 tinyrv1();

  logic [31:0] addr_unused;

  task write( input logic [31:0] addr, input logic [31:0] wdata );
    addr_unused = addr;
    m[addr] = wdata;
  endtask

  function [31:0] read( input logic [31:0] addr );
    addr_unused = addr;
    return m[addr];
  endfunction

  task asm( input logic [31:0] addr, input string str );
    write( addr, tinyrv1.asm( addr, str ) );
  endtask

endmodule

`endif
