%% Deep Learning: effect of epochs and batch sizes
% Vadim Bulitko
% Sep 23, 2016

close all
clear
clc
diary off
format short g

%% Control parameters
numProblems = 10;
r = 10;
numStartsPerProblem = 50;
scenarioNameTrain = 'scenarios/MovingAI_342_493298.mat';

targetGoalDirX = [];
targetGoalDirY = [];

cnnTargetHeight = 227;
cnnTargetWidth = 227;

batchSizeRange = [3 5 10 25];
numEpochsRange = [3 5 10];

numTrials = 4;
numGPUs = 4;

displayCNN = false;

markerShape = {'d','s','+','o','h','^','x'};
markerColor = {'b','r','c','g','k','m'};

%% Preliminaries
% create a parallel pool if needed
if (isempty(gcp('nocreate')))
    parpool('local', numGPUs);
end

valAccuracy = NaN(1,numTrials);
timeTrain = NaN(1,numTrials);

meanVA = NaN(length(batchSizeRange),length(numEpochsRange));
stdVA = NaN(length(batchSizeRange),length(numEpochsRange));
meanTT = NaN(length(batchSizeRange),length(numEpochsRange));
stdTT = NaN(length(batchSizeRange),length(numEpochsRange));

diaryFileName = sprintf('deepLearning/_optimalMove/_logs/batchEpoch_r%d_problems%d_starts%d_trials%d_x%d_y%d.txt',...
    r,numProblems,numStartsPerProblem,numTrials,targetGoalDirX,targetGoalDirY);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('batchEpoch.m | ');
disp(datetime);

fig = figure('Position',[100 95 1280 720]);

diary off
diary on

tttt = tic;

%% Load or generate neighborhoods data
dbFileName = sprintf('deepLearning/_optimalMove/_neighborhoods/r%d_problems%d_starts%d_x%d_y%d.mat',...
    r,numProblems,numStartsPerProblem,targetGoalDirX,targetGoalDirY);
if (exist(dbFileName,'file'))
    % already exist, load
    load(dbFileName);
    fprintf('Loaded %s\n\t%d neighborhoods in %d classes\n',dbFileName,length(data.class),data.numClasses);
else
    % generate the data
    [data, ~, ~, ~] = createTrainingDataOMmcn(scenarioNameTrain,r,...
        numProblems,numStartsPerProblem,targetGoalDirX,targetGoalDirY);
    save(dbFileName,'data','-v7.3');
end

%% Plot a histogram and a random training datum
subplot(1,2,1);
xt = 1:length(data.moveLabel);
counts = hist(data.class,xt);
bar(xt,100*counts/sum(counts));
ax = gca;
ax.XTick = xt;
ax.XTickLabel = data.moveLabel;
drawnow
xlabel('Optimal moves');
ylabel('Percentage of data');
box on
grid on
title(sprintf('%d data in %d classes',length(data.class),data.numClasses));

subplot(1,2,2);
rii = randi(length(data.class));
image(imresize2(data.input(:,:,:,rii),[cnnTargetHeight,cnnTargetWidth]));
box on
axis square
title(sprintf('Input %d | class %s',rii,data.moveLabel{data.class(rii)}));

drawnow

