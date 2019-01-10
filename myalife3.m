%Author : Toukir (mdtoukir@ualberta.ca)

%clear screen and variables
clear;
clc;
format long

%inputs to the script 
%worldName = 'worlds/world1.mat';
scenarioName = 'scenarios/mm_8_1024';
initialPopulation = 1;
showMap =false;
difficutyLevel = .3;
energyMultiplier = 4;
baseEnergy = 100000;
maxAllowedPopulation =500;
minReqEnergy = 0;

%for adding noise
errorRate =0;

%load scenario

load(scenarioName);
%gene stuff (probably should be input)

maxWeightAmp = 10;
geneMin = [1, -maxWeightAmp, -maxWeightAmp,0,0,0,100,0,0,0];
geneMax = [4, maxWeightAmp, maxWeightAmp,1,1,1,0,1,1,1];
mutationRate =0*(ones(size(geneMax)));
noMutation = zeros(size(geneMax));
%energy multiplier multiplies the h* to set the energy

%load the world
%load (worldName);

%create the agents
%unpack the worldAL struct
%eateries = worldAL(1).eateries;
%map = worldAL(1).map;
%optMatrix = worldAL(1).optMatrix;


%logging population min max and avg subopt
minArray =[];
maxArray =[];
avgArray=[];
avgDArray =[];

%finding best gene
bestAvgSub = 0;
bestGene =NaN;
%video
%videoW = VideoWriter('test.avi');
%open(videoW);
fig =figure('Visible','off');
%load('scenarios/yngvi_5.mat');
load(scenarioName);
problemId = 1;
map =maps{problem(problemId).mapInd};
start = problem(problemId).start;
goal = problem(problemId).goal;
h0 = problem(problemId).h0;
otc = problem(problemId).optimalTravelCost;
gats=[];
movetimes=[];
subopts =[];
for d=200:200
d
for i =1:initialPopulation
    
    %energy of 
    %energy = optMatrix(startI,goalI)* energyMultiplier;
    energy = baseEnergy*energyMultiplier;
    
    %korf
    gene = [1,1,1,0,0,0,d,.5,.5,.5];
    %gene =[1.88 ,1 ,1,0,0,.45];
    %gene = [ 1.2147  ,     112.82    ,   68.217   ,   0.40904, 0.10794 ,     0.55694];
    
    %agent Id
    id = i;
    
    hStar = h0;
    %agents{i} = createOffspring(id,worldAL,gene,mutationRate,geneMin,geneMax,energy);
    %agents{i}.gene
    %old style
    %agents{i} = createOffspring3(id,problem,maps,NaN,mutationRate,geneMin,geneMax,energy);
    agents{i} = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,0,1);
end

%start main loop
% count step
step = 0;

while ~isempty(agents) 
    step =step+1;
    %size(agents)
    if mod(step,1000)==0
        energyMultiplier = energyMultiplier-difficutyLevel;
        length(agents);
    end
    dead = false(1,length(agents));
    for aI =1:length(agents)
        tstart = tic;
        agents{aI} = runStep4(agents{aI},errorRate);
        te = toc(tstart);
        agents{aI}.tTotal=agents{aI}.tTotal+te;
        %dead(aI) = isDead2(agents{aI},0,NaN);
        
    end
    
    %remove deads
    lastagents = agents(dead);
    for i =1: length(lastagents)
        if lastagents{i}.numTrials>bestAvgSub
            bestAvgSub = lastagents{i}.numTrials
            bestGene = lastagents{i}.gene
        end
    end
    agents = agents(~dead);
    
    %cull population until it comes below max population
    minReqEnergy =10;
    while length(agents) > maxAllowedPopulation
        dead = false(1,length(agents));
        for aI =1:length(agents)
            dead(aI) = isDead2(agents{aI},minReqEnergy,NaN);
        
        end
        minReqEnergy = minReqEnergy+10;
        lastagents = agents(dead);
        for i =1: length(lastagents)
            if lastagents{i}.numTrials>bestAvgSub
                bestAvgSub = lastagents{i}.numTrials
                bestGene = lastagents{i}.gene
            end
        end
        agents = agents(~dead);
    end
    
    %print the last persons standing
    if isempty(agents)
        
    end
    %draw the map
    if (showMap)
        xh = agents{1}.h -h0;
        %xh = zeros(size(map))
        displayMap(map,xh,[0,0,1],false);
        for i =1:length(agents)
             drawAgent(agents{i});
             [agents{i}.x,agents{i}.y];
             
             [ agents{i}.goal.x,agents{i}.goal.y];
             
        end
        drawFood(start.x,start.y);
        drawFood(goal.x,goal.y);
    

        %for i =1:length(eateries)
        %    [y, x] = ind2sub(size(map),eateries(i));
        %    drawFood(x,y);
        %end
        %writeVideo(videoW,getframe(fig));
        drawnow
    end
    
    
    %process the ones that reached the goal
    newBorn = {};
        
        if ((agents{1}.goal.x == agents{1}.x) && (agents{1}.goal.y == agents{1}.y))
            s = 'here'
            agents{1}.tTotal
            gats =[gats agents{1}.tTotal];
            movetime = agents{1}.tTotal/agents{1}.travelCost;
            movetimes = [movetimes movetime];
            subopt = agents{1}.travelCost/otc;
            subopts =  [subopts subopt];
            agents={};
            
            
           
            
            
        end
end

end

x =1:d;
subplot(1,3,1);
plot(x,gats,'r');
xlabel('d');
ylabel('gat')


subplot(1,3,2);
plot(x,movetimes,'b');
xlabel('d');
ylabel('movetime')


subplot(1,3,3);
plot(x,subopts,'g');
xlabel('d');
ylabel('suboptimality')

