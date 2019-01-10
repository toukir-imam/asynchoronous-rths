function agent = createAgent(x,y,map,goal,energy,gene,id,h0,hsS0,aStarDifficulty,generation)
% createAgent

agent.isTraceGene =false;
%% Set dummy to false
agent.isDummy =false;

%% Set the start coordinates
agent.x = x;
agent.y = y;

%% Remember the start state
agent.start.x = x;
agent.start.y = y;

%% Set the goal
agent.goal = goal;

%% Remember the map
agent.map = map;

%% Define the neighborhood
mapHeight = size(map,1);
s2 = sqrt(2);
agent.frontier = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
agent.g = [s2 1 s2 1 s2 1 s2 1];

%% Store h0
agent.h = h0;

%% Store h0 for real
agent.h0 =h0;
%% Store h*(s0)
agent.hsS0 = hsS0;
%% Store aStarDifficulty
agent.aStarDifficulty=aStarDifficulty;

%% Reset all statistics
agent.subopt = [];
agent.travelCost = 0;
agent.numTrials = 0;
agent.energy = energy;
agent.id = id;

%% Final form 
agent.inFinalForm =false;
agent.finalFormNTrials =0;

%% Set the genome
agent.gene = gene;

%% Set the generation
agent.generation = generation;
agent.path = [];

%% GAT
agent.tTotal = 0;
agent.GATs = [];
agent.moveTimes=[];

%% Store old problems and old paths
agent.finishedProblems =[];
agent.path =[];
%agent.paths={};

%% Store old EnergyG Gradients
agent.energyGradient =[];
%agent.finishedEnergyGradient ={};
agent.pastFoodValue = zeros(1,500);
%agent.pastEnergy = zeros(1,500);
%agent.tAStarDifficulty =0;
agent.tAStarSubopt = 0;
end
