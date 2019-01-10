function [ bestAgent ,step,expanse ,stat] = asyncEvolution2( maps,problem,attr,features )
%Toukir Imam (mdtoukir@ualberta.ca)
%   Detailed explanation goes here

expanse =0;
%% Unpack attr
initialPopulation = attr.initialPopulation;
maxAllowedPopulation = attr.maxAllowedPopulation;
geneMax = attr.geneMax;
geneMin = attr.geneMin;
energyMultiplier = attr.energyMultiplier;
mutationRate1 = attr.mutationRate1;
mutationRate2 = attr.mutationRate2;
eraLength = attr.eraLength;
difficultyGrad = attr.difficultyGrad;

%% Set some parameters
noMutation = zeros(size(geneMax));
%mutationRate1 = noMutation;
errRate = 0;

%% stat
stat = struct();
%maxStep = round(eraLength*(energyMultiplier/difficultyGrad));
%stat.population = zeros(1,maxStep);
%stat.born1 = int8(zeros(1,maxStep));
%stat.born2 = int8(zeros(1,maxStep));
%stat.death1 = zeros(1,maxStep);
%stat.death2 = zeros(1,maxStep);

%% fix the size of agents vector
dummyAgent = createDummyAgent(maps,problem,geneMax,attr);
agents = repmat(dummyAgent,[1,maxAllowedPopulation*5]);
availStack = zeros(size(agents));
bestAgent = struct();
bestAgent.byNumTrial = dummyAgent;
bestAgent.byFoodValue = dummyAgent;
bestAgent.byFinalFormNTrials = dummyAgent;
%% populate with initial population
id =0;
for i = 1: initialPopulation
    id = i;

    gene = randGene(geneMin,geneMax);
    agents(i) = createOffspring6(id,problem,maps,gene,noMutation,geneMin,geneMax,energyMultiplier,attr);
    
end
if features.tracing
    agents(1) = createOffspring6(1,problem,maps,attr.traceGene,noMutation,geneMin,geneMax,energyMultiplier,attr);
    fprintf('trace gene born with energy %5.3e to solve OTC %5.3e\n',agents(1).energy,agents(1).hsS0);
    agents(1).isTraceGene = true;
end
numPopulation = initialPopulation;
availSpace = length(agents)-initialPopulation;
availStack(1,1:availSpace) = initialPopulation+1:length(agents);
availId = availSpace;
%% keep count of steps
step = 0;
%totalborn =0;
%% main loop
while numPopulation ~=0
    step = step+1;
    %stat.born1(1,step) =0;
    %stat.born2(1,step)=0;
    % gradual difficulty
    %if mod(step,100) ==0
    %            fprintf('population: %d, energyMultiplier: %f, step: %d\n',int32(numPopulation),energyMultiplier,int32(step));
    %end
    if mod(step,eraLength) ==0
        energyMultiplier = energyMultiplier - difficultyGrad;
        if energyMultiplier <0
            energyMultiplier = 0;
        end
        fprintf('population: %d, energyMultiplier: %f, step: %d\n',int32(numPopulation),energyMultiplier,int32(step));
        fprintf('%d problems by numTrials\n',int32(bestAgent.byNumTrial.numTrials));
        fprintf('%d problems by finalFormNTrials\n\n',int32(bestAgent.byFinalFormNTrials.finalFormNTrials));
        %bestAgent.byOTC
        %sum(bestAgent.byOTC.pastOTC(:))
        %bestAgent.byNumTrial
        
    end
    % move all agents one step
    for aI = 1:length(agents)
        if ~agents(aI).isDummy        
            agents(aI) = runStep(agents(aI),errRate);
            expanse = expanse+1;

        end
       % elist(i) = agents(i).energy; debug
    end
    
   % elist debug
    
    %% House keeping
    for i = 1:length(agents)
        if ~agents(i).isDummy
            
            %% kill agents who spent their energy
            if isDead2(agents(i),0,NaN)
                agents(i).isDummy =true;
                numPopulation = numPopulation -1;
                availId=availId+1;
                availStack(availId) =i;
                if features.tracing && agents(i).isTraceGene
                    fprintf('traceGene died. problems Solved %f, foods consumed %f \n',agents(i).numTrials,sum(agents(i).pastFoodValue));
                    %disp(agents(i));
                end
                %s = 'death at'
                %availStack(availId)
                %availStack
                %availId
            end
        end
    end
    for i =1:length(agents)
        if ~agents(i).isDummy
            %% Dont Kill anyone who reached goal

            if((agents(i).x == agents(i).goal.x) && (agents(i).y == agents(i).goal.y))
                %offspring Id
                agent = agents(i);
                %check if this is the best agent so far
                
                bestAgent = compareBest(agents(i),bestAgent);
                
                
                if agent.numTrials>attr.minSolved1
                    id = id+1;

                    % to recombine or not
                    gene = agent.gene;
                    if features.reCombination
                        p2 = findPair(agent,agents);

                        gene = reCombine(agent.gene,p2.gene);
                    end

                    agents(availStack(availId)) = createOffspring6(id,problem,maps,gene,mutationRate1,geneMin,geneMax,energyMultiplier,attr);
               
                    %stat.born1(1,step)=stat.born1(1,step)+1;
             
                    availId=availId-1;
                    numPopulation = numPopulation+1;
                end
                %totalborn = totalborn+1;
                
                if features.multiOffspring && agent.numTrials >attr.minSolved2
                    id = id+1;
                    agents(availStack(availId)) = createOffspring6(id,problem,maps,agent.gene,mutationRate2,geneMin,geneMax,energyMultiplier,attr);
                    
                    %stat.born2(1,step)=stat.born2(1,step)+1;
                    
                    availId=availId-1;
                    numPopulation = numPopulation+1;
                    %totalborn = totalborn+1;
                end   
                    
                %s ='here'
                %re assign to a new problem
                %agents(i).isDummy =true;
                %numPopulation = numPopulation -1;
                agents(i) = reAssign(agents(i),maps,problem,energyMultiplier,attr);
                
                %s = 'born at'
                %availStack(availId+1)
                %availStack
                %availId
                
            end
        end
    end
    
    %% cull population
    
    if numPopulation > maxAllowedPopulation
        
        %fprintf('culling started current Population %f\n',numPopulation);
        energyList = zeros([numPopulation,2]);
        elId =1;
        for i = 1:length(agents)
            if ~agents(i).isDummy
                energyList(elId,1) =agents(i).energy;
                energyList(elId,2)= i;
                elId = elId +1;
            end
        end
        energyList = sortrows(energyList,1);    
        for i=maxAllowedPopulation+1:numPopulation
            %perform the killing ritual
            
            agents(energyList(i,2)).isDummy = true;
            numPopulation = numPopulation -1;
            availId=availId+1;
            availStack(availId) =energyList(i,2);
            if features.tracing && agents(energyList(i,2)).isTraceGene
                fprintf('traceGene culled. problems Solved %f, foods consumed %f \n',agents(energyList(i,2)).numTrials,sum(agents(energyList(i,2)).pastFoodValue));
                %disp(agents(energyList(i,2)));
            end
        end
        %fprintf('culled %d agents',maxAllowedPopulation-numPopulation);
        %fprintf('culling ended current Population %f\n',numPopulation);
        
    end
    %if step<length(stat.population)
    %    stat.population(step) = numPopulation;
    %end
    
    
end

end

