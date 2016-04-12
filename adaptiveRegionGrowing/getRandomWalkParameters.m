function [rDeltaX, rDeltaY] = getRandomWalkParameters()
%getRandomWalk return the random delta X and delta Y to 
%apply to the current location
% rDeltaX and rDeltaY can be any of the following couple
% (-1, -1), (-1,0), (-1,1), (0,1), (0,-1), (1,0), (1,-1) or (1,1)

listOfChoices = [[-1,-1];[-1,0];[-1,1];[0,1];[0,-1];[1,0];[1,-1];[1,1]];

% random parameters (0,1,2,3,4,5,6,7 or 8);
randPara = fix(rand()*8)+1;

% element selected
ele = squeeze(listOfChoices(randPara,:));

rDeltaX = ele(1);
rDeltaY = ele(2);

end
