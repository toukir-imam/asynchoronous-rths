function [ p2 ] = findPair( agent,agents )

p2 = agent; %fall back to agent if noone alive
closestFoodValue = Inf;
for i =1:length(agents)
    if ~agents(i).isDummy
        if agent.id ~= agents(i).id && (abs(sum(agents(i).pastFoodValue(:))-sum(agent.pastFoodValue(:))) < closestFoodValue)
            p2 = agents(i);
            closestFoodValue=abs(sum(agents(i).pastFoodValue(:))-sum(agent.pastFoodValue(:)));
            
        end
    end


end


