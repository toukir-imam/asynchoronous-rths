function dead = isDead2(agent,minEnergy,maxGat)
%% Checks if an agent is dead
% Feb 16, 2016
% Toukir Imam
if ~isnan(maxGat)
    dead = agent.tTotal>=maxGat;
    return
end
    
dead =agent.energy <= minEnergy ;

end
