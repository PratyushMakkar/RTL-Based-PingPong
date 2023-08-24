module N64Controller (
  input logic clk,
  input logic start,
  output logic [33:0] data,
  output logic readValid,
  inout logic dataController      // Singal for the N64 controller
);

  localparam ONE_US = 9;
  localparam THREE_US = 29;
  localparam HALF_CLOCK_COUNT = 19;
  localparam FULL_CYCLE = 39;
  localparam MAX_FINISH_COUNT = 10;
  localparam logic [8:0] POLL_COMMAND = 9'b110000000;

  //--------------------------- Transmt Data Command Interface Signals ----------//
  logic [3:0] pollReg = 0;
  logic [31:0] dataCounter = 0;
  logic resetCounter = 0;

  //--------------------------- Recieve Data Interface Signals -----------------//
  logic [33:0] dataBuffer = 0;
  logic [31:0] recieveCounter = 0;
  logic [6:0] recievePointer = 0;
  logic [6:0] zeroCounter = 0;
  logic didFinishRecieve = 0;

  //--------------------------- Finish Interface Signals -----------------//
  logic [5:0] finishCounter = 0;

  //--------------------------- Helper Signals -----------------//
  logic outputEnable, transmitDataRegister = 0;
  logic dataInputReg;
  
  assign dataInputReg = (outputEnable == 1'b0) ? dataController : 1'b0;

  typedef enum logic [3:0] {IDLE, FINISH, RECIEVE, TRANSMIT_COMMAND, SEND0_ONE, SEND0_TWO, SEND1_ONE, SEND1_TWO} n64_state_t; 
  
  n64_state_t currentState = IDLE;
  n64_state_t nextState;
  
  always_ff @(posedge clk) begin
    currentState <= nextState;
  end

  always_ff @(posedge clk) begin : POLL_REG_INTERFACE
    if (nextState == TRANSMIT_COMMAND && (currentState != IDLE)) begin
      pollReg  <= pollReg + 1'b1;
    end else if (nextState == RECIEVE) begin
      pollReg <= 0;
    end
  end

  always_ff @(posedge clk) begin : COUNTER_INTERFACE
    if (nextState <= 4'b0011) begin
      dataCounter <= 0;
    end else begin
      if (resetCounter == 1'b1) begin
        dataCounter <= 'd0;
      end else begin
        dataCounter <= dataCounter + 1'b1;
      end
    end
  end

  always_ff @(posedge clk) begin : RECIEVE_INTERFACE
    if (nextState == RECIEVE) begin
      if (recieveCounter == FULL_CYCLE) begin
        didFinishRecieve <= (recievePointer == 33) ? 1'b1 : 1'b0;
        recievePointer <= recievePointer + 1'b1;
        recieveCounter <= 0;
        zeroCounter <= 0;
      end else begin
        if (recieveCounter == 30) begin
          dataBuffer[recievePointer] <= (zeroCounter >= HALF_CLOCK_COUNT) ? 1'b0 : 1'b1;
        end
        zeroCounter <= (dataInputReg == 1'b0) ? zeroCounter + 1'b1 : zeroCounter;
        recieveCounter <= recieveCounter + 1'b1;
        didFinishRecieve <= 1'b0;
      end
    end else begin
      didFinishRecieve <= 1'b0;
      recieveCounter <= 1'b0;
      recievePointer <= 1'b0;
    end
  end

  always_ff @(posedge clk) begin : FINISH_INTERFACE
    if (nextState == FINISH) begin
      finishCounter <= finishCounter + 1'b1;
    end else begin
      finishCounter <= 0;
    end
  end

  always_comb begin
    unique case (currentState)
      IDLE: begin
        resetCounter = 1'b1;
        nextState = (start == 1'b1) ? TRANSMIT_COMMAND : IDLE;
      end
      TRANSMIT_COMMAND: begin
        resetCounter = 1'b1;
        nextState = (pollReg == 9) ? RECIEVE :
                    (POLL_COMMAND[pollReg] == 1'b1) ? SEND1_ONE: SEND0_ONE;
      end
      SEND0_ONE: begin
        nextState = (dataCounter == THREE_US) ? SEND0_TWO : SEND0_ONE;
        resetCounter = (dataCounter == THREE_US) ? 1'b1 : 1'b0;
      end
      SEND0_TWO: begin
        nextState = (dataCounter == ONE_US) ? TRANSMIT_COMMAND : SEND0_TWO;
        resetCounter = (dataCounter == ONE_US) ? 1'b1 : 1'b0;
      end
      SEND1_ONE: begin
        nextState = (dataCounter == ONE_US) ? SEND1_TWO : SEND1_ONE;
        resetCounter = (dataCounter == ONE_US) ? 1'b1 : 1'b0;
      end
      SEND1_TWO: begin
        nextState = (dataCounter == THREE_US) ? TRANSMIT_COMMAND : SEND1_TWO;
        resetCounter = (dataCounter == THREE_US) ? 1'b1 : 1'b0;
      end
      RECIEVE: begin
        nextState = (didFinishRecieve == 1'b1) ? FINISH : RECIEVE;
        resetCounter = 1'b1;
      end
      FINISH : begin
        nextState = (finishCounter == MAX_FINISH_COUNT) ? IDLE : FINISH;
        resetCounter = 1'b1;
      end
    endcase
  end

  always_ff @(posedge clk) begin : TRANSMIT_DATA_REGISTER
    case (nextState)
      SEND0_ONE: transmitDataRegister <= 1'b0;
      SEND1_ONE : transmitDataRegister <= 1'b0;
      SEND1_TWO: transmitDataRegister <= 1'b1;
      SEND0_TWO: transmitDataRegister <= 1'b1;
      FINISH: transmitDataRegister <= 1'b0;
    endcase
  end

  assign outputEnable = (currentState == RECIEVE) ? 1'b0 : 1'b1;
  assign dataController = (outputEnable == 1'b1) ? transmitDataRegister : 1'bz;
  assign readValid = (currentState == FINISH) ? 1'b1 : 1'b0;
  assign data = dataBuffer;
endmodule