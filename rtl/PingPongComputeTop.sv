module PingPongComputeTop (
  input logic clk,
  input logic en,
  input logic rst,
  input logic rightPaddleController, // RdData from DPRAM
  output logic addr,
  output logic [31:0] ballPosition,
  output logic [31:0] leftPaddlePosition,
  output logic [31:0] rightPaddlePosition
);

  parameter logic [31:0] DEFAULT_BALL_POSITION = {};
  parameter logic [31:0] DEFAULT_LEFT_PADDLE_POSITION = {};
  parameter logic [31:0] DEFAULT_RIGHT_PADDLE_POSITION = {};
  parameter logic [31:0] DEFAULT_BALL_VELOCITY = {};
  parameter logic [31:0] PING_PONG_DIMENSIONS = {16'h0005, 16'h0005};

  parameter BASE_ADDRESS = 0;

  logic [31:0] ballPositionIn = DEFAULT_BALL_POSITION, ballPositionOut,
              leftPaddlePositionIn = DEFAULT_LEFT_PADDLE_POSITION, leftPaddlePositionOut,
              rightPaddlePositionIn = DEFAULT_RIGHT_PADDLE_POSITION, rightPaddlePositionOut,
              ballVelocityIn = DEFAULT_BALL_VELOCITY, ballVelocityOut;

  logic [15:0] scoreOut;

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      ballPositionIn <= DEFAULT_BALL_POSITION;
      leftPaddlePositionIn <= DEFAULT_LEFT_PADDLE_POSITION;
      rightPaddlePositionIn <= DEFAULT_RIGHT_PADDLE_POSITION;
    end else begin
      if (en == 1'b1) begin
        ballVelocityIn <= ballPositionOut;
        ballPositionIn <= ballPositionOut;
        leftPaddlePositionIn <= leftPaddlePositionOut;
      end
    end
  end

  PingPong pongCompute (
    .rst(rst),
    .clk(clk),
    .dimensions(PING_PONG_DIMENSIONS),
    .ballPosition(ballPositionIn),
    .ballVelocity(ballVelocityIn),
    .leftPaddlePosition(leftPaddlePositionIn),
    .rightPaddlePosition(rightPaddlePositionIn),

    .scoreOut(scoreOut),
    .leftPaddlePositionOut(leftPaddlePositionOut),
    .rightPaddlePositionOut(rightPaddlePositionOut),
    .ballPositionOut(ballPositionOut),
    .ballVelocityOut(ballPositionOut)
  );

  assign addr = BASE_ADDRESS;
  assign ballPosition = ballPositionOut;
  assign leftPaddlePosition = leftPaddlePositionOut;
  assign rightPaddlePosition = rightPaddlePositionOut;
endmodule