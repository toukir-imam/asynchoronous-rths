function [ newAgent ] = reAssign( agent,maps,problem,energyMultiplier,attr)
% Toukir Imam(mdtoukir@ualberta.ca)
    zeroGene = zeros(size(agent.gene));
    
    newAgent = createOffspring6( agent.id,problem,maps,agent.gene,zeroGene,zeroGene,zeroGene,energyMultiplier,attr);
    
    %%carry over energy
    %%newAgent.energy = newAgent.energy+agent.energy;
    
    %% Astar diffiulty
    %newAgent.tAStarDifficulty = newAgent.tAStarDifficulty + agent.aStarDifficulty;
    newAgent.tAStarSubopt = agent.tAStarSubopt + (agent.hsS0*agent.aStarDifficulty)/agent.travelCost;
    %% start counting trials in the final Form
    if agent.inFinalForm
        newAgent.finalFormNTrials =agent.finalFormNTrials +1;
    end
    %newAgent.spareEnergy = agent.spareEnergy + agent.
    newAgent.numTrials = agent.numTrials+1;

    for i =1:agent.numTrials
        newAgent.pastFoodValue(i) = agent.pastFoodValue(i);
    end
    newAgent.pastFoodValue(newAgent.numTrials) = agent.hsS0*agent.aStarDifficulty;

    
    if agent.isTraceGene
        newAgent.isTraceGene = true;
        fprintf('trace gene is now solving a problem with OTC %5.3e and has energy %5.3e \n',newAgent.hsS0,newAgent.energy);
    end
end

