%Author : Toukir (mdtoukir@ualberta.ca)

%clear screen and variables
clear;
clc;
format long
%inputs to the script 
worldName = 'worlds/world1.mat';
scenarioName = 'scenarios/uniMap_50_500_wh0.';
initialPopulation = 1;
showMap =false;
difficutyLevel = .3;
energyMultiplier = 4;
baseEnergy = 100;
maxAllowedPopulation =500;
minReqEnergy = 0;

%for adding noise
errorRate =0;

%load scenario

load(scenarioName);
%gene stuff (probably should be input)

maxWeightAmp = 10;
geneMin = [1, -maxWeightAmp, -maxWeightAmp,0,0,0];
geneMax = [4, maxWeightAmp, maxWeightAmp,1,1,1];
mutationRate =0*(ones(size(geneMax)));
noMutation = zeros(size(geneMax));
%energy multiplier multiplies the h* to set the energy

%load the world
load (worldName);

%create the agents
%unpack the worldAL struct
%eateries = worldAL(1).eateries;
%map = worldAL(1).map;
%optMatrix = worldAL(1).optMatrix;


%logging population min max and avg subopt
minArray =[];
maxArray =[];
avgArray=[];

%finding best gene
bestAvgSub = 0;
bestGene =NaN;
%video
%videoW = VideoWriter('test.avi');
%open(videoW);
%fig =figure('Visible','off');
load('scenarios/yngvi_5.mat');
%load('scenarios/uniMap_50_500_wh0.mat');
problemId = 1;
map =maps{problem(problemId).mapInd};
start = problem(problemId).start;
goal = problem(problemId).goal;
h0 = problem(problemId).h0;
for i =1:initialPopulation
    
    %energy of 
    %energy = optMatrix(startI,goalI)* energyMultiplier;
    energy = baseEnergy*energyMultiplier;
    
    %korf
    gene = [2 0];
    %gene =[1.88 ,1 ,1,0,0,.45];
    %gene = [ 1.2147  ,     112.82    ,   68.217   ,   0.40904, 0.10794 ,     0.55694];
    
    %agent Id
    id = i;
    
    hStar = h0;
    %agents{i} = createOffspring(id,worldAL,gene,mutationRate,geneMin,geneMax,energy);
    %agents{i}.gene
    %old style
    %agents{i} = createOffspring2(id,problem,maps,NaN,mutationRate,geneMin,geneMax,energy);
    agents{i} = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,1);
end

%start main loop
% count step
step = 0;

while ~isempty(agents) 
    step =step+1;
    %size(agents)
    if mod(step,1000)==0
        energyMultiplier = energyMultiplier-difficutyLevel
        length(agents)
    end
    dead = false(1,length(agents));
    for aI =1:length(agents)
        
        agents{aI} = runStep4(agents{aI},errorRate);
        dead(aI) = isDead2(agents{aI},0,NaN);
        
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
    for aI =1:length(agents)
        
        if ((agents{aI}.goal.x == agents{aI}.x) && (agents{aI}.goal.y == agents{aI}.y))
            s = 'here';
            x = agents{aI}.travelCost/problem(problemId).optimalTravelCost
            %create offspring
            
            
            %agent Id
            id = id+1;
            
            %energy
            energy = baseEnergy*energyMultiplier;

            newBorn{length(newBorn)+1} = createOffspring(id,worldAL,agents{aI}.gene,mutationRate,geneMin,geneMax,energy);
            %newBorn{length(newBorn)+1} = createOffspring2(id,problem,maps,agents{aI}.gene,mutationRate,geneMin,geneMax,energy);
            
            
            %for the parent, assign a new goal, remember suboptimality
            
            oldTrial = agents{aI}.numTrials;
            subopt = agents{aI}.travelCost/agents{aI}.hsS0;
            oldsubopt = agents{aI}.subopt;
            
            agents{aI} = createOffspring2(agents{aI}.id,problem,maps,agents{aI}.gene,noMutation,geneMin,geneMax,energy);
            
            agents{aI}.subopt = [oldsubopt subopt];
            agents{aI}.numTrials = oldTrial+1;
            
            
        end
    end

    agents = [agents newBorn];
    
    % find population min,max,and average, suboptimality
    popMinSubopt =Inf;
    popMaxSubopt =0;
    popSumSubopt =0;
    numAdults = 0;
    for i =1:length(agents)
        if agents{i}.numTrials ~=0
            numAdults=numAdults+1;
            popSumSubopt = popSumSubopt+mean(agents{i}.subopt);
            if popMinSubopt >mean(agents{i}.subopt)
                
                
                popMinSubopt = mean(agents{i}.subopt);
            end
            if popMaxSubopt <mean(agents{i}.subopt)
                popMaxSubopt = mean(agents{i}.subopt);
            end
            
        end
    end
  
    
    
    if numAdults ~=0
        popAvgSubopt = popSumSubopt/numAdults;
    else
        popAvgSubopt = 0;
        end
    
    %log min max and avg suboptimality
    minArray = [minArray popMinSubopt];
    maxArray = [maxArray popMaxSubopt];
    avgArray = [avgArray popAvgSubopt]; 
    
    %population and adults
    population(step) = length(agents);
    adults(step) = numAdults;
end

%%visualise
x =1:step;
subplot(2,3,1);
plot(x,minArray,'r');
xlabel('# Step');
ylabel('Min Population Suboptimality')
subplot(2,3,2);
plot(x,maxArray,'b');
xlabel('# Step');
ylabel('Max Population Suboptimality')
subplot(2,3,3);
plot(x,avgArray,'g');
xlabel('# Step');
ylabel('Mean Population Suboptimality')
subplot(2,3,4);
plot(x,population,'r');
hold on;
plot(x,adults,'b');

xlabel('# Step');
ylabel('Population');
legend('Total population','Adults');
%subplot(2,3,5);

%xlabel('# Step');
%ylabel('# Adults')
%close(videoW);
drawnow
othergene = [bestGene(3) bestGene(2) bestGene(6) bestGene(5) 0 bestGene(1) bestGene(4) 0]





 