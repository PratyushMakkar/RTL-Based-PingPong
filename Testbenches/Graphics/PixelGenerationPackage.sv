package PixelGenerationPackage;

  class PixelGeneration;
    parameter HEIGHT = 420;
    parameter WIDTH = 620;
    
    localparam logic [7:0] COLOUR_WHITE = 8'hFF;
    localparam logic [7:0] COLOUR_BLACK = 8'h00;

    parameter logic signed [15:0] PADDLE_HEIGHT = 16'h0064;
    parameter logic signed [15:0] PADDLE_WIDTH = 16'h000F;
    parameter logic signed [15:0] BALL_DIMENSION = 16'h000F;
    
    rand logic signed [15:0] leftPaddleX, leftPaddleY,
      rightPaddleX, rightPaddleY, pongBallX, pongBallY;
    logic signed [15:0] nextX = 0, nextY = 0;
    
    function void IncrementPixels();
      if (nextX == WIDTH) begin
        nextX = 0;
        if (nextY == WIDTH) begin
          $display("Finished all possible combinations for pixels");
          $finish;
        end else begin 
          nextY <= nextY + 1'b1;
        end
      end else begin
        nextX <= nextX + 1'b1;
      end
    endfunction
    
    function logic[7:0] returnExpectedColour(logic signed [15:0] nextXSigned, logic signed [15:0] nextYSigned);
      logic [7:0] pixelOut;
      if (($signed((nextXSigned - leftPaddleX)) <= PADDLE_WIDTH) || ($signed((nextYSigned - leftPaddleY)) <= PADDLE_HEIGHT)) pixelOut = COLOUR_WHITE;
      else if (($signed((nextXSigned - rightPaddleX)) <= PADDLE_WIDTH) || ($signed((nextYSigned - rightPaddleY)) <= PADDLE_HEIGHT)) pixelOut = COLOUR_WHITE;
      else if (($signed((nextXSigned - pongBallX)) <= PADDLE_WIDTH) || ($signed((nextYSigned - pongBallY)) <= PADDLE_HEIGHT)) pixelOut = COLOUR_WHITE;
      else pixelOut = COLOUR_BLACK;
      return pixelOut;
    endfunction
    
    constraint PixelGenerationContriants {
      leftPaddleX >= 0 && leftPaddleX <= WIDTH;
      leftPaddleY >= 0 && leftPaddleY <= HEIGHT;
      
      rightPaddleX >= 0 && rightPaddleX <= WIDTH;
      rightPaddleY >= 0 && rightPaddleY <= HEIGHT;
      
      pongBallX >= 0 && pongBallX <= WIDTH;
      pongBallY >= 0 && pongBallY <= HEIGHT;
    }

  endclass

endpackage