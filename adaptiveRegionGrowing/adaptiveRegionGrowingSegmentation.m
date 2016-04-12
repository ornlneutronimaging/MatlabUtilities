function finalListPixelRegion = adaptiveRegionGrowingSegmentation(array2D)
    
    %% Adaptive Region Growing Algorithm for Semi-Automatic Segmentation
    %
    % Algorithm source: Segmentation of Medical Images Using Adaptive Region
    % Growing (2001) by Regina Pohle, Klaus D. Toennies.
    % <http://http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.12.510>
    %
    % developer: Jean Bilheux
    %
    
    % information display along process (true/false)
    verbose = true;
    
    %size of marker in step2
    markersize = 5;
    
    % color of the selection
    selectionColor = [0,0,0];
    
    % the number of pixels we want the program to check the homogeneity
    % parameters (step1)
    nbrPixelVisited = 5000;
    
    % the number of pixels to use to figure out the region (step2)
    nbrPixelStep2 = 10000;
    listNbrPixelStep2 = (nbrPixelStep2);
    repeatStep2Factor = 5;
    listRepeatStep2Factor = (repeatStep2Factor);
    
    % w : weight
    wStep1 = 1.7; % used in step1
    wStep2 = 2.7; % used in step2 (default value is 2.58)
    
    % ---- end of inputs ----------
    
    
    %% == STEP 1 * Calculation of homogeneity parameters ======================
    if verbose
        fprintf('\n == Calculation of homogeneity parameters ==\n\n');
    end
    
    % doing a fresh restart
    close(findobj('type','figure','name','Integrated View over depth - Step 1'));
    close(findobj('type','figure','name','Integrated View over depth - Step 2'));
    
    % Display BigArray integrated view
    % [row,depth,col] = size(adjustedBigArray);
    [row, col] = size(array2D);
    
    if verbose
        fprintf('-> Information about BigArray loaded\n\n');
        fprintf('\t   row = %d\n',row);
        fprintf('\t   col = %d\n',col);
    end
    
    % array2D = squeeze(sum(adjustedBigArray, 2));
    
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
    
    tic
    
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
    arrayRegionIntensity = [array2D(indexRow-1,indexCol-1), ...
        array2D(indexRow-1,indexCol), ...
        array2D(indexRow-1,indexCol+1), ...
        array2D(indexRow,indexCol-1), ...
        array2D(indexRow,indexCol), ...
        array2D(indexRow,indexCol+1), ...
        array2D(indexRow+1,indexCol-1), ...
        array2D(indexRow+1,indexCol), ...
        array2D(indexRow+1,indexCol+1)];
    
    %     if verbose
    %         fprintf('\n-> Initialization of median, ld and ud using 3x3 neighborhood around seed point.\n');
    %         fprintf('3x3 array:\n');
    %         disp(arrayRegionIntensity(arrayRegionIntensity~=0));
    %     end
    
    [med, ld, ud] = getMedianUpperLowerDeviation(arrayRegionIntensity);
    [Tl, Tu] = getThresholds(wStep1, 9, med, ld, ud);
    
    if verbose
        fprintf('\tmed = %04.2f \t - median\n', med);
        fprintf('\t ld = %04.2f \t - lower deviation\n', ld);
        fprintf('\t ud = %04.2f \t - upper deviation\n', ud);
        fprintf('\t Tl = %04.2f \t - lower threshold\n', Tl);
        fprintf('\t Tu = %04.2f \t - upper threshold\n', Tu);
    end
    
    % ** random walk **
    
    listPixelRegion = zeros(nbrPixelVisited, 2);
    listPixelRegion(1,:) = [indexCol-1,indexRow-1];
    listPixelRegion(2,:) = [indexCol-1,indexRow];
    listPixelRegion(3,:) = [indexCol-1,indexRow+1];
    listPixelRegion(4,:) = [indexCol,indexRow-1];
    listPixelRegion(5,:) = [indexCol,indexRow];
    listPixelRegion(6,:) = [indexCol,indexRow+1];
    listPixelRegion(7,:) = [indexCol+1,indexRow-1];
    listPixelRegion(8,:) = [indexCol+1,indexRow];
    listPixelRegion(9,:) = [indexCol+1,indexRow+1];
    
    %     listPixelRegion = [[indexCol-1,indexRow-1];[indexCol-1,indexRow];[indexCol-1,indexRow+1];
    %         [indexCol,indexRow-1];[indexCol,indexRow];[indexCol,indexRow+1];
    %         [indexCol+1,indexRow-1];[indexCol+1,indexRow];[indexCol+1,indexRow+1]];
    
    % last number of pixel in region for which the parameters of the
    % homogeneity were recalculated (we started with 9 pixels = 3x3)
    lastRecalNbrPixel = 9;
    
    if verbose
        disp('');
    end
    
    nbrPixelRejectedStep1 = 0;
    n=1;
    while (n <= nbrPixelVisited)
        
        [rDeltaCol, rDeltaRow] = getRandomWalkParameters();
        
        newIndexCol = indexCol + rDeltaCol;
        newIndexRow = indexRow + rDeltaRow;
        
        bKeepPixel = isPixelWithinRange(array2D(newIndexRow, newIndexCol), Tl, Tu);
        if bKeepPixel
            color = selectionColor ;
            %         keepPixel = 'yes';
        else
            color = 'blue';
            %         keepPixel = 'no';
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
        %             drawnow
        
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
    
    % ld and ud have to be adjusted in order to account for the constant
    % underestimation of the standard deviation. For this, we will keep
    % only the pixels in the training region that deviate by less than 1.5w
    % from the current median.
    [ld, ud, med] = recalculateFinalDeviation(wStep1, med, arrayRegionIntensity);
    if verbose
        fprintf('-> Readjusting deviations and median\n');
        fprintf('\t  ld=\t%.2f\n', ld);
        fprintf('\t  ud=\t%.2f\n', ud);
        fprintf('\t med=\t%.2f\n', med);
    end
    
    fprintf('**** it took %f s to run step1\n',toc);
    
    hold off;
    
    %remove all empty cells
    listPixelRegion = listPixelRegion(~ismember(listPixelRegion,[0,0]));
    listPixelRegion = reshape(listPixelRegion, length(listPixelRegion)/2,2);
    
    %% == STEP 2 - Determine the pixels of the region =========================
    if verbose
        fprintf('\n == Determine the pixels of the region == \n\n');
    end
    
    scrsz=get(0,'ScreenSize');
    fig2=figure(2);
    set(fig2,'Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
    set(fig2,'name','Integrated View over depth - Step 2');
    imagesc(array2D);
    axis equal;
    axis([1 col 1 row])
    colorbar;
    title('Calculating ...','fontsize',20);
    hold on;
    drawnow;
    
    % get final thresholds values
    [Tl, Tu] = getThresholds(wStep2, length(arrayRegionIntensity), med, ld, ud);
    
    % list of row and col indexes of final growing region
    finalListPixelRegion = seedPoint;
    finalArrayRegionIntensity = (array2D(fix(seedPoint)));
    
    %for each new iteration, will go back to seedPoint
    nbrPixelsRejectedStep2 = 0;
    
    tocnTotal = 0; %total time it takes to run step2
    while (true) %only way to leave is by a break at the end of while
        
        tocn = zeros(repeatStep2Factor);
        for j=1:repeatStep2Factor
            
            tic;
            
            str = sprintf('Working on iteration %d/%d ...', j, repeatStep2Factor);
            title(str,'fontsize',20);
            drawnow;
            
            % we start at the same seed point
            indexCol = fix(seedPoint(1));
            indexRow = fix(seedPoint(2));
            
            for i=1:nbrPixelStep2
                
                [rDeltaCol, rDeltaRow] = getRandomWalkParameters();
                
                newIndexCol = indexCol + rDeltaCol;
                newIndexRow = indexRow + rDeltaRow;
                
                bKeepPixel = isPixelWithinRange(array2D(newIndexRow, newIndexCol), Tl, Tu);
                
                if bKeepPixel
                    color = selectionColor;
                    %                 keepPixel = 'yes';
                else
                    color = 'blue';
                    %                 keepPixel = 'no';
                    nbrPixelsRejectedStep2 = nbrPixelsRejectedStep2 +1;
                end
                
                seed=plot(newIndexCol,newIndexRow);
                set(seed, 'marker','s',...
                    'markeredgecolor',color,...
                    'markersize',markersize);
                %     drawnow
                
                if bKeepPixel
                    [finalListPixelRegion, finalArrayRegionIntensity] = addNewPixel(i, ...
                        finalListPixelRegion, ...
                        newIndexCol, ...
                        newIndexRow, ...
                        finalArrayRegionIntensity, ...
                        array2D);
                    indexCol = newIndexCol;
                    indexRow = newIndexRow;
                    
                end
                
            end
            
            tocn(j) = toc;
            tocnTotal = tocnTotal + tocn(j);
            fprintf('**** it took %f s to run step2\n',tocn(j));
            
        end
        
        str = sprintf('Done after %d x %d iterations!',repeatStep2Factor, nbrPixelStep2);
        title(str,'fontsize',20);
        
        drawnow;
        
        %Ask user if he wants to continue or not the work
        choice = questdlg('Would you like to Continue?', ...
            'Continue or not step2','Yes','No','No');
        
        % stop calculation here.
        if strcmp(choice,'No')
            break;
        end
        
        % otherwise ask user to select a new seedPoint
        title('Please Select a new Seed Point ...','fontsize', 20);
        seedPoint = ginput(1);
        
        prompt = {'Nbr pixel to use:','Repeat process factor:'};
        dlg_title = 'Parameters';
        num_lines = 1;
        def = {num2str(nbrPixelStep2),num2str(repeatStep2Factor)};
        answer = inputdlg(prompt, dlg_title, num_lines, def);
        nbrPixelStep2 = str2double(answer{1});
        repeatStep2Factor = str2double(answer{2});
        
        listNbrPixelStep2 = [listNbrPixelStep2, nbrPixelStep2];
        listRepeatStep2Factor = [listRepeatStep2Factor, repeatStep2Factor];
        
        title('Running step2 again!','fontsize',20);
        drawnow;
        
        tocnTotal = tocnTotal + sum(tocn);
        
    end
    
    fprintf('\n ++++ total time to run step2 is: %fs.\n', tocnTotal);
    
    hold off;
    
    % Recap of all parameters used
    fprintf('\n******* RECAP ********\n');
    fprintf('STEP 1 : learning step\n');
    fprintf('\t-> Nbr pixels used in learning step: %d\n', nbrPixelVisited);
    fprintf('\t-> weight: %.2f\n', wStep1);
    fprintf('\t-> used %d pixels for calculation\n', length(arrayRegionIntensity));
    fprintf('\t-> rejected %d pixels\n', nbrPixelRejectedStep1);
    fprintf('\n');
    fprintf('STEP 2 : growing region step\n');
    for u=1:length(listRepeatStep2Factor)
        fprintf('\t-> run #%d\n',u');
        fprintf('\t\t-> Nbr iteration: %d\n', listRepeatStep2Factor(u));
        fprintf('\t\t-> Nbr pixels used: %d\n', listNbrPixelStep2(u));
    end
    fprintf('\t-> weight: %.2f\n', wStep2);
    fprintf('\t-> used %d pixels to determine region\n', length(finalArrayRegionIntensity));
    fprintf('\t-> rejected %d pixels\n', nbrPixelsRejectedStep2);
    
    
    %OUTPUT
    %list of pixel coordinates that are part of the growing region
    %-> finalListPixelRegion
    
