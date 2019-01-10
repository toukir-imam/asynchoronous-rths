clear;
clc;
%inputs to the script 
%worldName = 'worlds/world1.mat';
fig =figure('Visible','on');
diary('logs/march_2');
diary on;
scenarioName = 'scenarios/uniMap_342_17100_wDif.mat'
%scenarioName = 'scenarios/uniMap_8_80.mat'
initialPopulation = 20
showMap =false
difficutyLevel = .3
energyMultiplier = 5
maxAllowedPopulation =75
minReqEnergy = 0
eraLength=1000;

load(scenarioName) 

[step,avgArray,avgGatArray,avgMoveTimeArray,population,adults,bestAgent] ...
    = asyncEvolutionOTCFood( maps,problem,initialPopulation,maxAllowedPopulation,...
    energyMultiplier,difficutyLevel,eraLength );

%save best agent

save ('test_bestAgent','bestAgent');


%%visualise
x =1:step;
subplot(1,2,1);
plot(x,avgArray,'g');
xlabel('# Step');
ylabel('Mean Population Suboptimality')
subplot(1,2,2);
plot(x,population,'r');
hold on;
plot(x,adults,'b');
xlabel('# Step');
ylabel('red : Population, blue : adults');

%close(videoW);
drawnow
load('scenarios/uniMap_200_10000')
%load('scenarios/uniMap_342_1710')
%load('scenarios/uniMap_342_34200')
%load('scenarios/uniMap_8_80.mat')
%load('scenarios/MovingAI_342_493298.mat')
%gene =  [3.0522   26.3443   35.9914    0.4935    0.2708    0.9438];
%gene = [1 1 1 0 0 0];
%gene = [ 2.681 27.394 30.545 0.388 1.000 0.000]
gene = bestAgent.byNumTrial.gene

nProblems = length(problem);
cutoff = 100000;
errorRate =0;
[subopt, sc, solved] = geneEval(gene,problem,maps,nProblems,cutoff,errorRate);
mean(subopt)
sum(solved)

gene = bestAgent.byOTC.gene

nProblems = length(problem);
cutoff = 100000;
errorRate =0;
[subopt, sc, solved] = geneEval(gene,problem,maps,nProblems,cutoff,errorRate);
mean(subopt)
sum(solved)
%othergene = [bestGene(3) bestGene(2) bestGene(6) bestGene(5) 0 bestGene(1) bestGene(4) 0]
diary off
