
`include "N64TestbenchPackage.sv"
`include "MockN64Device.sv"
import N64TestbenchPackage::*;

module N64ControllerTestbench();
  
  N64CommandPacket packet;
  logic clk;
  logic start;
  logic [33:0] data;
  logic readValid;
  wire dataPort;
  logic [15:0] simTimeCounter;
  logic [33:0] command;
    
  N64Controller controller (
    .clk(clk),
    .start(start),
    .data(data),
    .readValid(readValid),
    .dataController(dataPort)
  );
  
  MockN64Device device (
    .en(start),
    .data(dataPort),
    .simTimeCounter(simTimeCounter),
    .command(command)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 1'b0;
    start = 1'b0;
    simTimeCounter = 'd0;
    packet = new();
    packet.randomize();
    command = packet.command;
    
    clk = 1'b1;
    start = 1'b1;
    #10
    start = 1'b0;
    #7500
    $finish;
  end
  
  always begin
    #2
    clk = ~clk;
    if (clk == 1'b1) begin
      simTimeCounter = simTimeCounter + 1;
    end
  end
  
  always @(posedge readValid) begin
    if (readValid == 1'b1) begin
      if (command != data) begin
        $display("We did not recieve the correct data");
        $stop;
      end
    end
  end
  
endmodule