function [subopt, sc, solved] = geneEvalLSS(gene,problem,maps,nProblems,cutoff,errorRate)
%% Evaluates a gene on nProblems
% Vadim Bulitko
% March 3, 2016

%% Data structures
subopt = NaN(1,nProblems);
sc = NaN(1,nProblems);
solved = false(1,nProblems);

%% Go through the problems
for n = 1:nProblems
    
    % Prepare the problem
    n
    p = problem(n);
    map = maps{p.mapInd}; %#ok<PFBNS>
    goal = p.goal;
    mapHeight = size(map,1);
    s2 = sqrt(2);
    neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
    gCost = [s2 1 s2 1 s2 1 s2 1];
    hs = p.optimalTravelCost;
    maxTravel = hs*cutoff;
    if (~isfield(p,'h0'))
        h = computeH0_mex(map,goal);
    else
        h = p.h0;
    end
    iStart = sub2ind(size(map),p.start.y,p.start.x);
    
    % Run the algorithm
    [solution, sc(n), solved(n)] =  ...
        LSSLRTA(p.start,map,goal,neighborhoodI,gCost,h,h,errorRate,maxTravel,gene);
    
    subopt(n) = solution / hs;
end

end
