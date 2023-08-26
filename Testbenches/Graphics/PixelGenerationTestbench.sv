module PixelGenerationTestbench();
  
  parameter HEIGHT = 420;
  parameter WIDTH = 620;
  
  PixelGeneration pkt;
  logic [7:0] pixelOut;
  logic signed [15:0] nextX, nextY, leftPaddleX, leftPaddleY,
  	rightPaddleX, rightPaddleY, pongBallX, pongBallY;
  
  PixelGenerationLogic generation (
    .leftPaddle({leftPaddleX, leftPaddleY}),
    .rightPaddle({rightPaddleX, rightPaddleY}),
    .pongBall({pongBallX, pongBallY}),
    .nextX(nextX),
    .nextY(nextY),
    .pixelOut(pixelOut)
  );
  
  initial begin
    pkt = new();
    pkt.randomize();
    leftPaddleX = pkt.leftPaddleX;
    leftPaddleY = pkt.leftPaddleY;
    rightPaddleX = pkt.rightPaddleX;
    rightPaddleY = pkt.rightPaddleY;
    pongBallX = pkt.pongBallX;
    pongBallY = pkt.pongBallY;
    nextX = pkt.nextX;
    nextY = pkt.nextY;
    
    $monitor("Recieved colour %d", pixelOut);
    
    for (int j = 0; j<HEIGHT*WIDTH; j = j+1) begin
      #2
      if (pixelOut != pkt.returnExpectedColour(nextX, nextY)) begin
        $display("Error occured at pixels x - %h y - %h", nextX, nextY);
        $stop;
      end
     pkt.IncrementPixels();
     {nextX, nextY} = {pkt.nextX, pkt.nextY};
    end
  end
  
endmodule