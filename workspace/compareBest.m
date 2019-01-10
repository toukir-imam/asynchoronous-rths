function [ bestAgent ] = compareBest( agent,bestAgent )
% Toukir Imam (mdtoukir@ualberta.ca)

if agent.numTrials>bestAgent.byNumTrial.numTrials
    bestAgent.byNumTrial = agent;
end
if sum(agent.pastFoodValue(:)) >sum(bestAgent.byFoodValue.pastFoodValue(:))
    bestAgent.byFoodValue = agent;
end
if agent.finalFormNTrials>bestAgent.byFinalFormNTrials.finalFormNTrials 
    bestAgent.byFinalFormNTrials = agent;
end
if agent.tAStarSubopt >bestAgent.byAStarSubopt.tAStarSubopt
    bestAgent.byAStarSubopt = agent;
end

end

