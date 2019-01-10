clear;
scenarioName = 'scenarios/uniMap_342_17100_async';
load(scenarioName);

testScenarioName = 'scenarios/MovingAI_342_493298_opl.mat';
testS = load(testScenarioName);
hmS = testS;

maps =mapList;
%x = load('scenarios/uniMap_342_17100.mat');
if ~isstruct(maps)
    [mapList, problems] = prepForAsync(scenarioName);
    s = 'sdkf'
end
%compute lower and uper bound
aStar = extractfield(problems,'aStarDifficulty');
otp = extractfield(problems,'optimalTravelCost');
foodValue = aStar.*otp;
m = mean(foodValue);



attr.initialPopulation = 10;
attr.maxAllowedPopulation = 10;
attr.geneMax = [4 10 10 1 1 1 1];
attr.geneMin = [1 1 1 0 0 0 0 ];
attr.energyMultiplier = 8;
attr.mutationRate1=(attr.geneMax-attr.geneMin)/50;
attr.mutationRate2=(attr.geneMax-attr.geneMin)/150;
attr.eraLength = 5*10^3;
attr.difficultyGrad = .3;
%attr.finalForm = 1;
attr.minSolved1=10;
attr.minSolved2=12;
attr.lBound = 0;
attr.uBound  = m+10^8;
attr.finalForm=1;
attr.traceGene = [3.0000    3.4235    1.2998    0.2446    1.0000         0    0.2790];
attr.numTraceGene = 0;

features= struct();
features.reCombination = true;
features.multiOffspring = true;
features.tracing = false;
tstart = tic;
[bestAgent,step,expanse,stat,statBest] = asyncEvolution2_mex(maps,problems,attr,features);


popSubopt = zeros(size(stat));
bestSuboptF = zeros(size(statBest));
bestSuboptA = zeros(size(statBest));

popSolved = zeros(size(stat));
bestSolvedF = zeros(size(statBest));
bestSolvedA = zeros(size(statBest));

%save('logs/population_helth.mat','stat','statBest');
for i = 1:size(stat,1)
    for j = 1:size(stat,2)
        if ~stat(i,j).isDummy
            gene = stat(i,j).gene;
            [subopt,~,~,~,solved] = evaluate(hmS.maps,hmS.problem,gene,49329);
            popSubopt(i,j) = subopt;
            popSolved(i,j) = solved;
        end
    end
end
for i =1: length(statBest)
    gene = statBest(i).byFoodValue.gene;
    if sum(gene) ~=0
        [subopt,~,~,~,solved] = evaluate(hmS.maps,hmS.problem,gene,49329);
        bestSuboptF(i) = subopt;
        bestSolvedF(i) = solved;
    end
    if sum(gene) ~=0
        
        gene = statBest(i).byAStarSubopt.gene;
        [subopt,~,~,~,solved] = evaluate(hmS.maps,hmS.problem,gene,49329);
        bestSuboptA(i) = subopt;
        bestSolvedA(i) = solved;
    end
end

%step = min(step,length(stat.population));
%x = 1:step;
%plot(x,stat.population(1:step),'b');
%hold on

save('logs/population_helth_take4.mat','popSubopt','bestSuboptF','bestSuboptA','popSolved','bestSolvedF','bestSolvedA');


%diary on
tend = toc(tstart)
expPerTime = expanse/tend
fprintf('expanse %5.2e\n',expanse);


