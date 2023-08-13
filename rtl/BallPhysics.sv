module BallPhysics (
  input logic rst,
  input logic clk,
  input logic [31:0] dimensions,
  input logic [31:0] ballPosition,    // X- Y value
  input logic [31:0] ballVelocity,
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,
  output logic [1:0] playerDidScore,     // RL
  output logic [31:0] ballPositionOut,
  output logic [31:0] ballVelocityOut
);

  localparam PADDLE_HEIGHT = 16'h0064;
  localparam INITIAL_BALL_VELOCITY = 15;

  logic [31:0] ball_vel_reg = {16'd5, 16'd5};
  logic [31:0] ball_pos_reg;
  logic [1:0] player_score_reg;
  
  logic flagDidScore = 0;
  always_ff @(posedge clk) begin 
    if (rst == 1'b0) begin
      ball_pos_reg[15:0] <= {1'b0, dimensions[15:1]}; 
      ball_pos_reg[31:16] <= {1'b0, dimensions[31:17]}; 

      ball_vel_reg <= {16'd5, 16'd5};
    end
    else begin player_score_reg <= 2'b00;
      ball_pos_reg <= ballPosition;
      flagDidScore <= 1'b0;

      if (((ballPosition[15:0] + 16'h000F) >= dimensions[15:0]) ||  (ballPosition[15:0] <= 16'h000A)) begin
        ball_vel_reg[15:0] <= ~ballVelocity[15:0] + 16'h01;
      end

      if ((ballPosition[31:16] < (leftPaddlePosition[31:16] + 16'h000D))) begin
        if ((ballPosition[15:0] < leftPaddlePosition[15:0] + PADDLE_HEIGHT) && ((ballPosition[15:0] > leftPaddlePosition[15:0]))) begin
          ball_vel_reg[31:16] <= ~ballVelocity[31:16] + 16'h01;
        end else begin
          player_score_reg <= 2'b01;
          flagDidScore <= 1'b1;
        end
      end 

      if (((ballPosition[31:16]+ 16'h000D)  > rightPaddlePosition[31:16])) begin
        if ((ballPosition[15:0] < (rightPaddlePosition[15:0] + PADDLE_HEIGHT)) && (ballPosition[15:0] > rightPaddlePosition[15:0])) begin
        ball_vel_reg[31:16] <= ~ballVelocity[31:16] + 16'h01;
        end else begin
          player_score_reg <= 2'b10;
          flagDidScore <= 1'b1;
        end
      end
    end
  end

  always_comb begin
    ballPositionOut[15:0] = (flagDidScore == 1'b0) ? (ball_vel_reg[15:0] + ball_pos_reg[15:0]) : {1'b0, dimensions[15:1]};
    ballPositionOut[31:16] = (flagDidScore == 1'b0) ? (ball_vel_reg[31:16] + ball_pos_reg[31:16]) : {1'b0, dimensions[31:17]};
  end

  assign playerDidScore = player_score_reg;
  assign ballVelocityOut = ball_vel_reg;
endmodule

