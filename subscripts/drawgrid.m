function drawgrid(players, tokno, losstokno, graphset)
%% This function draws the players on the framed grid and adds collected
% tokens
% players is a struct array with fields
% .pos (xy pos in blocks), .sprite
% Dominik R Bach 22.03.2013
% -------------------------------------------------------------------------
% last edited by Dominik R Bach 27.01.2014

% constants 
% -------------------------------------------------------------------------
framesize = graphset.gridblock * (sqrt(2 * (graphset.gridsize + 1).^2));  % add 1/2 gridblock frame 
spritesize = framesize + 4 * graphset.gridblock;                          % add space for collected tokens
% white frame for potential token loss
losstokpoly.x = graphset.gridblock .* [-3 3 3 -3]; 
losstokpoly.y = -0.5 * framesize - (0.7 + [-0.5 -0.5 0.5 0.5]) * graphset.gridblock ; 
losstokpoly.yi = losstokpoly.y + graphset.gridline .* [-1 -1 1 1];
losstokpoly.xi = losstokpoly.x + graphset.gridline .* [1 -1 -1 1];


% local variables
% -------------------------------------------------------------------------
k = 1;          % counter
pos = [1 1];    % temporary variable for player position

% prepare sprite
% -------------------------------------------------------------------------
cgmakesprite(graphset.dispsprite, spritesize, spritesize, graphset.transcol);
cgsetsprite(graphset.dispsprite); 

% draw framed grid
% -------------------------------------------------------------------------
cgdrawsprite(graphset.framesprite, 0, 0);

% draw players on grid
% -------------------------------------------------------------------------
for k = 1:numel(players)
    pos = graphset.blockcentre(players(k).pos(1), players(k).pos(2), :);
    cgdrawsprite(players(k).sprite, pos(1), pos(2));
end;

% add potential token loss
% -------------------------------------------------------------------------  
if ismember(losstokno, [1 3 5])
    losstokpos =  [([3 4 2 5 1] - 3.0) .* graphset.gridblock; -(0.5 * framesize + 0.7 * graphset.gridblock) * ones(1, 5)]; 
else
    losstokpos =  [([3 4 2 5 1 6] - 3.5) .* graphset.gridblock; -(0.5 * framesize + 0.7 * graphset.gridblock) * ones(1, 6)]; 
end;

cgpencol(1, 1, 1);
cgpolygon(losstokpoly.x, losstokpoly.y);
cgpencol(0, 0, 0);
cgpolygon(losstokpoly.xi , losstokpoly.yi);

for k = 1:losstokno
    cgdrawsprite(graphset.losttokensprite, losstokpos(1, k), losstokpos(2, k));
end;

% add collected tokens
% -------------------------------------------------------------------------
if tokno >= 0
    tokensprite = graphset.tokensprite;
else
    tokensprite = graphset.losttokensprite;
    tokno = abs(tokno);
end;

if ismember(tokno, [1 3 5])
    tokpos =  [([3 4 2 5 1] - 3.0) .* graphset.gridblock; (0.5 * framesize + 0.7 * graphset.gridblock) * ones(1, 5)]; 
else
    tokpos =  [([3 4 2 5 1 6] - 3.5) .* graphset.gridblock; (0.5 * framesize + 0.7 * graphset.gridblock) * ones(1, 6)]; 
end;

for k = 1:tokno
    cgdrawsprite(tokensprite, tokpos(1, k), tokpos(2, k));
end;

% make transparent
% -------------------------------------------------------------------------
cgtrncol(graphset.dispsprite, graphset.trans);

% return to screen
% -------------------------------------------------------------------------
cgsetsprite(0);


