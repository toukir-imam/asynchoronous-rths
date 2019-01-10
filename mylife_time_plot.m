%% Heuristic search A-life
% Vadim Bulitko
% September 9, 2015

close all
clear
clc
diary off
format short g

%% Preliminaries & control parameters
targetPopSize = 200;

maxWeightAmp = 10;
geneMin = [1,1, -maxWeightAmp];
geneMax = [1,1, maxWeightAmp];

marker = {'o','s','d','p'};

errorRate = 0;
maxSteps = 1000000;
maxTime = 30*60;
numSims = 1;
initialPopulationSize = 100;
%mutationRate = 0.01;
mutationRate = 5*ones(1,length(geneMax));
visualizeIntermediate = true;
saveVideo = false;

maxTrials = Inf;

nBins = 20;
binX = linspace(1,20,nBins);

rng('shuffle');

%scenarioName = 'scenarios/yngvi_5.mat';
%pNumber = 3;

%scenarioName = 'scenarios/mm_8_128.mat';
%pNumber = 2;

%scenarioName = 'scenarios/mm_8_128_Cropped_53.mat';
%pNumber = 1;

% scenarioName = 'scenarios/mini012_100.mat';
% pNumber = 4;

scenarioName = 'scenarios/mm_8_1024.mat';

%scenarioName = 'scenarios/MovingAI_342_493298.mat';
targetNumProblems = 100;

fPos = [100 150 1280 720];
fig = figure('Position',fPos);
cm = flipud(colormap(copper(100)));
colorbar off

[~, sName, ~] = fileparts(scenarioName);
diaryFileName = sprintf('logs/alife_%s.txt',sName);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('alife.m |');
disp(datetime);

diary off
diary on

ttt = tic;


%% Load scenario
load(scenarioName);
numProblems = length(problem);
[~, sName, ~] = fileparts(scenarioName);
fprintf('Scenario %s\n',scenarioName);

% Load prepared problems
load(sprintf('data/alifeProblemPrep_%s_%d.mat',sName,targetNumProblems),'pFound','pFoundH','pFoundHS');


%% Run simulations
simI = 0;

step_plot=[];
step_plot_w=[];
step_plot_subopt=[];


