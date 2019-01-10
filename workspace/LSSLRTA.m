function [distTraveled, meanScrubbing, solved] = LSSLRTA(start,map,goal,neighborhoodI,gCost,...
    h0,h,errorRate,cutOff,gene)
%% Returns the expected distance traveled to a goal state
%% Local search space LRTA*
% Toukir Imam (mdtoukir@ualberta.ca)
%

%% Preliminaries
%[y,x] = ind2sub(size(map),i);
energy = 0;
hsS0=0;
generation = 1;
id = 1;
% Create the agent
agent = createAgent(start.x,start.y,map,goal,energy,gene,id,h,hsS0,generation);

%% As long as we haven't reached the goal and haven't run out of quota

while (agent.x ~= agent.goal.x && agent.y ~=agent.goal.y)
    [agent.x agent.y]
    [agent.goal.x agent.goal.y]
    agent = runStep4(agent,errorRate);

end

end

