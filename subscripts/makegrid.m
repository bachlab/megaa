function makegrid(graphset)
% This function creates a diamond-shaped 2 x 2  grid for AAA_1 
% structure: (1) draw black background rectancgle (2) draw white gridblocks
% corner offsets of gridblocks are added to block centres defined in
% definegrid.m
%
% Dominik R Bach 01.03.2013
% -------------------------------------------------------------------------
% last edited by Dominik R Bach 02.04.2013


% constants 
% -------------------------------------------------------------------------
gridx = round([graphset.griddiag/2, 0, -graphset.griddiag/2, 0]); % grid x corners
gridy = round([0, graphset.griddiag/2, 0, -graphset.griddiag/2]); % grid y corners
blockxy = 1/sqrt(2) * graphset.gridblock - graphset.gridline; % foreground block size

% prepare sprite
% -------------------------------------------------------------------------
cgmakesprite(graphset.gridsprite, graphset.griddiag, graphset.griddiag, graphset.transcol); 
cgsetsprite(graphset.gridsprite); 

% draw black grid background
% -------------------------------------------------------------------------
cgpencol(graphset.bckgrnd);
cgpolygon(gridx, gridy);

% draw white grid blocks
% -------------------------------------------------------------------------
for xblock = 1:graphset.gridsize;
    for yblock = 1:graphset.gridsize;
        cgpencol(graphset.gridcol);
        if xblock == 1 && yblock == 1
            cgpencol(graphset.safecol);
        end;
         blockcornersx = graphset.blockcentre(xblock, yblock, 1) + [blockxy, 0, -blockxy, 0];   % define x coordinates of grid block corners
         blockcornersy = graphset.blockcentre(xblock, yblock, 2) + [0, blockxy, 0, -blockxy];   % define y coordinates of grid block corners
         cgpolygon(round(blockcornersx), round(blockcornersy));
    end;     
end; 

% make transparent
% -------------------------------------------------------------------------
cgtrncol(graphset.gridsprite, graphset.trans);

% return to screen
% -------------------------------------------------------------------------
cgsetsprite(0);


