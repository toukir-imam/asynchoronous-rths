%% exp 1
try
    %clear -except gsubopt gexpanse;
    name ='march_14_exp3';
    exId = 3;
    %scenarioName ='scenarios/mm_8_8.mat';  
    load(scenarioName);
    
    diary off
    diary on
    fprintf('\nstarting experiment %d\n\n',exId);


    attr.initialPopulation = 200;
    attr.maxAllowedPopulation = 200;
    attr.geneMax = [4 20 20 1 1 1 ];
    attr.geneMin = [1 0 0 0 0 0];
    attr.energyMultiplier = 6;
    attr.mutationRate1=[.2,.5,.5,.3,.3,.3];
    attr.mutationRate2=[.5,.6,.6,.1,.1,.1];
    attr.eraLength = 5000;
    attr.difficultyGrad = .25;

    features.reCombination = true;
    features.multiOffspring = true;

    disp(attr);
    disp(features);

    
    diary off
    bestAgents = cell(1,nRepeat);
    steps = zeros(1,nRepeat);
    expanses = zeros(1,nRepeat);
    subopts = zeros(1,nRepeat);

    tstart = tic;
    parfor i = 1:nRepeat

        [bestAgents{i},steps(i),expanses(i)] = asyncEvolution2_mex(maps,problems,attr,features);

    end
    tend = toc(tstart);

    diary on
    fprintf('time taken for evolution is %.2f minutes\n',tend/3*60);
    fprintf( '\n')
    %run test
    for i =1:nRepeat
        fprintf('Spotlight on agent : \n');
        disp(bestAgents{i}.byNumTrial);
        
        [sanSub,isSolved] = sanityCheck(bestAgents{i}.byNumTrial.gene);
        if isSolved && sanSub<25
            subopts(i) = evaluate(testScenarioName,bestAgents{i}.byNumTrial.gene);
        end
    end
    fprintf('Final results from Experiment %d\n',exId);
    fprintf('subopt ='); disp(subopts);
    fprintf('expanse =');disp(expanses);
    gSubopt = [gSubopt subopts];
    gExpanse = [gExpanse expanses];
    diary off
catch ME
    diary on
    ME
    for k=1:length(ME.stack)
        ME.stack(k)
    end
    diary off
end