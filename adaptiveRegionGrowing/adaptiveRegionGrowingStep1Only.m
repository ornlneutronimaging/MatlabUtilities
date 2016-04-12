function [finalListPixelRegion, Tl, Tu] = adaptiveRegionGrowingStep1Only(array2D, wStep)
    
    %% Adaptive Region Growing Algorithm for Semi-Automatic Segmentation
    % only the first step is implemented and use here.
    %
    % This function will return the ROI plus the min and max threshold 
    % calculated.
    %
    % Algorithm source: Segmentation of Medical Images Using Adaptive Region
    % Growing (2001) by Regina Pohle, Klaus D. Toennies.
    % <http://http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.12.510>
    %
    % developer: Jean Bilheux
    %
    
    % information display along process (true/false)
    verbose = true;
    
    % the number of pixels we want the program to check the homogeneity
    % parameters (step1)
    nbrPixelVisited = 10000;
    
    % w : weight
    wStep1 = wStep;
    %wStep1 = 1.5; % used in step1
    
    % ---- end of inputs ----------
    
    % == STEP 1 * Calculation of homogeneity parameters ======================
    if verbose
        fprintf('\n == Calculation of homogeneity parameters ==\n\n');
    end
    
    % doing a fresh restart
    close(findobj('type','figure','name','Integrated View over depth - Step 1'));
    
    % Display BigArray integrated view
    % [row,depth,col] = size(adjustedBigArray);
    [row, col] = size(array2D);
    
    if verbose
        fprintf('-> Information about BigArray loaded\n\n');
        fprintf('\t   row = %d\n',row);
        fprintf('\t   col = %d\n',col);
    end
    
    scrsz=get(0,'ScreenSize');
    fig1=figure(1);
    set(fig1,'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
    set(fig1,'name','Integrated View over depth - Step 1');
    imagesc(array2D);
    axis equal;
    axis([1 col 1 row])
    colorbar;
    
    % ** Initialization **
    
    title('Please Select the Seed Point ...','fontsize', 20);
    [indexCol,indexRow] = ginput(1);
    
    % record seed position to start the step 2 of process
    seedPoint = [indexCol, indexRow];
    
    %keep only integer value of position
    indexCol=fix(indexCol);
    indexRow=fix(indexRow);
    if verbose
        fprintf('\n-> Graphical seed point selected:\n');
        fprintf('\t indexCol = %d\n', indexCol);
        fprintf('\t indexRow = %d\n', indexRow);
    end
    
    title(sprintf('Seed Point selected: (indexCol,indexRow) = (%g,%g)', ...
        indexCol, indexRow), 'fontsize', 20);
    hold on
    seed=plot(indexCol,indexRow);
    set(seed, 'marker','hexagram',...
        'markeredgecolor','red',...
        'markersize',10,...
        'markerfacecolor','yellow');
    
    %Initialization using 3x3 pixels around seed point
    initArray = [array2D(indexRow-1,indexCol-1), ...
        array2D(indexRow-1,indexCol), ...
        array2D(indexRow-1,indexCol+1), ...
        array2D(indexRow,indexCol-1), ...
        array2D(indexRow,indexCol), ...
        array2D(indexRow,indexCol+1), ...
        array2D(indexRow+1,indexCol-1), ...
        array2D(indexRow+1,indexCol), ...
        array2D(indexRow+1,indexCol+1)];
    
    if verbose
        fprintf('\n-> Initialization of median, ld and ud using 3x3 neighborhood around seed point.\n');
        fprintf('3x3 array:\n');
        disp(initArray);
    end
    
    [med, ld, ud] = getMedianUpperLowerDeviation(initArray);
    [Tl, Tu] = getThresholds(wStep1, length(initArray), med, ld, ud);
    
    if verbose
        fprintf('\tmed = %04.2f \t - median\n', med);
        fprintf('\t ld = %04.2f \t - lower deviation\n', ld);
        fprintf('\t ud = %04.2f \t - upper deviation\n', ud);
        fprintf('\t Tl = %04.2f \t - lower threshold\n', Tl);
        fprintf('\t Tu = %04.2f \t - upper threshold\n', Tu);
    end
    
    % ** random walk **
    
    listPixelRegion = [[indexCol-1,indexRow-1];[indexCol-1,indexRow];[indexCol-1,indexRow+1];
        [indexCol,indexRow-1];[indexCol,indexRow];[indexCol,indexRow+1];
        [indexCol+1,indexRow-1];[indexCol+1,indexRow];[indexCol+1,indexRow+1]];
    
    % last number of pixel in region for which the parameters of the
    % homogeneity were recalculated (we started with 9 pixels = 3x3)
    lastRecalNbrPixel = 9;
    
    % list of intensities of pixel within region
    arrayRegionIntensity = initArray;
    
    if verbose
        disp('');
    end
    
    nbrPixelRejectedStep1 = 0;
    
    while (true)
        
        n=0;
        while (n < nbrPixelVisited)
            
            [rDeltaCol, rDeltaRow] = getRandomWalkParameters();
            
            newIndexCol = indexCol + rDeltaCol;
            newIndexRow = indexRow + rDeltaRow;
            
            bKeepPixel = isPixelWithinRange(array2D(newIndexRow, newIndexCol), Tl, Tu);
            if bKeepPixel
                color = 'red';
                keepPixel = 'yes';
            else
                color = 'white';
                keepPixel = 'no';
                nbrPixelRejectedStep1 = nbrPixelRejectedStep1 + 1;
            end
            
            %     if verbose
            %         fprintf('n=%d , isPixelInRange=%s\n', n, keepPixel)
            %     end
            
            %display new position
            seed=plot(newIndexCol,newIndexRow);
            set(seed, 'marker','+',...
                'markeredgecolor',color,...
                'markersize',8);
            %     drawnow
            
            if bKeepPixel
                [listPixelRegion, arrayRegionIntensity] = addNewPixel(n, ...
                    listPixelRegion, ...
                    newIndexCol, ...
                    newIndexRow, ...
                    arrayRegionIntensity, ...
                    array2D);
            end
            
            if bKeepPixel
                indexCol = newIndexCol;
                indexRow = newIndexRow;
            end
            
            % check if we need to recalculate median, ld, ud, Tl and Tu
            if length(listPixelRegion) == lastRecalNbrPixel * 2
                
                fprintf('-> Recalculating med, ld, ud, Tl and Tu\n');
                [med, ld, ud] = getMedianUpperLowerDeviation(arrayRegionIntensity);
                [Tl, Tu] = getThresholds(wStep1, length(arrayRegionIntensity), med, ld, ud);
                lastRecalNbrPixel = lastRecalNbrPixel * 2;
                
                fprintf('\tmed=\t%.2f\n', med);
                fprintf('\t ld=\t%.2f\n', ld);
                fprintf('\t ud=\t%.2f\n', ud);
                fprintf('\t Tl=\t%.2f\n', Tl);
                fprintf('\t Tu=\t%.2f\n', Tu);
                fprintf('\t -> lastRecalNbrPixel =\t%d\n', lastRecalNbrPixel);
                
            end
            
            n = n + 1;
            
        end
        
        drawnow;
        
        %Ask user if he wants to continue or not the work
        choice = questdlg('Would you like to Continue?', ...
            'Continue or not step2','Yes','No','No');
        
        %     fprintf('**** it took %f s to run step2\n',toc);
        
        % stop calculation here.
        if strcmp(choice,'No')
            break;
        end
        
        % otherwise ask user to select a new seedPoint
        title('Please Select a new Seed Point ...','fontsize', 20);
        [indexCol, indexRow] = ginput(1);
        indexCol=fix(indexCol);
        indexRow=fix(indexRow);
        
        title('Running step1 again!','fontsize',20);
        
    end
    
    hold off;
    
        %remove all empty cells
    listPixelRegion = listPixelRegion(~ismember(listPixelRegion,[0,0]));
    listPixelRegion = reshape(listPixelRegion, length(listPixelRegion)/2,2);

    finalListPixelRegion = listPixelRegion;
    
end
