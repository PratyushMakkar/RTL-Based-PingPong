`include "VGAGraphics.sv"
module VideoController (
  input logic clk,
  input logic rst,
  input logic [31:0] ballPosition,
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,
  output logic hsync,
  output logic vscync,
  output logic [7:0] red,
  output logic [7:0] green,
  output logic [7:0] blue,
  output logic sync,
  output logic blank,
  output logic clkOut
);

  PixelGenerationLogic pixelGeneration (

  );

  VGADriver graphics (

  );


endmodule