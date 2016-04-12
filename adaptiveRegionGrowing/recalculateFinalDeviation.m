function [ld, ud, med] = recalculateFinalDeviation(w, med, arrayRegionIntensity)
    % ld and ud have to be adjusted in order to account for the constant
    % underestimation of the standard deviation. For this, we will keep
    % only the pixels in the training region that deviate by less than 1.5w
    % from the current median.
    
    % deviation criteria
    deviationCrit = 1.5 * w * med;
    
    lowerLimit = med - deviationCrit;
    upperLimit = med + deviationCrit;
    
    % keep only the pixels that are within the range specify [med-dev,
    % med+dev]
    newArrayRegionIntensity = [];
    for i=1:length(arrayRegionIntensity)
        
        val = arrayRegionIntensity(i);
        if (val >= lowerLimit) && (val <= upperLimit)
           newArrayRegionIntensity = [newArrayRegionIntensity, val];  %#ok<AGROW>
        end

    end

    med = median(newArrayRegionIntensity);
    
     %get ld and ud arrays
    indexLTmed = newArrayRegionIntensity < med;
    indexGTmed = newArrayRegionIntensity > med;
    
    ldArray = newArrayRegionIntensity(indexLTmed);
    udArray = newArrayRegionIntensity(indexGTmed);
    
    ld = std(ldArray);
    ud = std(udArray);
    
end