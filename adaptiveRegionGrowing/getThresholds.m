function [Tl, Tu] = getThresholds(w, n, med, ld, ud)
   %getThresholds returns the lower (Tl) and upper (Tu) thresholds
   % based on the following algorithms
   %
   % Tu = med + [ ud * w + c(n)]
   % Tl = med - [ ld * w + c(n)]
   %
   % and c(n) = 20/sqrt(n)
   %
    
   cn = single(20) / sqrt(n);
   
   Tu = med + (ud * w + cn);
   Tl = med - (ld * w + cn);
    
end