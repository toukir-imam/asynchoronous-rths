
clear 

nRepeat = 1;
diary('logs/may_23.txt');
scenarioName = 'scenarios/uniMap_342_17100_async.mat';
testScenarioName = 'scenarios/uniMap_342_1710_opl.mat';%'scenarios/uniMap_342_34200.mat';%scenarios/MovingAI_342_493298';%scenarios/uniMap_200_10000';
halfMillionScenario= 'scenarios/MovingAI_342_493298_opl';%'scenarios/uniMap_342_1710.mat';%'scenarios/mm_8_8.mat';%'scenarios/uniMap_342_493164';
%toyMap = 'scenarios/mm_8_8.mat';
hmS = load(halfMillionScenario);
trainS = load(scenarioName);
trainS.maps =trainS.mapList;
testS = load(testScenarioName);
%hmS = testS
to = tic;
fig = figure();

eras  =[10^6];
for outId = 1:length(eras)
era = eras(outId);
gSuboptByNumTrial =[];
gSuboptByFoodValue =[];
gSuboptByFinalTrialCount =[];
gSuboptByAStarSubopt =[];

 gST1 = [];
 gST2 = [];
 gST3 = [];
 gSTH1 = [];
 gSTH2 = [];
 gSTH3 = [];

gMaxSubopt1 = [];
gMaxSubopt2 = [];
gMaxSubopt3 = [];

gExpanse =[];
gGene = cell(1,5);
for expId =1:1
    exp1;
    diary on
    gSuboptByNumTrial
    gSuboptByFoodValue
    gSuboptByFinalTrialCount
    gExpanse
    gGene
    plot(gExpanse,gSuboptByAStarSubopt,'bo');
    hold on
    plot(gExpanse,gSuboptByFoodValue,'ro');
    hold on
    plot(gExpanse,gSuboptByFinalTrialCount,'go');
    xlabel('States expanded');
    ylabel('Suboptimality');
    legend('NumTrial','FoodValue','FinalTrial');
    drawnow;
    diary off
    save(strcat('logs/_range_async_carry_20_',num2str(era),'_pointy.mat'),'gSuboptByAStarSubopt',...
        'gSuboptByFoodValue','gSuboptByFinalTrialCount','gExpanse','gGene','gST1','gST2','gST3'...
        ,'gSTH1','gSTH2','gSTH3','gMaxSubopt1','gMaxSubopt2','gMaxSubopt3');
end
end
%exp2;
%exp3;
%exp4;
diary on


te = toc(to);
fprintf('total time taken for experiment : %s m\n',sec2str(te)); 
%plot(gExpanse,gSubopt,'gx');
diary off