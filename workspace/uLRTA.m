function [distTraveled, meanScrubbing, solved,nTouched,nTouchedH] = uLRTA(i,map,goal,neighborhoodI,gCost,h0,h,errorRate,cutOff,gene)
%% Returns the expected distance traveled to a goal state
%% Universal LRTA*, incorporates elements from wLRTA*, wbLRTA*, LRTA*-E, daLRTA* and SLA*T
% Vadim Bulitko
% February 25, 2016

%% Preliminaries
% Unpack the gene                                          
%w = gene(1);
%wc = gene(2);
%da = round(gene(3));
%markExpendable = round(gene(4));
%backtrack = round(gene(5));
%learningOperator = round(gene(6));
%beamWidth = gene(7);
%learningQuota = gene(8);

learningOperator = round(gene(1));
weightC = gene(2);
weightH = gene(3);
beamWidth = gene(4);
markExpendable = round(gene(5));
da = round(gene(6));
learningRate = gene(7);
% Set initial parameters
mapSize = size(map);
iGoal = sub2ind(mapSize,goal.y,goal.x);
%iPrevious = ones(1,0); % = []
%coder.varsize('iPrevious',[1, Inf], [0, 1]);
%iPreviousCost = ones(1,0);   % = []                   
%coder.varsize('iPreviousCost',[1, Inf], [0, 1]);
distTraveled = 0;
%h0 = h;
nVisits = zeros(mapSize);
totalLearning = 0;
nTouched = 0;
nTouchedH = 0;
% As long as we haven't reached the goal and haven't run out of quota
while (i ~= iGoal && distTraveled < cutOff)

    % Mark the visit
    nVisits(i) = nVisits(i) + 1;
    
    % Generate the neighborhood
    iN = i + neighborhoodI;
    availableN = ~map(iN);
    iN = iN(availableN);
    gN = gCost(availableN);
    hN = getH(iN,h,errorRate);
    hI = getH(i,h,errorRate);
    
    nTouched = nTouched + size(iN,2);
    nTouchedH = nTouchedH + size(iN,2);

    fN = gN + hN;
    
    % Check if we actually have any moves
    if (isempty(fN))
        nVisitsNZ = nVisits(nVisits > 0);
        meanScrubbing = mean(nVisitsNZ);
        solved = false;
        distTraveled = cutOff + min(gCost);
        s ='i dont think this is supposed to happen';
        return
    end
            
    % Mask out all neighbors with non-minimal deltas
    fNMove = fN;
    if (da)
        hN0 = getH(iN,h0,errorRate);
        deltaN = abs(hN - hN0);
        minDeltaN = min(deltaN);
        minDeltaMask = abs(deltaN - minDeltaN) < 0.0001;
        nTouched = nTouched + size(iN,2);
        nTouchedH = nTouchedH + size(iN,2);
        fNMove(~minDeltaMask) = Inf;
    end
    
    % Select the move as arg min f
    [~,minIndex] = min(fNMove);
    iNext = iN(minIndex);
    iNextDist = gN(minIndex);

    % Take a subset of the neighborhood as determined by the beam width
    [~, fNSortedI] = sort(fN, 'ascend');
    fNSorted = weightC*gN(fNSortedI) + weightH*hN(fNSortedI);
    if (beamWidth == 0)
        portionFNS = fNSorted(1);
    else
        portionFNS = fNSorted(1:ceil(length(fNSorted)*beamWidth));
    end
    
    % Update the heuristic
    newH = hI;
    switch (learningOperator)
        case 1
            newH = max(hI,min(portionFNS));
        case 2
            newH = max(hI,mean(portionFNS));
        case 3
            newH = max(hI,median(portionFNS));
        case 4
            newH = max(hI,max(portionFNS));
    end
    
    updateMagnitude = abs(hI - newH);
    hUpdate =  updateMagnitude > 0.0001;
    totalLearning = totalLearning + updateMagnitude;
    newH = learningRate*newH + (1-learningRate)*hI;
    h = setH(i,newH,h,errorRate);
    nTouchedH = nTouchedH+1;
    % Remove the current state from the search graph if it is expendable AND we updated its heuristic
    if (markExpendable && hUpdate)
        nTouched = nTouched + size(iN,2);
        if (expendable(availableN))
            map(i) = true;
            nTouchedH =nTouchedH+1;
        end
    end
    
    % Move
%     %iOld = i;
%     if (backtrack && hUpdate && totalLearning > learningQuota)
%         % Backtrack
%         if (~isempty(iPrevious))
%             i = iPrevious(end);
%             iNextDist = iPreviousCost(end);
%             iPrevious = iPrevious(1:end-1);
%             iPreviousCost = iPreviousCost(1:end-1);
%         end
%     else
%         % Go forward
%         iPrevious = [iPrevious i]; %#ok<AGROW>
%         iPreviousCost = [iPreviousCost iNextDist];  %#ok<AGROW>
%         i = iNext;
%     end
    i = iNext;
    
    distTraveled = distTraveled + iNextDist;

end

%% Compute scrubbing
nVisitsNZ = nVisits(nVisits > 0);
meanScrubbing = mean(nVisitsNZ);
solved = (i==iGoal && distTraveled<=cutOff);


end

