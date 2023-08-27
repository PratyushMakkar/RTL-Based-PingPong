`include "VGATestbenchPackage.sv"
import VGATestbenchPackage::*;

module VGADriverTestbench();
  
  logic clk, rst;
  logic [23:0] colour;
  logic [9:0] pixelX, pixelY;
  logic [9:0] hsyncReg, vsyncReg;
  logic hsync, vsync;
  logic [7:0] red, green, blue;
  logic sync, blank, clkOut;
  
  parameter HSYNC_ACTIVE  = 639;
  parameter VSYNC_ACTIVE  = 479;
  
  VGAImageData pkt;
  
  VGADriver vga (
    .clk(clk),
    .rst(rst),
    .colour_in(colour),
    .x_pixel(pixelX),
    .y_pixel(pixelY),
    .hsyncReg(hsyncReg),
    .vsyncReg(vsyncReg),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue),
    .sync(sync),
    .blank(blank),
    .clkOut(clkOut)
  );
  
  initial begin
    pkt = new();
    pkt.randomize();
    $monitor("The value of hsync is %h at x - %d y -%d", hsync, pixelX, pixelY);
    
    clk = 1'b0;
    #1
    colour <= pkt.getRGBData(pixelX, pixelY);
    #1
    clk = 1'b1;
  end
  
  always @(posedge clk) begin
    colour <= pkt.getRGBData(pixelX, pixelY);
    if ((pixelX > 0 && pixelX < 640) && (pixelY >= 0 && pixelY < 480)) begin
      if ({red, blue, green} != pkt.getRGBData(hsyncReg, vsyncReg)) begin
        $display("There was a mismatch at x- %h y - %h", hsyncReg, vsyncReg);
        $display("Expected colour - %h, recieved - %h", pkt.getRGBData(hsyncReg, vsyncReg), {red, blue, green}); 
        $stop;
      end
    end
    if (pixelX == HSYNC_ACTIVE && pixelY == VSYNC_ACTIVE) $finish;
  end
  
  always #1 clk = ~clk;

endmodule