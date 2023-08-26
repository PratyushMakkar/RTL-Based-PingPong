module PixelGenerationLogic (
  input logic [31:0] leftPaddle,
  input logic [31:0] rightPaddle,
  input logic [31:0] pongBall,
  input logic [15:0] nextX,
  input logic [15:0] nextY,
  output logic [7:0] pixelOut
);

  localparam logic [7:0] COLOUR_WHITE = 8'hFF;
  localparam logic [7:0] COLOUR_BLACK = 8'hFF;

  parameter signed logic [15:0] PADDLE_HEIGHT = 16'h0064;
  parameter signed logic [15:0] PADDLE_WIDTH = 16'h000F;
  parameter signed logic [15:0] BALL_DIMENSION = 16'h000F;
  
  signed logic [15:0] leftPaddleX, leftPaddleY, rightPaddleX, rightPaddleY, 
    ballX, ballY, nextXSigned, nextYSigned;

  assign {leftPaddleX, leftPaddleY}   = leftPaddle;
  assign {rightPaddleX, rightPaddleY} = rightPaddle;
  assign {ballX, ballY}               = pongBall
  assign {nextXSigned, nextXSigned}   = {nextX, nextY};

  always_comb begin
    if (((nextXSigned - leftPaddleX) <= PADDLE_WIDTH) || ((nextXSigned - leftPaddleY) <= PADDLE_HEIGHT)) pixelOut <= COLOUR_WHITE;
    else if (((nextXSigned - rightPaddleX) <= PADDLE_WIDTH) || ((nextXSigned - rightPaddleY) <= PADDLE_HEIGHT)) pixelOut <= COLOUR_WHITE;
    else if (((nextXSigned - ballX) <= PADDLE_WIDTH) || ((nextXSigned - ballY) <= PADDLE_HEIGHT)) pixelOut <= COLOUR_WHITE;
    else pixelOut <= COLOUR_BLACK;
  end

endmodule