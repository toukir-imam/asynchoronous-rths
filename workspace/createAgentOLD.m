function agent = createAgent(x,y,map,goal,computeH)
% createAgent
% creates an agent, pre-computes the neighborhood, the g values and, if requested, the h value

%% Preliminaries
if (nargin < 5)
    computeH = true;
end

%% Set the start coordinates
agent.x = x;
agent.y = y;

%% Set the goal
agent.goal = goal;

%% Define the neighborhood
dc = sqrt(2);
sc = 1;
neighborhood = '8';
mapHeight = size(map,1);

switch (neighborhood)
    case '8'
        agent.frontier =...
            [-mapHeight-1 -mapHeight -mapHeight+1 -1 1 mapHeight-1 mapHeight mapHeight+1];
        agent.g = [dc sc dc sc sc dc sc dc];
        
    case '4'
        agent.frontier = [-mapHeight -1 1 mapHeight];
        agent.g = [sc sc sc sc];
end

%% Pre-compute h : heuristic distance to goal for all states
agent.h = NaN(size(map));
coder.varsize('agent.h',[],[1 1]);
if (computeH)
    for y=1:size(map,1)
        for x=1:size(map,2)
            agent.h(y,x) = distance(x,y,goal.x,goal.y);
        end
    end
end

agent.changedH = false(size(map));
coder.varsize('agent.changedH',[],[1 1]);

%% Reset all statistics
agent.travelCost = 0;
agent.planningTime = 0;
agent.statesTouched = 0;
agent.statesExpanded = 0;
agent.numMoves = 0;
agent.scrubbingMeter = 0;
agent.lastVisit = nan(size(map));
agent.flow = 0;
agent.usedFlow = false;
agent.Return = 0;

%agent.maxMoves = 5000;
%agent.history = zeros(1,agent.maxMoves);
%coder.varsize('agent.history',[],[0 1]);

end
