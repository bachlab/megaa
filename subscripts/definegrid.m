function blockcentre = definegrid(graphset)
% This function defines grid block centres for a rotated grid for AAA_1
% centre coordinates of the white gridblocks are first defined in a regular
% (non-rotated) grid, then rotated
% Dominik R Bach 20.03.2013
% -------------------------------------------------------------------------
% last edited by Dominik R Bach 20.03.2013


blockx = graphset.gridblock * repmat((1:graphset.gridsize) - graphset.gridsize/2 - 1/2, graphset.gridsize, 1);  % x positions of blocks in a non-rotated grid
blocky = blockx';                                                                                               % y positions of blocks in a non-rotated grid
rotmat = [1/sqrt(2), -1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];                                                         % rotation matrix by pi/4 counterclockwise

for x = 1:graphset.gridsize
    for y = 1:graphset.gridsize
        blockcentre(x, y, 1:2) = rotmat * [blockx(y, x); blocky(y, x)];      % rotate grid
    end;
end;
       