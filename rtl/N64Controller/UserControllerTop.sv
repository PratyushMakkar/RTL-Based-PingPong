`include "N64Controller.sv"
module UserControllerTop (
  input clk,
  input rst,
  inout logic dataController,
  output logic [31:0] leftPaddleController,
  output logic wrEnable,
  output logic [31:0] wrData,
  output logic [15:0] wrAddr
);

  parameter logic signed [15:0] PADDLE_HEIGHT = 16'h0064;
  parameter logic signed [15:0] SCREEN_HEIGHT = 480;
  parameter logic signed [15:0] PADDLE_INCREMENT  = 16'h0005;
  parameter logic signed [31:0] DEFAULT_PADDLE_POSITION = {16'h000F, $signed(240 - (PADDLE_HEIGHT >> 1))}; 

  parameter BASE_ADDRESS = 0;
  parameter MAX_CONTROLLER_SET_CNT = 10;
  parameter MAX_DPRAM_WRITE_CNT = 5;

  logic [31:0] leftPaddleControllerReg;
  logic setGnt;
  logic cnt = 0;
  /* ------------------------ N64 gaming controller interface signals ----------- */
  logic [33:0] command, commandReg;    // Command reg is the latch for the command after each retrieve cycle in N64.
  logic readValid, start;

  assign start = 1'b1;
  typedef enum {IDLE, CONTROLLER_SET, WRITE_CONTROLLER} user_controller_state_t;
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
    .data(command),
    .readValid(readValid),
    .dataController(dataController)   
  );

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      leftPaddleControllerReg <= DEFAULT_PADDLE_POSITION;
      currentState <= IDLE;
    end else begin
      currentState <= nextState;
      if (setGnt == 1'b1) begin
         commandReg <= command;
        leftPaddleControllerReg[15:0] <= setPaddleHeight(command);
      end
    end
  end

  always_ff @(posedge clk) begin : CNT_LOGIC
    if (currentState != IDLE) begin
      if (cnt == MAX_CONTROLLER_SET_CNT) cnt <= 0;
      else if (cnt == MAX_DPRAM_WRITE_CNT) cnt <= 0;
      else cnt <= cnt + 1'b1;
    end else cnt <= 0;
  end

  always_comb begin : NEXT_STATE_LOGIC
    unique case (currentState) 
      IDLE: begin
        nextState = (readValid == 1'b1) ? CONTROLLER_SET : IDLE;
        setGnt = readValid;
      end
      CONTROLLER_SET: begin
        nextState = (cnt == MAX_CONTROLLER_SET_CNT) ? WRITE_CONTROLLER ? CONTROLLER_SET;
        setGnt = 1'b0;
      end
      WRITE_CONTROLLER: begin
        nextState = (cnt == MAX_DPRAM_WRITE_CNT) ? IDLE : WRITE_CONTROLLER;
        setGnt = 1'b0;
      end
    endcase
  end

  always_comb begin : NEXT_STATE_LOGIC
    wrData = leftPaddleController;
    wrEnable = (currentState == WRITE_CONTROLLER) ? 1'b1 : 1'b0;
    wrAddr = BASE_ADDRESS;
  end

  assign leftPaddleController = {DEFAULT_PADDLE_POSITION[31:16], leftPaddleControllerReg[15:0]};
endmodule