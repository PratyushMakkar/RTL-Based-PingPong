module MockN64Device (
  input logic en,
  inout logic data,
  input logic [15:0] simTimeCounter,
  input logic [33:0] command
);
  
  enum logic [2:0] {IDLE, RECIEVE, TRANSMIT} state;
  logic [6:0] counter;
  logic dataReg = 1'b0;
  logic unsigned [15:0] counterReg;
  
  initial begin
    counter = 0;
    state = IDLE;
  end
  
  always @(negedge data) begin
    counter <= counter + 1;
    if (state == IDLE) begin
      state <= (en == 1'b1) ? RECIEVE : IDLE;
    end else if (state == RECIEVE) begin
      if (counter == 9) begin
        state <= TRANSMIT;
        counterReg <= simTimeCounter;
        counter <= 0;
      end 
    end else begin
      if (counter == 34) begin
        state <= IDLE;
        counter <= 0;
      end
    end
  end
  
  always @(*) begin
    if (state == TRANSMIT) begin
      if (command[counter-1] == 1'b1) begin
        dataReg = (((simTimeCounter - counterReg) % 40) < 10) ? 1'b0 : 1'b1;
      end else begin
        dataReg = (((simTimeCounter - counterReg) % 40) < 30) ? 1'b0 : 1'b1;
      end
    end
  end

  assign data = (state == TRANSMIT) ? dataReg : 1'bz;
endmodule