while (simI < numSims)
    simI = simI + 1;
    
    % Reset some data
    maxSubopt = 10;
    globalSuboptMin = Inf;
    globalSuboptGene = [];
    
    minSubopt = NaN(1,maxSteps);
    maxSuboptRec = NaN(1,maxSteps);
    distr = NaN(maxSteps,length(binX));
    dStep = 0;
    clear agent
    clf
    
    if (saveVideo)
       % videoW = VideoWriter(sprintf('~/tmp/alife_%s_%d.avi',sName,simI)); %#ok<TNMLP>
       % open(videoW);
    end
    
    %% Create the initial population
    id = 0;
    gene = NaN(1,length(geneMax));
    generation_plot=[];
    weightH_plot=[];
    subopt_plot=[];
    subopt_g_plot=[];
    for aI=1:initialPopulationSize
        
        % Pick a random problem from the prepared problems for this map and
        % load its h0
        pFoundI = randi(targetNumProblems);
        pNumber = pFound(pFoundI);
        p = problem(pNumber);
        map = maps{p.mapInd};
        
        %% To test HCDPS abstraction, uncomment the following
        % hcdpsAbstract(map,25);
        % return
        
        h0 = pFoundH{pFoundI};
        hsS0 = pFoundHS(pFoundI);
        
        % Generate a valid random genome
        for j = 1:length(geneMax)
            gene(j) = randr([geneMin(j),geneMax(j)]);
        end

        %gene = [2 64 1];
        
        % set initial generation to 1
        generation =1;
        % Create an agent with it
        id = id+1;
        agent{aI} = createAgent(p.start.x,p.start.y,map,p.goal,hsS0*maxSubopt,gene,id,h0,hsS0,generation); %#ok<SAGROW>
        generation_plot = [generation_plot, generation];
        weightH_plot = [weightH_plot, gene(3)];
        %fprintf('Created agent %d with problem %d\n',aI,pNumber);
    end
    %figure
    %subplot(1,2,1)
    %s = plot(generation_plot,weightH_plot,'ro');
    %drawnow
    %hold on
    
    %% Run the A-life simulation
    step = 0;
    lastVis = 0;
    tt = tic;
    while (toc(tt) < maxTime && ~isempty(agent))
        step = step + 1;
        
        % Run a single move for each agent
        dead = false(1,length(agent));
        for aI = 1:length(agent)
            agent{aI} = runStep(agent{aI},errorRate);
            dead(aI) = isDead(agent{aI},maxTrials,maxSubopt);
        end
        
        agent = agent(~dead);
        popChange = any(dead);
        
        % Process the ones that reached the goal
        newBorn = {};
        for aI = 1:length(agent)
            a = agent{aI};
            if (a.x == a.goal.x && a.y == a.goal.y)
                
                % compute suboptimality
                a.subopt = a.travelCost / a.hsS0;
                subopt_g_plot =[subopt_g_plot a.generation];
                subopt_plot = [subopt_plot a.subopt];
                a.numTrials = a.numTrials+1;
                
                fprintf('\tagent %d reached the goal | subopt %0.1f\n',a.id,a.subopt);
                
                % select a random problem for the off-spring
                pFoundI = randi(targetNumProblems);
                pNumber = pFound(pFoundI);
                p = problem(pNumber);
                map = maps{p.mapInd};
                h0 = pFoundH{pFoundI};
                hsS0 = pFoundHS(pFoundI);
                
                % create an off spring
                id = id + 1;
                gene = mutate(a.gene, mutationRate, geneMin, geneMax);
                newBorn{length(newBorn)+1} =...
                    createAgent(p.start.x,p.start.y,map,p.goal,hsS0*maxSubopt,gene,id,h0,hsS0,a.generation+1); %#ok<SAGROW>
                generation_plot = [generation_plot, a.generation+1];
                weightH_plot = [weightH_plot, gene(3)];
                %subplot(1,2,1)
                %s = plot(generation_plot,weightH_plot,'ro');
                %subplot(1,2,2)
                %s = plot(subopt_g_plot,subopt_plot,'bo');
                %hold on
                
                drawnow
                popChange = true;
                %fprintf('\t\t%d gave birth to %d | %s\n',a.id,id,gene2str(gene));
                
                % switch the parent to the same new problem as its child
                a.x = p.start.x;
                a.y = p.start.y;
                a.start.x = p.start.x;
                a.start.y = p.start.y;
                a.goal = p.goal;
                a.map = map;
                mapHeight = size(map,1);
                a.frontier = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
                a.energy = hsS0*maxSubopt;
                a.h = h0;
                a.hsS0 = hsS0;
                a.travelCost = 0;
                
                % update the parent
                agent{aI} = a;
            end
        end
        
        % Add the newborns to the population
        agent = [agent newBorn]; %#ok<AGROW>
        temp_subopt =[];
        temp_step = step*ones(1,length(agent));
        for i = 1:length(agent)
            temp_subopt = [temp_subopt agent{i}.gene(3)];
        end
        step_plot =[step_plot temp_step];
        step_plot_subopt = [step_plot_subopt temp_subopt];
        
        % Compute the min subopt in the population on this time step
        popSubopt = NaN(1,length(agent));
        for aI = 1:length(agent)
            popSubopt(aI) = agent{aI}.subopt;
            if (~isnan(agent{aI}.subopt) && (isnan(minSubopt(step)) || agent{aI}.subopt < minSubopt(step)))
                minSubopt(step) = agent{aI}.subopt;
                minSuboptGene = agent{aI}.gene;
            end
        end
        popSubopt = popSubopt(~isnan(popSubopt));
        
        % Adjust the lowest subopt ever achieved by the population
        if (minSubopt(step) < globalSuboptMin)
            globalSuboptMin = minSubopt(step);
            globalSuboptGene = minSuboptGene;
            %fprintf('---> new min subopt %0.1f with %s\n\n',globalSuboptMin,gene2str(globalSuboptGene));
        end
        
        % Put in competitive effects
        if (length(agent) > targetPopSize)
            fraction = targetPopSize / length(agent);
            if (~isempty(popSubopt))
                [sortedPopSubopt,~] = sort(popSubopt,'ascend');
                maxSubopt = sortedPopSubopt(ceil(fraction*length(sortedPopSubopt)));
                %fprintf('*** population of %d exceeded %d (portion %0.1f), setting maxSubopt to %0.1f\n\n',...
                %    length(agent),targetPopSize,fraction,maxSubopt);
            end
        end
        maxSuboptRec(step) = maxSubopt;
        
        if (popChange)
            fprintf('%d | %s | %d newborns; %d total\n\n',step,sec2str(toc(tt)),length(newBorn),length(agent));
        end
        
        % Log subopt distribution
        [y,~] = hist(popSubopt,binX);
        y = y/sum(y);
        if (all(~isnan(y)))
            dStep = dStep+1;
            distr(dStep,:) = y;
        end
        
        % Get the suboptimality of the oldest population member and its
        % gene
        if (~isempty(agent))
            agentNumTrials = NaN(1,length(agent));
            for aI = 1:length(agent)
                agentNumTrials(aI) = agent{aI}.numTrials;
            end
            [oldestTrials, oldestI] = max(agentNumTrials);
            oldestGene = agent{oldestI}.gene;
            oldestSubopt = agent{oldestI}.subopt;
        else
            oldestGene = [];
            oldestSubopt = NaN;
            oldestTrials = NaN;
        end
        
       

    end
end
%subplot(2,3,4)
hold off
plot(step_plot,step_plot_subopt,'g.');
xlabel('step');
ylabel('weight H')
title('suboptimality vs time')
hold on
drawnow
%% Wrap up

fprintf('\nTotal time %s\n',sec2str(toc(ttt)));
%diary off

