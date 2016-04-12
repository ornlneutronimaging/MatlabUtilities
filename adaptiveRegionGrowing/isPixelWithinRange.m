function   bKeepPixel = isPixelWithinRange(pixelValue, Tl, Tu)
   %isPixelWithinRange will check if the intensity of the pixel selected
   % is within the range of the Threshold [Tl, Tu] and will return true or
   % false
    
   if (pixelValue >= Tl) && (pixelValue <= Tu)
       bKeepPixel = true;
       return;
   end
   
   bKeepPixel = false;
   
end