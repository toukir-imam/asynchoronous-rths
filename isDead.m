function dead = isDead(agent,maxTrials,maxSubopt)
%% Checks if an agent is dead
% Feb 16, 2016
% Vadim Bulitko

if (~isempty(agent.subopt))
    subopt = agent.subopt(end);
else
    subopt = NaN;
end

%dead = (agent.energy <= 0 || agent.numTrials > maxTrials || subopt > maxSubopt);

end
