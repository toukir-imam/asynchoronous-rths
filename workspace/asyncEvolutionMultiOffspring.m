function [ step, minArray,maxArray,avgArray,avgGatArray,avgMoveTimeArray,population,...
    adults,bestGene ] = asyncEvolutionMultiOffspring( maps,problem,initialPopulation,...
    maxAllowedPopulation,baseEnergy,energyMultiplier,difficutyLevel,eraLength )
%Asynchronous Evolution
%Author : Toukir Imam (mdtoukir@ualberta.ca)

    %inputs to the script 
    %worldName = 'worlds/world1.mat';
    %scenarioName = 'scenarios/mm_8_1024';
    %initialPopulation = 1;
    %showMap =false;
    %difficutyLevel = .3;
    %energyMultiplier = 4;
    %baseEnergy = 100000;
    %maxAllowedPopulation =500;
    %minReqEnergy = 0;

    %for adding noise
    errorRate =0;
    
    %gene stuff (probably should be input)
    maxWeightAmp = 50;
    geneMin = [1, 0, 0,0,0,0];
    geneMax = [4, maxWeightAmp, maxWeightAmp,1,1,1];
    mutationRate1 = [.3,.6,.6,.2,.2,.2];
    mutationRate2 = [.1,.1,.1,.06,.06,.06];
    noMutation = zeros(size(geneMax));

    %logging population min max and avg subopt
    
    maxPossibleStep = eraLength*ceil(energyMultiplier/difficutyLevel);
    minArray =zeros(1,maxPossibleStep);
    maxArray =zeros(1,maxPossibleStep);
    avgArray=zeros(1,maxPossibleStep);
    %avgGatArray=zeros(maxPossibleStep);
    %avgMoveTimeArray=zeros(maxPossibleStep);
    population = zeros(1,maxPossibleStep);
    adults = zeros(1,maxPossibleStep);
    
    %avgDArray =[];
    %gats=[];
    %movetimes=[];
    %subopts =[];

    %finding best gene
    %bestAvgSub = 0;
    %bestGene =NaN;
    bestNumTrials =0;
    
    %load Scenario
    %load(scenarioName);
    agents = cell(0);
    for i =1:initialPopulation

        %energy of Foods
        energy = baseEnergy*energyMultiplier;
        %energy = NaN; 

        %korf
        %gene = [1,1,1,0,0,0];
        
        %agent Id
        id = i;
        
        %create Agent

        agents{i} = createOffspring3(id,problem,maps,NaN,NaN,geneMin,geneMax,energy);
        
        %old style
        %agents{i} = createOffspring(id,worldAL,gene,mutationRate,geneMin,geneMax,energy);
        %agents{i} = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,1);
    end

    %start main loop
    % count step
    step = 0;

    while ~isempty(agents) 
        step =step+1;
        
        %Make environement harder every 1000 steps
        if mod(step,eraLength)==0
            energyMultiplier = energyMultiplier-difficutyLevel;
            fprintf('\npopulation = %d ; energy Multiplier =  %1.2f\n\n',length(agents),energyMultiplier);
        end
        
        %find dead ones
        %[agents, dead] =runStepAll(agents,errorRate);
        dead = false(1,length(agents));
        
        for aI =1:length(agents)
            %tstart = tic;
           agents{aI} = runStep(agents{aI},errorRate);
            %te = toc(tstart);
            %agents{aI}.tTotal=agents{aI}.tTotal+te;
            dead(aI) = isDead2(agents{aI},0,NaN);
        end

        %remove deads and find best agent so far
        lastagents = agents(dead);
        for i =1: length(lastagents)
            if lastagents{i}.numTrials>bestNumTrials
                bestNumTrials = lastagents{i}.numTrials;
                bestGene = lastagents{i}.gene;
                bestSubopt = mean(lastagents{i}.subopt);
                fprintf('best num solved = %d best mean subopt = %.3f\n',bestNumTrials,bestSubopt);
                fprintf('best gene = [');
                fprintf (' %f ' ,bestGene');
                fprintf(']\n');
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
                if lastagents{i}.numTrials>bestNumTrials
                    bestNumTrials = lastagents{i}.numTrials;
                    bestGene = lastagents{i}.gene;
                    bestSubopt = mean(lastagents{i}.subopt);
                    fprintf('best num solved = %d best mean subopt = %.3f\n',bestNumTrials,bestSubopt);
                    fprintf('best gene = [');
                    fprintf (' %f ' ,bestGene');
                    fprintf(']\n');
            
                end
            end
            agents = agents(~dead);
        end

        % Dont draw the map
        
        %process the ones that reached the goal
        %newBorn = {};
        
        %count Number of Newborns
        numNewBorn =0;
        for aI =1:length(agents)
            if ((agents{aI}.goal.x == agents{aI}.x) && (agents{aI}.goal.y == agents{aI}.y))
                numNewBorn =numNewBorn+1;
            end
        end
        numNewBorn =numNewBorn*2;
        newBorn = cell(1,numNewBorn);
        
        numNewBorn = 1;
        for aI =1:length(agents)
            if ((agents{aI}.goal.x == agents{aI}.x) && (agents{aI}.goal.y == agents{aI}.y))
              
                %offspring Id
                id = id+1;

                %energy
                energy = baseEnergy*energyMultiplier;

                
                newBorn{numNewBorn} = createOffspring3(id,problem,maps,agents{aI}.gene,mutationRate1,geneMin,geneMax,energy);
                numNewBorn = numNewBorn+1;
                id = id+1;
                newBorn{numNewBorn} = createOffspring3(id,problem,maps,agents{aI}.gene,mutationRate2,geneMin,geneMax,energy);
                numNewBorn = numNewBorn+1;
                %old style
                %newBorn{length(newBorn)+1} = createOffspring(id,worldAL,agents{aI}.gene,mutationRate,geneMin,geneMax,energy);
                
                %for the parent, assign a new goal, remember suboptimality
                %save old values
                oldTrial = agents{aI}.numTrials;
                subopt = agents{aI}.travelCost/agents{aI}.hsS0;
                oldsubopt = agents{aI}.subopt;
                oldGats = agents{aI}.GATs;
                oldtTotal = agents{aI}.tTotal;
                oldMoveTime = agents{aI}.moveTimes;
                moveTime = agents{aI}.tTotal/agents{aI}.travelCost;
                
                %create duplicate
                agents{aI} = createOffspring3(agents{aI}.id,problem,maps,agents{aI}.gene,noMutation,geneMin,geneMax,energy);
                
                %assignback old values
                agents{aI}.GATs = [oldGats oldtTotal];
                agents{aI}.moveTimes = [oldMoveTime moveTime];
                agents{aI}.subopt = [oldsubopt subopt];
                agents{aI}.numTrials = oldTrial+1;



            end
            
        end 
        newagents = [agents newBorn];
        agents = newagents;
        
        % Log population progress
        
        % find population min,max,and average, suboptimality
        popMinSubopt =Inf;
        popMaxSubopt =0;
        popSumSubopt =0;
        numAdults = 0;
        popSumGat = 0;
        popSumMoveTime=0;
        for i =1:length(agents)
            if agents{i}.numTrials ~=0
                numAdults=numAdults+1;
                popSumGat = popSumGat +mean(agents{i}.GATs);
                popSumMoveTime=popSumMoveTime+mean(agents{i}.moveTimes);
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
           % popAvgGat = popSumGat/numAdults;
            %popAvgMoveTime=popSumMoveTime/numAdults;
        else
            %popAvgGat = 0;
            popAvgSubopt = 0;
            %popAvgMoveTime=0;
        end

        %log min max and avg suboptimality
        minArray(step) = popMinSubopt;
        maxArray(step) = popMaxSubopt;
        avgArray(step) = popAvgSubopt; 
        %avgGatArray(step) = popAvgGat;
        %avgMoveTimeArray(step) =popAvgMoveTime;

        %population and adults
        population(step) = length(agents);
        adults(step) = numAdults;

        %population lookahead and gat
        %sumLookahead = 0;
        %totaLookahead = 0;
        %for i =1:length(agents)
        %    sumLookahead = agents{i}.gene(7)+sumLookahead;
        %end
        %avgLookahead = sumLookahead/length(agents);
        %avgLookArray = [avgLookArray avgLookahead];

        %populaton GAT
           
    end
    minArray = minArray(1:step);
    maxArray = maxArray(1:step);
    avgArray = avgArray(1:step);
    population =population(1:step);
    adults = adults(1:step);
    avgGatArray = 0;%avgGatArray(1:step);
    avgMoveTimeArray =0;
    
    
    

end
