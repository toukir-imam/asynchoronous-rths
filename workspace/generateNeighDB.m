%% Deep Learning: effects of database size and the neighborhood radius
%% Create training data
% Vadim Bulitko
% Sep 29, 2016

close all
clear
clc
diary off
format short g

%% Control parameters
dbSize = 10^6;
rRange = [5 10 25 50 75 113];

numDBChunks = 1000;

scenarioNameTrain = 'scenarios/MovingAI_342_493298.mat';

targetGoalDirX = [];
targetGoalDirY = [];

cnnTargetHeight = 227;
cnnTargetWidth = 227;

%% Preliminaries
diaryFileName = sprintf('deepLearning/_optimalMove/_logs/generateNeighDB_x%d_y%d.txt',...
    targetGoalDirX,targetGoalDirY);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('generateNeighDB.m | ');
disp(datetime);

fig = figure('Position',[100 95 1280 720]);

diary off
diary on

tttt = tic;

fprintf('Target goal direction: dx %d, dx %d\n',targetGoalDirX,targetGoalDirY);

%% Try different database sizes
numGoals = numDBChunks;
numStartsPerProblem = floor(dbSize/numGoals);

fprintf('\n>>>>>>>>>>>> Database size %s : %s goals x %s starts\n',hrNumber(dbSize),...
    hrNumber(numGoals),hrNumber(numStartsPerProblem));

%% Try different radii
rI = 0;
for r = rRange
    rI = rI + 1;
    fprintf('\n==== Radius %d\n\n',r);
    
    [data, ~, ~, ~] = createTrainingDataOMmcn(scenarioNameTrain,r,...
        numGoals,numStartsPerProblem,targetGoalDirX,targetGoalDirY);
    
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
    
end

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttt)));
diary off
