% exp 1
try
    %clear -except gsubopt gexpanse;
    name ='march_29_exp1';
    exId = 1;
    %scenarioName ='scenarios/mm_8_8.mat';  
    %load(scenarioName);
    
    diary off
    diary on
    fprintf('\nstarting experiment %d\n\n',exId);


    attr.initialPopulation = 20;
    attr.maxAllowedPopulation = 20;
    attr.geneMax = [4 10 10 1 1 1 1];
    attr.geneMin = [1 0 0 0 0 0 0 ];
    attr.energyMultiplier = 5;
    attr.mutationRate1=(attr.geneMax-attr.geneMin)/50;
    attr.mutationRate2=(attr.geneMax-attr.geneMin)/150;
    attr.eraLength = era;
    attr.difficultyGrad = .3;
    attr.minSolved1=18;
    attr.minSolved2=24;
    attr.lBound = 0;
    attr.uBound  =10^6;
    attr.finalForm=3;
    
    attr.traceGene = [3.0000    3.4235    1.2998    0.2446    1.0000         0    0.2790];  
    attr.numTraceGene = 0;
    

    features.reCombination = true;
    features.multiOffspring = true;
    features.tracing = false;
    disp(attr);
    disp(features);

    
    diary off
    bestAgents = cell(1,nRepeat);
    steps = zeros(1,nRepeat);
    expanses = zeros(1,nRepeat);
    subopts1 = zeros(1,nRepeat);
    subopts2 = zeros(1,nRepeat);
    subopts3 = zeros(1,nRepeat);
    sT1 = zeros(1,nRepeat);
    sT2 = zeros(1,nRepeat);
    sT3 = zeros(1,nRepeat);
    sTH1 = zeros(1,nRepeat);
    sTH2 = zeros(1,nRepeat);
    sTH3 = zeros(1,nRepeat);
    maxSubopt1 = zeros(1,nRepeat);
    maxSubopt2 = zeros(1,nRepeat);
    maxSubopt3 = zeros(1,nRepeat);

    tstart = tic;
    for i = 1:nRepeat
        
        [bestAgents{i},steps(i),expanses(i),~,~] = asyncEvolution2_mex(trainS.maps,trainS.problems,attr,features);

    end
    tend = toc(tstart);
    %pop = stat.population;
    %if step<length(stat.population)
    
   %     pop = stat.population(1,1:step);
   % else
   %     step = length(stat.population);
   % end
    %x = 1:step;
    %plot(x,pop);
    %drawnow;
    
    
    
    diary on
    fprintf('time taken for evolution is %s\n',sec2str(tend));
    printVector('expanses = ',expanses);
    fprintf( '\n')
    %run test AStarSubopt
    numTestProblems = 123325;
    %numTestProblems = 2;
    for i =1:nRepeat
        %fprintf('Spotlight on gene : \n');
        %disp(bestAgents{i}.byNumTrial);
        %gene = bestAgents{i}.byAStarSubopt.gene;
        subopts1(i)=0;maxSubopt1(i)=0;sT1(i)=0;sTH1(i)=0;
       % if sum(gene(:)) ~=0
       %     [subopts1(i),maxSubopt1(i),sT1(i),sTH1(i)] = evaluate(hmS.maps,hmS.problem,gene,123325);
       % end
        %subopts(i)=0;
       
    end
    %by Foodvalue
    for i =1:nRepeat
        fprintf('Spotlight on gene : \n');
        gene = bestAgents{i}.byFoodValue.gene;
        disp(gene);
        subopts2(i)=0;maxSubopt2(i)=0;sT2(i)=0;sTH2(i)=0;
        if sum(gene(:)) ~= 0
            [subopts2(i),maxSubopt2(i),sT2(i),sTH2(i)] = evaluate(hmS.maps,hmS.problem,gene,123325);
        end
        %subopts(i)=0;
       
    end
    %by Final Num Trial
    for i =1:nRepeat
        %fprintf('Spotlight on gene : \n');
        %gene = bestAgents{i}.byFinalFormNTrials.gene;
        %disp(gene);
        subopts3(i)=0;maxSubopt3(i)=0;sT3(i)=0;sTH3(i)=0;
        %if sum(gene(:)) ~=0
        %    [subopts3(i),maxSubopt3(i),sT3(i),sTH3(i)] = evaluate(hmS.maps,hmS.problem,gene,123325);
        %end
        %subopts(i)=0;
       
    end
    tend2 = toc(tstart);
    fprintf('Final results from Experiment %d\n',exId);
    %printVector('subopts = ',subopts);
    
    fprintf('Total experiment time %s',sec2str(tend2));
    %gSuboptbyNumTrial = [gSuboptByNumTrial subopts];
    
    gSuboptByAStarSubopt =[gSuboptByAStarSubopt subopts1];
    gSuboptByFoodValue =[gSuboptByFoodValue subopts2];
    gSuboptByFinalTrialCount =[gSuboptByFinalTrialCount subopts3];
    gST1 = [gST1 sT1];
    gST2 = [gST2 sT2];
    gST3 = [gST3 sT3];
    gSTH1 = [gSTH1 sTH1];
    gSTH2 = [gSTH2 sTH2];
    gSTH3 = [gSTH3 sTH3];
    
    gMaxSubopt1 = [gMaxSubopt1 maxSubopt1];
    gMaxSubopt2 = [gMaxSubopt2 maxSubopt2];
    gMaxSubopt3 = [gMaxSubopt3 maxSubopt3];
    

    gExpanse = [gExpanse expanses];
    gGene{expId} = bestAgents{i};
    diary off
    
catch ME
    diary on
    ME
    for k=1:length(ME.stack)
        ME.stack(k)
    end
    diary off
end
    
   