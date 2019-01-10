function [bestAgent] = findBestAgent(agents,bestAgent)
%Author:  Toukir Imam (mdtoukir@ualberta.ca)
%finds the best agent based on best Value
%This function will morph into finding best agent in all criterias and
%returning a struct

%% By Num Trial
if isfield(bestAgent,'byNumTrial')
    bestNumTrial = bestAgent.byNumTrial.numTrials;
else
    bestNumTrial = 0;
end
for i =1: length(agents)
    if agents{i}.numTrials>bestNumTrial
        bestAgent.byNumTrial = agents{i};
        bestNumTrial = agents{i}.numTrials;
    end
end

%% By final Num Trial
if isfield(bestAgent,'byFinalFormNTrials')
    finalFormNTrials = bestAgent.byFinalFormNTrials.finalFormNTrials;
else
    finalFormNTrials = 0;
end
for i =1: length(agents)
    if agents{i}.finalFormNTrials>finalFormNTrials
        bestAgent.byFinalFormNTrials = agents{i};
        finalFormNTrials = agents{i}.finalFormNTrials;
    end
end

%% By OTC
if isfield(bestAgent,'byOTC')
    bestValue = bestAgent.byFoodValue.bestValue;
else
    bestValue =-1;
end
for i =1: length(agents)
    tFoodValue = sum(agents{i}.pastFoodValue);
    if  tFoodValue> bestValue
        bestValue = tFoodValue;
        bestAgent.byFoodValue = agents{i};
        bestAgent.byFoodValue.bestValue = bestValue;
    end
end

%% By A* difficulty
bestDifficulty = bestAgent.byAStarDifficulty.tAStarDifficulty;
for i =1:length(agents)
    if ~agents{i}.isDummy 
        if agents{i}.tAStarDifficulty > bestDifficulty
            bestDifficulty = agents{i}.tAStarDifficulty;
            bestAgent.byAStarDifficulty = agents{i};
        end
   end
end
        %% By LRTAStarDifficulty
%elseif strcmp(policy,'LRTAStarDifficulty')
%    for i =1: length(agents)
%        fproblems = agents{i}.finishedProblems;
%        totalOTC = 0;
%        for j =1:length(fproblems)
%            totalOTC = totalOTC+ problem(fproblems(j)).optimalTravelCost*problem(fproblems(j)).LRTAStarDifficulty;
%        end
%        if totalOTC > bestValue
%            bestValue = totalOTC;
%            bestAgent = agents{i};
%            bestAgent.bestValue = bestValue
%        end
%    end
%else
%    s='motherfucker'
%    alsdkf
%end
end