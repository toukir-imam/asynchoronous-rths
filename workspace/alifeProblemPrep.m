%% Prepare some problems for A-life
% Vadim Bulitko
% February 17, 2016

close all
clear
clc
diary off

format short g

%% Preliminaries & control parameters
targetNumProblems = 100;
hsRange = [50, 300];
lrtaSuboptRange = [10, 50];

pFound = NaN(1,targetNumProblems);
pFoundHS = NaN(1,targetNumProblems);

rng('shuffle');

%scenarioName = 'scenarios/yngvi_5.mat';
%scenarioName = 'scenarios/mm_8_128.mat';
%scenarioName = 'scenarios/mm_8_128_Cropped_53.mat';
% scenarioName = 'scenarios/mini012_100.mat';
%scenarioName = 'scenarios/mm_8_1024.mat';
scenarioName = 'scenarios/MovingAI_342_493298.mat';

[~, sName, ~] = fileparts(scenarioName);
diaryFileName = sprintf('logs/alifeProblemPrep_%s_%d.txt',sName,targetNumProblems);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('alifeProblemPrep.m |');
disp(datetime);

diary off
diary on

ttt = tic;


%% Load scenario
load(scenarioName); 
numProblems = length(problem);

[~, sName, ~] = fileparts(scenarioName);

fprintf('Scenario %s\n',scenarioName);

%% Run many problems
for pN = 1:targetNumProblems
    
    %% Find a difficult problem
    while (true)
        pNumber = randi(length(problem));
        p = problem(pNumber);
        map = maps{p.mapInd};
        goal = p.goal;
        
        % Compute h*
        hStarMEX = dijkstraMEX(map,p.goal);
        hsS0 = hStarMEX(p.start.y,p.start.x);
        fprintf('Problem %d | (%d,%d) -> (%d,%d) | h* %0.1f\n',...
            pNumber,p.start.x,p.start.y,p.goal.x,p.goal.y,hsS0);
        
        if (hsS0 < hsRange(1) || hsS0 > hsRange(2))
            continue;
        end
        
        %% Run a few benchmarks
        mapHeight = size(map,1);
        s2 = sqrt(2);
        neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
        gCost = [s2 1 s2 1 s2 1 s2 1];
        
        % Mark the goal cell as a wall so that it is not updated
        map(goal.y, goal.x) = true;
        updateIndex = find(~map)';
        numCells = length(updateIndex);
        
        % Fill in the heuristic with the initial values
        h = zeros(size(map));
        for i = updateIndex
            [yi, xi] = ind2sub(size(map),i);
            h(i) = distance(xi,yi,goal.x,goal.y);
        end
        h(map) = Inf;
        h(goal.y, goal.x) = 0;
        
        % Run several algorithms
        iStart = sub2ind(size(map),p.start.y,p.start.x);
        map(goal.y,goal.x) = false;                         % enable the goal to be reachable
        
        [hLRTA, ~, ~] = wLRTA_mex(iStart,map,goal,neighborhoodI,gCost,h,1,0,Inf);
        %[hwbLRTA, ~, ~] = wbLRTA_mex(iStart,map,goal,neighborhoodI,gCost,h,64,1,0.0001,errorRate,Inf);
        fprintf('\tLRTA* suboptimality %0.1fx\n',hLRTA/hsS0);
        %fprintf('\t64-1-LRTA* suboptimality %0.1fx\n\n',hwbLRTA/hsS0);
        
        if (hLRTA/hsS0 >= lrtaSuboptRange(1) && hLRTA/hsS0 <= lrtaSuboptRange(2))
            break;
        end
        
    end
    
    % Recompute h0
    h0 = zeros(size(map));
    for y = 1:size(map,1)
        for x = 1:size(map,2)
            h0(y,x) = distance(x,y,goal.x,goal.y);
        end
    end
    
    fprintf('Problem %d (%d out of %d) | h* %0.1f | LRTA* subopt %0.1f\n',...
        pNumber,pN,targetNumProblems,hsS0,hLRTA/hsS0);
    pFound(pN) = pNumber;
    pFoundHS(pN) = hsS0;
    pFoundH{pN} = h0; %#ok<SAGROW>
end

%% Save the data
save(sprintf('data/alifeProblemPrep_%s_%d.mat',sName,targetNumProblems),...
    'sName','targetNumProblems','pFound','pFoundH','hsRange','lrtaSuboptRange','pFoundHS');

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(ttt)));
diary off