%% Go through different epoch numbers
firstCNNplot = true;
legendStr = {};
epochI = 0;
for numEpochs = numEpochsRange
    epochI = epochI + 1;
    fprintf('\n%d epochs\n',numEpochs);
    
    %% Go through different batch sizes
    batchI = 0;
    for batchSize = batchSizeRange
        batchI = batchI + 1;
        fprintf('\n\tbatch size %d\n',batchSize);
        
        %% Run several trials
        %for t = 1:numTrials
        parfor t = 1:numTrials
            gpuIndex = 1+mod(t,numGPUs);
            reset(gpuDevice(gpuIndex));
            
            % Train the network
            tttTrain = tic;
            [net,~,~,validationI] = trainCNN(data,numEpochs,batchSize,gpuIndex,displayCNN);
            timeTrain(t) = toc(tttTrain);
            
            reset(gpuDevice(gpuIndex));
            
            % Evaluate the network accuracy
            tttValidate = tic;
            valAccuracy(t) = evalNetworkAccuracy(net,data,validationI,gpuIndex);
            timeValidate = toc(tttValidate);
            
            fprintf('\t%d | GPU %d | %s : %s/epoch | valAcc %0.1f%%, %s\n',...
                t,gpuIndex,...
                sec2str(timeTrain(t)),sec2str(timeTrain(t)/numEpochs),...
                100*valAccuracy(t),sec2str(timeValidate));
        end
        
        %% Stats
        meanVA(batchI,epochI) = mean(valAccuracy);
        meanTT(batchI,epochI) = mean(timeTrain);
        stdVA(batchI,epochI) = std(valAccuracy);
        stdTT(batchI,epochI) = std(timeTrain);
        
        fprintf('Train time %s +/- %s | validation accuracy %0.1f%% +/- %0.1f%%\n',...
            sec2str(meanTT(batchI,epochI)),sec2str(stdTT(batchI,epochI)),100*meanVA(batchI,epochI),100*stdVA(batchI,epochI));
        
        %% Plot
        if (firstCNNplot)
            close(fig);
            fig = figure('Position',[100 95 1280 720]);
            firstCNNplot = false;
        end
        legendStr = [legendStr sprintf('%d epochs, %d in batch',numEpochs,batchSize)]; %#ok<AGROW>
        plot(meanTT(batchI,epochI),100*meanVA(batchI,epochI),[markerColor{epochI} markerShape{batchI}]);
        hold on
        rectangle('Position',[meanTT(batchI,epochI)-stdTT(batchI,epochI), 100*meanVA(batchI,epochI)-100*stdVA(batchI,epochI),...
            2*stdTT(batchI,epochI), 2*100*stdVA(batchI,epochI)],'EdgeColor',markerColor{epochI});
        legend(legendStr,'Location','eastoutside');
        box on
        grid on
        xlabel('Time (sec)');
        ylabel('Validation accuracy (%)');
        title(sprintf('radius %d | %d problems x %d starts | %d trials | dx %d, dy %d | %s',...
            r,numProblems,numStartsPerProblem,numTrials,targetGoalDirX,targetGoalDirY,sec2str(toc(tttt))));
        
        drawnow
        exportFigure(fig,sprintf('deepLearning/_optimalMove/_plots/batchEpoch_r%d_problems%d_starts%d_trials%d_x%d_y%d',...
            r,numProblems,numStartsPerProblem,numTrials,targetGoalDirX,targetGoalDirY),'pdf',[10 6]);
    end
end

%% Final plot
clf
subplot(1,2,1);
contourf(numEpochsRange,batchSizeRange,100*meanVA,'ShowText','on');
colormap('jet');
box on
grid on
xlabel('Number of epochs');
ylabel('Batch size');
title(sprintf('Validation accuracy | radius %d | %d problems x %d starts | dx %d, dy %d',...
    r,numProblems,numStartsPerProblem,targetGoalDirX,targetGoalDirY));

subplot(1,2,2);
contourf(numEpochsRange,batchSizeRange,meanTT,'ShowText','on');
colormap('jet');
box on
grid on
xlabel('Number of epochs');
ylabel('Batch size');
title(sprintf('Train time (sec) | %d trials | %s',numTrials,sec2str(toc(tttt))));

exportFigure(fig,sprintf('deepLearning/_optimalMove/_plots/batchEpoch2_r%d_problems%d_starts%d_trials%d_x%d_y%d',...
    r,numProblems,numStartsPerProblem,numTrials,targetGoalDirX,targetGoalDirY),'pdf',[10 6]);

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttt)));
diary off
