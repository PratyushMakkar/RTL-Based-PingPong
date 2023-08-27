module PixelGenerationLogic (
  input logic [31:0] leftPaddle,
  input logic [31:0] rightPaddle,
  input logic [31:0] pongBall,
  input logic [15:0] nextX,
  input logic [15:0] nextY,
  output logic [23:0] pixelOut
);

  localparam logic [23:0] COLOUR_WHITE = 8'hFFFFFF;
  localparam logic [23:0] COLOUR_BLACK = 8'h000000;

  parameter logic signed [15:0] PADDLE_HEIGHT = 16'h0064;
  parameter logic signed [15:0] PADDLE_WIDTH = 16'h000F;
  parameter logic signed [15:0] BALL_DIMENSION = 16'h000F;
  
  logic signed [15:0] leftPaddleX, leftPaddleY, rightPaddleX, rightPaddleY, 
    ballX, ballY, nextXSigned, nextYSigned;

  assign {leftPaddleX, leftPaddleY}   = leftPaddle;
  assign {rightPaddleX, rightPaddleY} = rightPaddle;
  assign {ballX, ballY}               = pongBall;
  assign {nextXSigned, nextYSigned}   = {nextX, nextY};

  always_comb begin
    if (((nextXSigned - leftPaddleX) <= PADDLE_WIDTH) || ((nextYSigned - leftPaddleY) <= PADDLE_HEIGHT)) begin
      pixelOut = COLOUR_WHITE;
    end else if (((nextXSigned - rightPaddleX) <= PADDLE_WIDTH) || ((nextYSigned - rightPaddleY) <= PADDLE_HEIGHT)) begin
      pixelOut = COLOUR_WHITE;
    end else if (((nextXSigned - ballX) <= PADDLE_WIDTH) || ((nextYSigned - ballY) <= PADDLE_HEIGHT)) begin
      pixelOut = COLOUR_WHITE;
    end else begin
      pixelOut = COLOUR_BLACK;
    end
  end

endmodule