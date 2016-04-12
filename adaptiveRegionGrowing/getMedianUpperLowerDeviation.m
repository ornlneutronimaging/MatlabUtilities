function [med, ld, ud] = getMedianUpperLowerDeviation(array)
    %getMedianUpperLowerDeviation calculate the median (-> med) of 
    % the array, as well as the
    % lower deviation -> ld (standard deviation of all the elements 
    % having a value less than the median) and the uppder deviation -> ud
    % (standard deviation of all the elements having a value more than
    % the median).
    
    %median
    med = median(array);
    
    %get ld and ud arrays
    indexLTmed = array < med;
    indexGTmed = array > med;
    
    ldArray = array(indexLTmed);
    udArray = array(indexGTmed);
    
    ld = std(ldArray);
    ud = std(udArray);
    
end

