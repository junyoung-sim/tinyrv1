//========================================================================
// BinaryToBinCodedDec_GL
//========================================================================

`ifndef BINARY_TO_BIN_CODED_DEC_GL_V
`define BINARY_TO_BIN_CODED_DEC_GL_V

module BinaryToBinCodedDec_GL
(
  (* keep=1 *) input  wire [4:0] in,
  (* keep=1 *) output wire [3:0] tens,
  (* keep=1 *) output wire [3:0] ones
);

  wire d4, d3, d2, d1, d0;
  assign d4 = in[4];
  assign d3 = in[3];
  assign d2 = in[2];
  assign d1 = in[1];
  assign d0 = in[0];

  assign tens[3] = 0;
  assign tens[2] = 0;
  assign tens[1] =  d4 & (d3 | d2);
  assign tens[0] = ~d4 &  d3 & (d2 | d1) | 
                    d4 & ~d3 & ~d2       |
                    d4 &  d3 &  d2 & d1  ;
  
  assign ones[3] = ~d4 &  d3 & ~d2 & ~d1 |
                    d4 & ~d3 & ~d2 &  d1 |
                    d4 &  d3 &  d2 & ~d1 ;
  assign ones[2] = ~d4 & ~d3 &  d2       |
                   ~d4 &  d3 &  d2 &  d1 |
                    d4 & ~d3 & ~d2 & ~d1 |
                    d4 &  d3 & ~d2       ;
  assign ones[1] = ~d4 & ~d3 &  d1       |
                   ~d4 &  d3 &  d2 & ~d1 |
                    d4 & ~d3 & ~d2 & ~d1 |
                    d4 & ~d3 &  d2 &  d1 |
                    d4 &  d3 & ~d2 &  d1 ;
  assign ones[0] = d0;

endmodule

`endif /* BINARY_TO_BIN_CODED_DEC_GL_V */

