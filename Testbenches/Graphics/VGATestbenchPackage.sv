package VGATestbenchPackage;
	class VGAImageData;
      rand logic [23:0] imageData [9:0][9:0];
      
      function logic [23:0] getRGBData(logic [9:0] pixelX, logic [9:0] pixelY); 
        return imageData[pixelX][pixelY];
      endfunction
    endclass
endpackage