//========================================================================
// Display_GL
//========================================================================

`ifndef DISPLAY_GL_V
`define DISPLAY_GL_V

`include "BinaryToBinCodedDec_GL.v"
`include "BinaryToSevenSeg_GL.v"

module Display_GL
(
  (* keep=1 *) input  wire [4:0] in,
  (* keep=1 *) output wire [6:0] seg_tens,
  (* keep=1 *) output wire [6:0] seg_ones
);

  wire [3:0] tens;
  wire [3:0] ones;

  BinaryToBinCodedDec_GL BCD
  (
    .in(in),
    .tens(tens),
    .ones(ones)
  );

  BinaryToSevenSeg_GL SEG_TENS
  (
    .in(tens),
    .seg(seg_tens)
  );

  BinaryToSevenSeg_GL SEG_ONES
  (
    .in(ones),
    .seg(seg_ones)
  );

endmodule

`endif /* DISPLAY_GL_V */

