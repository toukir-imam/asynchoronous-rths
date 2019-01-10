function [aSD, difficulty, pathFound] = aStarDistance(map,start,goal)
% aStarDistance
% computes A* distance (i.e., optimal distance) from (x,y) to goal
% Also computes the difficulty

% If the problem is unsolvable then
% aSD = -1
% difficulty <= 0

%astarAgent = createAgentOLD(x,y,map,goal);
startI = sub2ind(size(map),start.y,start.x);
goalI = sub2ind(size(map),goal.y,goal.x);
mapHeight = size(map,1);
s2 = sqrt(2);
frontier = int32([-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight]);
g = [s2 1 s2 1 s2 1 s2 1];

[path,numExpanded,traveled,numMoves] = mexAstar_Vadim(map,startI,goalI,frontier,g);
aSD = traveled;

% Need to deal with an unsolvable problem

if (nargout > 1)
    difficulty = numExpanded / numMoves;
end
pathFound =1;

end
