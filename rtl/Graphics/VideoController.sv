`include "VGAGraphics.sv"
module VideoController (
  input logic clk,
  input logic rst,
  input logic [31:0] ballPosition,
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,
  output logic en,           //Enable Ping Pong Compute
  output logic hsync,
  output logic vscync,
  output logic [7:0] red,
  output logic [7:0] green,
  output logic [7:0] blue,
  output logic sync,
  output logic blank,
  output logic clkOut
);

  parameter HSYNC_ACTIVE  = 639;
  parameter VSYNC_ACTIVE  = 479;

  logic [9:0] nextX, nextY, currHsync, currVsync;
  logic [23:0] pixel;

  logic [31:0] ballPositionReg = ballPosition,
     leftPaddlePositionReg = leftPaddlePosition, 
     rightPaddlePositionReg = rightPaddlePosition;

  enum logic [1:0] state {INITIAL, SET_REGISTER, DISPLAY} currentState = INITIAL, nextState;

  always_ff @(posedge clk) begin
    nextState <= currentState;
    if (currentState == SET_REGISTER) begin
        leftPaddlePositionReg <= leftPaddleController;
        rightPaddlePositionReg <= rightPaddlePosition;
        ballPositionReg <= ballPosition;
    end
  end

  always_comb begin
    unique case (currentState)
      INITIAL: nextState = SET_REGISTER;
      SET_REGISTER: nextState = DISPLAY;
      DISPLAY: nextState = (currHsync == HSYNC_ACTIVE && currVsync == VSYNC_ACTIVE) ? SET_REGISTER : DISPLAY;
    endcase
  end
  
  PixelGenerationLogic pixelGeneration (
    .leftPaddle(leftPaddlePosition),
    .rightPaddle(rightPaddlePosition),
    .pongBall(ballPosition),
    .nextX(nextX),
    .nextY(nextY),
    .pixelOut(pixel)
  );

  VGADriver graphics (
    .clk(clk),
    .rst(rst),
    .colour_in(pixel),
    .x_pixel(nextX),
    .y_pixel(nextY),
    .hsyncReg(currHsync),
    .vsyncReg(currVsync),
    .hsync(hsync),
    .vsync(vsync),
    .red(read),
    .green(green),
    .blue(blue),
    .sync(sync),
    .blank(blank),
    .clkOut(clkOut)
  );

  assign en = (nextState == SET_REGISTER) ? 1'b1 : 1'b0;
endmodule