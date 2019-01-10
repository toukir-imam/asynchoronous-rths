%% Deep Learning: convert a database of neighborhoods to PNG files for Digits
% Vadim Bulitko
% Sep 25, 2016

close all
clear
clc
diary off
format short g

%% Control parameters
dbSizeRange = [75000];
rRange = [75];

scenarioNameTrain = 'scenarios/MovingAI_342_493298.mat';

targetGoalDirX = [];
targetGoalDirY = [];

cnnTargetHeight = 227;
cnnTargetWidth = 227;


%% Preliminaries
diaryFileName = sprintf('deepLearning/_optimalMove/_logs/mat2png_x%d_y%d.txt',targetGoalDirX,targetGoalDirY);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('mat2png.m | ');
disp(datetime);

fig = figure('Position',[100 95 1280 720]);

diary off
diary on

tttt = tic;

%% Try different database sizes
dbsI = 0;
for dbSize = dbSizeRange
    dbsI = dbsI + 1;
    
    numProblems = floor(dbSize/10);
    numStartsPerProblem = floor(dbSize/numProblems);
    
    fprintf('\n>>>>>>>>>>>> Database size %s : %d problems x %d starts\n',hrNumber(dbSize),numProblems,numStartsPerProblem);
    
    %% Try different radii
    rI = 0;
    for r = rRange
        rI = rI + 1;
        fprintf('\n==== Radius %d\n\n',r);
        
        %% Load or generate neighborhoods data
        clear data
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
        
        %% Convert to PNG
        numEntries = length(data.class);
        datasetPath = sprintf('~/dl/_optimalMove/neigborhoods_r%d_dx%d_dy%d_total%d',r,targetGoalDirX,targetGoalDirY,numEntries);
        
        % Create the folder structure
        for c = 1:data.numClasses
            classPath = sprintf('%s/%d',datasetPath,c);
            [~,~,~] = mkdir(classPath);
            classEntries = find(data.class == c);
            
            % Generate PNGs
            for e = classEntries
                imwrite(data.input(:,:,:,e),sprintf('%s/%08d.png',classPath,e));
            end
        end
        
    end
end

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttt)));
diary off
