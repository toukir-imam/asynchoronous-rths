%% Deep Learning: effects of database size and the neighborhood radius
% Vadim Bulitko
% Sep 25, 2016

close all
clear
clc
diary off
format short g

%% Control parameters
maxDBsize = 1000000;
maxDBchunks = 1000;
entriesPerChunk = maxDBsize / maxDBchunks;

dbSizeRange = entriesPerChunk*[50 100 150 200]; % can go up to maxDBChunks chunks inside []
rRange = [50 75 113]; %[5 10 25 50 75 113];

scenarioNameTrain = 'scenarios/MovingAI_342_493298.mat';

targetGoalDirX = [];
targetGoalDirY = [];

cnnTargetHeight = 227;
cnnTargetWidth = 227;

numEpochs = 5;
batchSize = 25;

numTrials = 2;
numGPUs = 1;

displayCNN = false;

marker = {'ro','bs','gv','mh','k^','c+'};
assert(length(marker) >= length(rRange));


%% Preliminaries
%create a parallel pool if needed
if (numGPUs > 1 && numTrials > 1 && isempty(gcp('nocreate')))
    parpool('local', numGPUs);
end

valAccuracy = NaN(1,numTrials);
timeTrain = NaN(1,numTrials);

meanVA = NaN(length(dbSizeRange),length(rRange));
stdVA = NaN(length(dbSizeRange),length(rRange));
meanTT = NaN(length(dbSizeRange),length(rRange));
stdTT = NaN(length(dbSizeRange),length(rRange));

diaryFileName = sprintf('deepLearning/_optimalMove/_logs/dbSizeRadius_epochs%d_batch%d_trials%d_x%d_y%d.txt',...
    numEpochs,batchSize,numTrials,targetGoalDirX,targetGoalDirY);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('dbSizeRadius.m | ');
disp(datetime);

fig = figure('Position',[100 95 1280 720]);
drawnow

fig2 = figure('Position',[100 95 1280 720]);
drawnow

diary off
diary on

tttt = tic;

