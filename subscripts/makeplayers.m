function makeplayers(graphset)
% This function draws the players on the framed grid
% players is a struct array with fields
% .xpos, .ypos (in blocks), .sprite
% Dominik R Bach 22.03.2013
% -------------------------------------------------------------------------
% last edited by Dominik R Bach 23.01.2014

% constants 
% -------------------------------------------------------------------------
sprite = [graphset.preysprite, graphset.tokensprite, graphset.losttokensprite, graphset.sleeppredsprite, graphset.activepredsprite];

% local variables
% -------------------------------------------------------------------------
k = 1; % counter
x = [0 0 0]; % x position
y = [0 0 0]; % y pos

% prepare and draw sprites
% -------------------------------------------------------------------------
for k = 1:numel(sprite)
    cgmakesprite(sprite(k), graphset.gridblock, graphset.gridblock, graphset.transcol); 
    cgsetsprite(sprite(k)); 
    cgpencol(graphset.spritecol{sprite(k)});
    if k == 1 % a triangle
        x = [-(graphset.gridblock/2) + 20, 0, (graphset.gridblock/2) - 20];
        y = [-(graphset.gridblock/2) + 30, (graphset.gridblock/2) - 10, -(graphset.gridblock/2) + 30];
        cgpolygon(x, y);
    elseif ismember(k, [2, 3]) % a diamond
        x = [-(graphset.gridblock * 0.3), 0, (graphset.gridblock * 0.3), 0];
        y = [0, -(graphset.gridblock/2) + 10, 0, (graphset.gridblock/2) - 10];
        cgpolygon(x, y);
    elseif ismember(k, [4, 5]); % a circle
        x = [0, graphset.gridblock * 0.7];
        y = x;
        cgellipse(x(1), y(1), x(2), y(2), 'f');
    end;
    cgtrncol(sprite(k), graphset.trans);
end;


% return to screen
% -------------------------------------------------------------------------
cgsetsprite(0);


