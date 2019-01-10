%% Train a deep learning network for optimal move
% Vadim Bulitko
% May 29, 2016

clear 
close all
clc
diary off
format short g

%% Preliminaries
numProblemsTrain = 100;
r = 10;                   
numDataPerProblemTrain = 500;

cnnTargetHeight = 227;
cnnTargetWidth = 227;

diaryFileName = sprintf('logs/optimalMoveDL_%d_%d_%d.txt',r,numProblemsTrain,numDataPerProblemTrain);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('optimalMoveDL.m | ');
disp(datetime);

diary off
diary on

ttt = tic;

%% Create the training data
scenarioNameTrain = 'scenarios/MovingAI_342_493298_100.mat';

[data, cm, addC, ~] = createTrainingDataOMmcn(scenarioNameTrain,r,numProblemsTrain,numDataPerProblemTrain,cnnTargetHeight,cnnTargetWidth);

%% Train the network
batchSize = 100;
cardIndex = 1;
numEpochs = 30;

tttt = tic;
[net,~,~,validationI] = trainOM(scenarioNameTrain,r,numProblemsTrain,numDataPerProblemTrain,numEpochs,batchSize,cardIndex,data);
fprintf('Trained %d epochs in %s | %s per epoch\n',numEpochs,sec2str(toc(tttt)),sec2str(toc(tttt)/numEpochs));

% % % Save the network
% [~, sNameNET, ~] = fileparts(scenarioNameTrain);
% save(sprintf('deepLearning/_optimalMove/nn_%s_%d_%d_%d_%d.mat',sNameNET,r,numProblemsTrain,numDataPerProblemTrain,numEpochs),'net');

%% Evaluate the network accuracy
networkAccuracy = evalNetworkAccuracy(net,data,validationI);
fprintf('\tNetwork validation accuracy %0.1f%%\n',100*networkAccuracy);

%% Evaluate the resulting network by solving problems
scenarioNameEval = 'scenarios/MovingAI_342_493298_100.mat';
numProblemsEval = 25;
cutoff = 10;

[meanSubopt,semSubopt,meanSc,semSc,fractionSolved] = moveAlgEval(scenarioNameEval,numProblemsEval,cutoff,r,net,cm,addC);

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(ttt)));
diary off
