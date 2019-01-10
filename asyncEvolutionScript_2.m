clear;
scenarioName = 'scenarios/uniMap_342_17100_async';
load(scenarioName);
 x = load('scenarios/MovingAI_342_493298.mat');
if ~isstruct(maps)
    [maps, problems] = prepForAsync(scenarioName);
    s = 'sdkf'
end
%compute lower and uper bound
aStar = extractfield(problems,'aStarDifficulty');
otp = extractfield(problems,'optimalTravelCost');
foodValue = aStar.*otp;
m = mean(foodValue);

diary('logs/may_2_finalForm.txt')
diary on
wins1 =[];
wins2 =[];
wins3 =[];
subopts=[];
%for ms1 = 20:5:50
for kk = 1:10
diary off
attr.initialPopulation = 10;
attr.maxAllowedPopulation = 10;
attr.geneMax = [4 10 10 1 1 1 1];
attr.geneMin = [1 0 0 0 0 0 0 ];
attr.energyMultiplier = 6;
attr.mutationRate1=(attr.geneMax-attr.geneMin)/50;
attr.mutatiopnRate2=(attr.geneMax-attr.geneMin)/150;
attr.eraLength = 50000;
attr.difficultyGrad = .4;
attr.finalForm =1;
attr.minSolved1=30;
attr.minSolved2=35;

attr.lBound = m-10^9;
attr.uBound  = m+10^9;

attr.traceGene = [3.0000    3.4235    1.2998    0.2446    1.0000         0    0.2790];
attr.numTraceGene = 10;
features= struct();
features.reCombination = true;
features.multiOffspring = true ;
features.tracing = true ;
tstart = tic;

[bestAgent,step,gExpanse,stat] = asyncEvolution2_mex(maps,problems,attr,features);

%diary on
tend = toc(tstart);
%expPerTime = expanse/tend;
fprintf('expanse per second %5.2e\n',gExpanse/tend);

if bestAgent.byNumTrial.isTraceGene == true
    fprintf('trace gene won by numTrial\n')
    wins1 = [wins1 1];
    subopts =[subopts NaN];
else 
    wins1 = [wins1 0];
end
if bestAgent.byFoodValue.isTraceGene == true
    fprintf('trace gene won by foodValue\n')
    wins2 = [wins2 2];
    subopts =[subopts NaN];
else 
    wins2 = [wins2 0];
end
if bestAgent.byFinalFormNTrials.isTraceGene == true
    fprintf('trace gene won by foodValue\n')
    wins3 = [wins3 3];
    subopts =[subopts NaN];
else 
    wins3 = [wins3 0];
end
    %fprintf('best agent solved = %d\n, with food %d',bestAgent.byFinalFormNTrials.numTrials,sum(bestAgent.byFoodValue.pastFoodValue));

    %gSubopt = evaluate(x.maps,x.problem,bestAgent.byNumTrial.gene,4933 );
    %save('logs/_range_10_10_5_all_trace.mat','gExpanse','gSubopt');
    %subopts =[subopts NaN];
    
if bestAgent.byNumTrial.id == bestAgent.byFinalFormNTrials.id
    fprintf('byNumTrial and byFinalFormNTrials are the same\n');
end
diary off  
%end
diary on
wins1
wins2
wins3
subopts
diary off
end

%pop = stat.population;
%if step<length(stat.population)
    
%    pop = stat.population(1,1:step);
%else
%    step = length(stat.population);
%end
%x = 1:step;
%plot(x,pop);
%drawnow;
%end
%[ meanSubopt,isSolved ] = sanityCheck(bestAgent.byNumTrial.gene )




