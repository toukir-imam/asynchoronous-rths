%% The Final Cut Script
clear;
set(groot,'DefaultFigureRenderer','painters')
scenarioName = 'scenarios/uniMap_342_17100.mat';

%load test agent
load('test_bestAgent.mat')

%theFinalCut(bestAgent.byNumTrial,scenarioName)