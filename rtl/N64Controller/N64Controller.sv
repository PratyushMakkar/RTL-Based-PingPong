module N64Controller (
  input logic clk,
  input logic pollEnable,
  input logic start,
  output logic [33:0] data,
  output logic readValid,
  inout logic dataController      // Singal for the N64 controller
);

  localparam ONE_US = 4;
  localparam THREE_US = 4;
  localparam HALF_CLOCK_COUNT = 100;
  localparam MAX_FINISH_COUNT = 10;
  localparam logic [8:0] POLL_COMMAND = 9'b110000000;

  //--------------------------- Transmt Data Command Interface Signals ----------//
  logic [3:0] pollReg = 0;
  logic [31:0] dataCounter = 0;
  logic resetCounter = 0;

  //--------------------------- Recieve Data Interface Signals -----------------//
  logic [33:0] dataBuffer = 0;
  logic [31:0] recieveCounter = 0;
  logic [5:0] recievePointer = 0;
  logic didFinishRecieve = 0;

  //--------------------------- Finish Interface Signals -----------------//
  logic [5:0] finishCounter = 0;

  //--------------------------- Helper Signals -----------------//
  logic outputEnable, transmitDataRegister;

  logic [3:0] enum {IDLE, TRANSMIT_COMMAND, RECIEVE, FINISH, SEND0_ONE, SEND0_TWO, SEND1_ONE, SEND1_TWO} currentState, nextState;
  
  always_ff @(posedge clk) begin
    currentState <= nextState;
  end

  always_ff @(posedge clk) begin : POLL_REG_INTERFACE
    if (nextState == TRANSMIT_COMMAND) begin
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
    recieveCounter <= 0;
    recievePointer <= 0;
    didFinishRecieve <= 0;
    if (nextState == RECIEVE) begin
      if (recieveCounter == HALF_CLOCK_COUNT) begin
        dataBuffer[recievePointer] = data;
        didFinishRecieve <= (recievePointer == 33) ? 1'b1 : 1'b0;
        recievePointer <= recievePointer + 1'b1;
        recieveCounter <= 0;
      end else begin
        recieveCounter <= recieveCounter + 1'b1;
        didFinishRecieve <= 1'b0;
      end
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
    outputEnable <= (currentState <= 4'b011) ? 1'b1 : 1'b0;
    unique case (currentState)
      IDLE: begin
        resetCounter <= 1'b1;
        nextState = (start == 1'b1) ? TRANSMIT : IDLE;
      end
      TRANSMIT_COMMAND: begin
        resetCounter <= 1'b1;
        nextState = (pollReg == 9) ? RECIEVE :
                    (POLL_COMMAND[pollReg] == 1'b1) ? SEND1_ONE: SEND0_ONE;
      end
      SEND0_ONE: begin
        nextState <= (dataCounter == THREE_US) ? SEND0_TWO : SEND0_ONE;
        resetCounter <= (dataCounter == THREE_US) : 1'b1 : 1'b0;
      end
      SEND0_TWO: begin
        nextState <= (dataCounter == ONE_US) ? TRANSMIT_COMMAND : SEND0_TWO;
        resetCounter <= (dataCounter == ONE_US) : 1'b1 : 1'b0;
      end
      SEND1_ONE: begin
        nextState <= (dataCounter == ONE_US) ? SEND1_TWO : SEND1_ONE;
        resetCounter <= (dataCounter == ONE_US) : 1'b1 : 1'b0;
      end
      SEND1_TWO: begin
        nextState <= (dataCounter == THREE_US) ? TRANSMIT_COMMAND : SEND1_TWO;
        resetCounter <= (dataCounter == THREE_US) : 1'b1 : 1'b0;
      end
      RECIEVE: begin
        nextState <= (didFinishRecieve == 1'b1) : FINISH : RECIEVE;
        resetCounter <= 1'b1;
      end
      FINISH : begin
        nextState <= (finishCounter == MAX_FINISH_COUNT) ? IDLE : FINISH;
        resetCounter <= 1'b1;
      end
    endcase
  end

  always_comb begin : TRANSMIT_DATA_REGISTER
    case (currentState)
      SEND0_ONE: transmitDataRegister <= 1'b0;
      SEND0_TWO : transmitDataRegister <= 1'b0;
      default: transmitDataRegister <= 1'b1;
    endcase
  end

  assign dataController = (outputEnable == 1'b1) ? transmitDataRegister : 1'bz;
  assign readValid = (currentState == FINISH) ? 1'b1 : 1'b0;
  assign data = dataBuffer;
endmodule