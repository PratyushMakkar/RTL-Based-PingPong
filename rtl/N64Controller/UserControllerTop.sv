`include "N64Controller.sv"
module UserControllerTop (
  input clk,
  input rst,
  inout logic dataController,
  output logic [31:0] leftPaddleController
);

  parameter logic signed [15:0] PADDLE_HEIGHT = 16'h0064;
  parameter logic signed [15:0] SCREEN_HEIGHT = 480;
  parameter logic signed [15:0] PADDLE_INCREMENT  = 16'h0005;
  parameter logic signed [31:0] DEFAULT_PADDLE_POSITION = {16'h000F, $signed(240 - (PADDLE_HEIGHT >> 1))}; 
  
  logic [31:0] leftPaddleControllerReg;
  logic setGnt;

  /* ------------------------ N64 gaming controller interface signals ----------- */
  logic [33:0] commandReg;
  logic readValid, start;

  assign start = 1'b1;

  typedef enum {IDLE, CONTROLLER_SET} user_controller_state_t;
  user_controller_state_t currentState = IDLE, nextState;

  function logic [15:0] setPaddleHeight(logic [33:0] command);
    logic signed [15:0] paddleHeight = leftPaddleControllerReg[15:0];
    if (set[5] == 1'b1) begin
      if (paddleHeight >= PADDLE_INCREMENT) begin
        paddleHeight = paddleHeight - PADDLE_INCREMENT;
      end
    end else if (set[4] == 1'b1) begin
      if (paddleHeight <= (SCREEN_HEIGHT - PADDLE_HEIGHT)) begin
        paddleHeight = paddleHeight + PADDLE_INCREMENT;
      end
    end 
    return paddleHeight;
  endfunction

  N64Controller controller (
    .clk(clk),
    .start(start),
    .data(commandReg),
    .readValid(readValid),
    .dataController(dataController)   
  );

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      leftPaddleControllerReg <= DEFAULT_PADDLE_POSITION;
    end else begin
      if (setGnt == 1'b1) begin
        leftPaddleControllerReg[15:0] <= setPaddleHeight(commandReg);
      end
    end
  end

  always_comb begin
    nextState = (readValid == 1'b1) ? CONTROLLER_SET : IDLE;
    setGnt = (currentState == IDLE ? readValid : 1'b0);
  end

  assign leftPaddleController = {DEFAULT_PADDLE_POSITION[31:16], leftPaddleControllerReg[15:0]};
endmodule