//========================================================================
// BinaryToSevenSeg_GL
//========================================================================

`ifndef BINARY_TO_SEVEN_SEG_GL_V
`define BINARY_TO_SEVEN_SEG_GL_V

module BinaryToSevenSeg_GL
(
  (* keep=1 *) input  wire [3:0] in,
  (* keep=1 *) output wire [6:0] seg
);

  wire d3, d2, d1, d0;
  assign d3 = in[3];
  assign d2 = in[2];
  assign d1 = in[1];
  assign d0 = in[0];

  assign seg[6] = ~(d3 | d2 | d1) | ~d3 & d2 & d1 & d0;
  assign seg[5] = ~d3 &  d1 & d0  | ~(d3 | d2) & (d1 | d0);
  assign seg[4] = ~d2 & ~d1 & d0  | ~d3 & (d2 & ~d1 | d0);

  assign seg[3] = ~d2 & ~d1 &  d0       |
                  ~d3 &  d2 &  d1 &  d0 |
                  ~d3 &  d2 & ~d1 & ~d0 ;
  assign seg[2] = ~d3 & ~d2 &  d1 & ~d0 ;
  assign seg[1] = ~d3 &  d2 & ~d1 &  d0 |
                  ~d3 &  d2 &  d1 & ~d0 ;
  assign seg[0] = ~d3 &  d2 & ~d1 & ~d0 |
                  ~d3 & ~d2 & ~d1 &  d0 ;

endmodule

`endif /* BINARY_TO_SEVEN_SEG_GL_V */

