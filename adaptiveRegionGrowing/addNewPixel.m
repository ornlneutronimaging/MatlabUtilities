function [listPixelRegion, arrayRegionIntensity] = addNewPixel(i, ...
        listPixelRegion, ...
        newIndexCol, ...
        newIndexRow, ...
        arrayRegionIntensity, ...
        array2D)
    %addNewPixel will add the new col and row indexes if not part of the
    % list already and update the list of intensities of the region
    
    if ~ismember([newIndexCol, newIndexRow], listPixelRegion, 'rows')
        listPixelRegion(i,:) = [newIndexCol, newIndexRow];
%         listPixelRegion = [listPixelPosition; [newIndexCol, newIndexRow]];
         arrayRegionIntensity = [arrayRegionIntensity, array2D(newIndexRow, newIndexCol)];
%        arrayRegionIntensity(i) = array2D(newIndexRow, newIndexCol);
    end
    
end