function agent = runStep_bb(agent,errorRate)
%% Runs a single step of a given agent
% Vadim Bulitko
% Feb 16, 2016

%% Do nothing if we are already at the goal
if (agent.x == agent.goal.x && agent.y == agent.goal.y)
    return
end

learningOperator = round(agent.gene(1));
weightC = agent.gene(2);
weightH = agent.gene(3);
beamWidth = agent.gene(4);
markExpendable = round(agent.gene(5));
da = round(agent.gene(6));
%% Otherwise make a move
i = sub2ind(size(agent.map),agent.y,agent.x);

% Mark the visit
%agent.nVisits(i) = agent.nVisits(i) + 1;

% Generate the neighborhood
iN = i + agent.frontier;
availableN = ~agent.map(iN);
iN = iN(availableN);
gN = agent.g(availableN);
hN = getH(iN,agent.h,errorRate);
fN = gN + hN;

 % Check if we actually have any moves
if (isempty(fN))
    agent.energy=0;
    return
end


%wfN = weightC*gN + weightH*hN;
hI = getH(i,agent.h,errorRate);
hN0 = getH(iN,agent.h0,errorRate);%should be agent.h0


%da

fNMove = fN;
if (da)
    deltaN = abs(hN - hN0);
    minDeltaN = min(deltaN);
    minDeltaMask = abs(deltaN - minDeltaN) < 0.0001;
    fNMove(~minDeltaMask) = Inf;
end


% Select the move as arg min f (non-weighted)
[~,minIndex] = min(fNMove);
iNext = iN(minIndex);
agent.travelCost = agent.travelCost + gN(minIndex);


%beam width

[~, fNSortedI] = sort(fN, 'ascend');
fNSorted = weightC*gN(fNSortedI) + weightH*hN(fNSortedI);
if (beamWidth == 0)
     portionFNS = fNSorted(1);
else
     portionFNS = fNSorted(1:ceil(length(fNSorted)*beamWidth));
end

% Compute the new H
newH = hI;
switch round(learningOperator)
    case 1
        newH = max(hI,min(portionFNS));
    case 2
        newH = max(hI,mean(portionFNS));
    case 3
        newH = max(hI,median(portionFNS));
    case 4
        newH = max(hI,max(portionFNS));
end


% Set the new H
agent.h(i)=newH;% = setH(i,newH,agent.h,errorRate);

% Make the move
i = iNext;
%[agent.y, agent.x] = ind2sub(size(agent.map),i);

% Save the path
%agent.path = [agent.path iNext];
% Decrease the energy
agent.energy = agent.energy - gN(minIndex);
%agent.energyGradient = [agent.energyGradient agent.energy];
%mark expandable state

% learning magnitude
updateMagnitude = abs(hI - newH);
hUpdate =  updateMagnitude > 0.0001;

if (markExpendable && hUpdate && expendable(availableN))
        %agent.h = setH(i,100000000,agent.h,errorRate);
        agent.map(i) = true;
        
end


end
