clear;
scenarioName = 'scenarios/uniMap_342_17100_async';
load(scenarioName);
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



attr.initialPopulation = 50;
attr.maxAllowedPopulation = 50;
attr.geneMax = [4 10 10 1 1 1 1];
attr.geneMin = [1 0 0 0 0 0 0 ];
attr.energyMultiplier = 2;
attr.mutationRate1=(attr.geneMax-attr.geneMin)/50;
attr.mutationRate2=(attr.geneMax-attr.geneMin)/150;
attr.eraLength = 100000;
attr.difficultyGrad = .4;
%attr.finalForm = 1;
attr.minSolved1=0;
attr.minSolved2=0;
attr.lBound = 0;
attr.uBound  = m+10^8;
attr.finalForm=1;
attr.traceGene = [3.0000    3.4235    1.2998    0.2446    1.0000         0    0.2790];
attr.numTraceGene = 1;

features= struct();
features.reCombination = true;
features.multiOffspring = true;
features.tracing = true;
tstart = tic;
[bestAgent,step,expanse,stat,~] = asyncEvolution2(maps,problems,attr,features);
bestAgent.byFinalFormNTrials
bestAgent.byFoodValue
bestAgent.byAStarSubopt
%step = min(step,length(stat.population));
%x = 1:step;
%plot(x,stat.population(1:step),'b');
%hold on



drawnow;

%diary on
tend = toc(tstart)
expPerTime = expanse/tend
fprintf('expanse %5.2e\n',expanse);






