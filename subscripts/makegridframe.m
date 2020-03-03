function makegridframe(framecol, graphset)
% This function draws the grid on a frame
%
% Dominik R Bach 20.03.2013
% -------------------------------------------------------------------------
% last edited by Dominik R Bach 20.03.2013


% constants 
% -------------------------------------------------------------------------
framesize = graphset.gridblock * sqrt(2 * (graphset.gridsize + 1).^2);  % add 1/2 gridblock frame
gridx = round([framesize/2, 0, -framesize/2, 0]); % grid x corners
gridy = round([0, framesize/2, 0, -framesize/2]); % grid y corners

% prepare sprite
% -------------------------------------------------------------------------
cgmakesprite(graphset.framesprite, framesize, framesize, graphset.transcol); 
cgsetsprite(graphset.framesprite); 

% draw coloured grid background
% -------------------------------------------------------------------------
cgpencol(framecol);
cgpolygon(gridx, gridy);

% draw grid on frame
% -------------------------------------------------------------------------
cgdrawsprite(graphset.gridsprite, 0, 0);

% make transparent
% -------------------------------------------------------------------------
cgtrncol(graphset.framesprite, graphset.trans);

% return to screen
% -------------------------------------------------------------------------
cgsetsprite(0);


