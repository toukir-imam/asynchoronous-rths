function [subopt, sc, solved,nTouched,nTouchedH,tTouched,tTouchedH] = geneEval(gene,problem,maps,nProblems,cutoff,errorRate)
%% Evaluates a gene on nProblems
% Vadim Bulitko
% March 3, 2016

%% Data structures
subopt = NaN(1,nProblems);
sc = NaN(1,nProblems);
solved = false(1,nProblems);
nTouched = NaN(1,nProblems);
nTouchedH =NaN(1,nProblems);
%timeList = NaN(1,nProblems);
tTouched =0;
tTouchedH =0;
%% Go through the problems
parfor n = 1:nProblems
    
    % Prepare the problem
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
    %tstart =tic;
    [solution, sc(n), solved(n),nTouched(n),nTouchedH(n)] =  ...
        uLRTA_mex(iStart,map,goal,neighborhoodI,gCost,h,h,errorRate,maxTravel,gene);
    %tend = toc(tstart);
    %timeList(n) = tend;
    tTouched = tTouched +nTouched(n);
    tTouchedH = tTouchedH +nTouchedH(n);
    nTouched(n) = nTouched(n)/p.optimalPathLength;
    nTouchedH(n) = nTouchedH(n)/p.optimalPathLength;
    
    subopt(n) = solution / hs;
end

end