%% Try different radii
legendStr = {};
rI = 0;
for r = rRange
    rI = rI + 1;
    fprintf('\n==== Radius %d\n',r);
    
    %% Try different database sizes
    dbsI = 0;
    for dbSize = dbSizeRange
        dbsI = dbsI + 1;
        
        fprintf('\n>>>>>>>>>>>> Database size %s\n\n',hrNumber(dbSize));
        
        %% Prepare the data structures
        clear data
        data.input = NaN(2*r+1,2*r+1,3,dbSize,'single');
        data.class = NaN(1,dbSize,'single');
        offset = 0;
        
        %% Load the data
        numLoadedChunks = floor(dbSize / entriesPerChunk);
        fprintf('Need %s entries, %s per chunk, %s chunks\n',...
            hrNumber(dbSize),hrNumber(entriesPerChunk),hrNumber(numLoadedChunks));
        for c = 1:numLoadedChunks
            % load
            clear chunkData
            dbFileName = sprintf('~/dl/_optimalMove/_neighborhoods/r%d_problems%d_starts%d_x%d_y%d_part%d',...
                r,maxDBchunks,entriesPerChunk,targetGoalDirX,targetGoalDirY,c);
            chunkData = load(dbFileName);
            fprintf('...%s\n',dbFileName);
            assert(~any(isnan(chunkData.data.class)));
            
            % Add it to the data
            actualEntries = length(chunkData.data.class);
            data.input(:,:,:,offset+1:offset+actualEntries) = chunkData.data.input;
            data.class(offset+1:offset+actualEntries) = single(chunkData.data.class);
            offset = offset + actualEntries;
        end
        
        % Trim
        data.input = data.input(:,:,:,1:offset);
        data.class = data.class(1:offset);
        
        % Copy the rest of the data from the last chunk
        data.imageHeight = chunkData.data.imageHeight;
        data.imageWidth = chunkData.data.imageWidth;
        data.r = chunkData.data.r;
        assert(data.r == r);
        data.cm = chunkData.data.cm;
        data.numClasses = chunkData.data.numClasses;
        data.moveLabel = chunkData.data.moveLabel;
        
        x = whos('data');
        fprintf('%s data in %d classes | %s\n',hrNumber(length(data.class)),data.numClasses,hrBytes(x.bytes));
        clear chunkData
        
        % Plot a histogram and a random training datum
        figure(fig2);
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
        title(sprintf('%s data (%s goals x %s starts) | %d classes',...
            hrNumber(length(data.class)),hrNumber(numLoadedChunks),hrNumber(entriesPerChunk),data.numClasses));
        
        subplot(1,2,2);
        rii = randi(length(data.class));
        image(imresize2(data.input(:,:,:,rii),[cnnTargetHeight,cnnTargetWidth]));
        box on
        axis square
        title(sprintf('radius %d | input %d | class %s',r,rii,data.moveLabel{data.class(rii)}));
        
        drawnow
        
        exportFigure(fig2,sprintf('deepLearning/_optimalMove/_plots/_neighDB/neighDB_r%d_problems%d_starts%d_x%d_y%d',...
            r,numLoadedChunks,entriesPerChunk,targetGoalDirX,targetGoalDirY),'pdf',[10 6]);
        figure(fig);
        
        %% Run several trials
        fprintf('\n');
        for t = 1:numTrials
        %parfor t = 1:numTrials
            %gpuIndex = 1+mod(t,numGPUs);
            gpuIndex = 2;
            %reset(gpuDevice(gpuIndex));
            %gpuDevice(gpuIndex);
            
            % Train the network
            tttTrain = tic;
            [net,~,~,validationI] = trainCNN(data,numEpochs,batchSize,gpuIndex,displayCNN);
            timeTrain(t) = toc(tttTrain);
            
            %reset(gpuDevice(gpuIndex));
            
            % Evaluate the network accuracy
            tttValidate = tic;
            valAccuracy(t) = evalNetworkAccuracy(net,data,validationI,gpuIndex);
            timeValidate = toc(tttValidate);
            
            fprintf('%d | GPU %d | %s : %s/epoch | valAcc %0.1f%%, %s\n',...
                t,gpuIndex,...
                sec2str(timeTrain(t)),sec2str(timeTrain(t)/numEpochs),...
                100*valAccuracy(t),sec2str(timeValidate));
        end
        
        %% Stats
        meanVA(dbsI,rI) = mean(valAccuracy);
        meanTT(dbsI,rI) = mean(timeTrain);
        stdVA(dbsI,rI) = std(valAccuracy);
        stdTT(dbsI,rI) = std(timeTrain);
        
        fprintf('Train time %s +/- %s | Validation accuracy %0.1f%% +/- %0.1f%%\n',...
            sec2str(meanTT(dbsI,rI)),sec2str(stdTT(dbsI,rI)),100*meanVA(dbsI,rI),100*stdVA(dbsI,rI));
        
    end
    
    %% Plot
    legendStr = [legendStr sprintf('%d',r)]; %#ok<AGROW>
    
    figure(fig);
    subplot(1,2,1);
    errorbar(dbSizeRange,100*meanVA(:,rI),100*stdVA(:,rI),[marker{rI} '-']);
    hold on
    box on
    grid on
    legend(legendStr,'Location','NW');
    ylabel('Validation accuracy (%)');
    xlabel('DB size (entries)');
    title(sprintf('epochs %d | batch size %d | dx %d, dy %d',numEpochs,batchSize,targetGoalDirX,targetGoalDirY));
    
    subplot(1,2,2);
    errorbar(dbSizeRange,meanTT(:,rI)/3600,stdTT(:,rI)/3600,[marker{rI} '-']);
    hold on
    box on
    grid on
    legend(legendStr,'Location','NW');
    ylabel('Train time (h)');
    xlabel('DB size (entries)');
    title(sprintf('%d trials | %d GPUs | %s',numTrials,numGPUs,sec2str(toc(tttt))));
    
    drawnow
    
    exportFigure(fig,sprintf('deepLearning/_optimalMove/_plots/dbSizeRadius_epochs%d_batch%d_trials%d_x%d_y%d',...
        numEpochs,batchSize,numTrials,targetGoalDirX,targetGoalDirY),'pdf',[10 6]);
end

%% Final plot
clf
subplot(1,2,1);
contourf(rRange,dbSizeRange,100*meanVA,'ShowText','on');
colormap('jet');
box on
grid on
ylabel('DB size');
xlabel('Radius');
title(sprintf('Validation accuracy | epochs %d | batch size %d | dx %d, dy %d',...
    numEpochs,batchSize,targetGoalDirX,targetGoalDirY));

subplot(1,2,2);
contourf(rRange,dbSizeRange,meanTT/3600,'ShowText','on');
colormap('jet');
box on
grid on
ylabel('DB size');
xlabel('Radius');
title(sprintf('Train time (h) | %d trials | %s',numTrials,sec2str(toc(tttt))));

exportFigure(fig,sprintf('deepLearning/_optimalMove/_plots/dbSizeRadius2_epochs%d_batch%d_trials%d_x%d_y%d',...
    numEpochs,batchSize,numTrials,targetGoalDirX,targetGoalDirY),'pdf',[10 6]);

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttt)));
diary off
