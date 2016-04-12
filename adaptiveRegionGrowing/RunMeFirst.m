cd ../../UserSandBox/Maria_03_13;

load('BigArray_16Jan_3rdSample.mat'); %January16, sample 3
% load('BigArraySample2.mat'); %sample 2
% load('BigArrayBottomPartWorkspace.mat'); %bottom part

adjustedBigArray = getAdjustedBigArray(BigArray);
cd ../../Utilities/adaptiveRegionGrowing;

array2D = squeeze(sum(adjustedBigArray, 2));
finalListPixelRegion = adaptiveRegionGrowingSegmentation(array2D);
% finalListPixelRegion = adaptiveRegionGrowingStep1Only(array2D);
        