function [data, cm, addC, rp] = createTrainingDataOMmcn(scenarioName,r,numProblems,maxDataPerProblem,...
    goalDirectionX,goalDirectionY)
%% Create training data for the optimal move
% The Matconvnet version
% Vadim Bulitko
% May 29, 2016

%% Preliminaries
cm = [
    1 1 1;              % 0: empty is white
    0.25 0.25 0.25;     % 1: wall is black
    0 1 0;              % 2: highlighted empty is green
    0.25 0.5 0.25;      % 3: highlighted wall is dark green
    0 1 0;              % 4: double-highlighted empty is green
    0.25 0.5 0.25;      % 5: double-highlighted wall is dark green
    1 0 0               % 6: current state is bright red
    0 0 1               % 7: goal state is bright blue
    ];
addC = 2;

s2 = sqrt(2);
gCost = [s2 1 s2 1 s2 1 s2 1];
moveI = 1:numel(gCost);
moveLabel = {'NW','N','NE','E','SE','S','SW','W'};

% fPos = [100 95 1280 720];
% fig = figure('Position',fPos); %#ok<NASGU>

[~, sName, ~] = fileparts(scenarioName);

% Load the scenario and shuffle the problems
loadedScenario = load(scenarioName);
nProblems = length(loadedScenario.problem);
numProblems = min(numProblems,nProblems);

rp = randperm(nProblems);
loadedScenario.problem = loadedScenario.problem(rp);

fprintf('%s | %d problems | %d starts | r %d\n',sName,numProblems,maxDataPerProblem,r);

%% Go through problems
for problemI = 1:numProblems
    clear data
    
    % Create a database chunk for the goal states from that problem
    data = dbPerGoal(loadedScenario,problemI,r,maxDataPerProblem,goalDirectionX,goalDirectionY,...
        moveI,gCost,cm,addC,moveLabel,rp);
    
    % Save it
    dbFileName = sprintf('~/dl/_optimalMove/_neighborhoods/r%d_problems%d_starts%d_x%d_y%d_part%d.mat',...
        r,numProblems,maxDataPerProblem,goalDirectionX,goalDirectionY,problemI);
    save(dbFileName,'data'); %,'-v7.3');
end

end




%% Go through a few starts for the given problem's goal
function data = dbPerGoal(loadedScenario,problemI,r,maxDataPerProblem,goalDirectionX,goalDirectionY,...
    moveI,gCost,cm,addC,moveLabel,rp)

ttt = tic;

% get the problem
p = loadedScenario.problem(problemI);
map = loadedScenario.maps{p.mapInd};
goal = p.goal;
% fprintf('problem %d | %s (%d) | goal (%d,%d)\n',problemI,p.mapName,p.mapInd,goal.x,goal.y);

%% Compute h* wrt the goal
hStar = dijkstraMEX(map,goal);
hStar(hStar == 10000) = Inf;

mapHeight = size(map,1);
neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];

%% Determine reachable states
hStar(goal.y, goal.x) = Inf;  % don't include the goal in the reachable states
reachableStatesI = find(~isinf(hStar))';
hStar(goal.y, goal.x) = 0;

%% Compute optimal move
optimalMove = NaN(size(map));
for i = reachableStatesI
    % Generate the neighborhood
    iN = i + neighborhoodI;
    availableN = ~map(iN);
    iN = iN(availableN);
    gN = gCost(availableN);
    mN = moveI(availableN);
    hN = hStar(iN);
    fN = gN + hN;
    
    % Select the move as arg min f
    [~,minIndex] = min(fN);
    optimalMove(i) = mN(minIndex);
    assert(~isnan(optimalMove(i)));
end

% Go through a few start states, randomly picked from the reachable states
reachableStatesI = reachableStatesI(randperm(length(reachableStatesI)));
numStarts = min(maxDataPerProblem,length(reachableStatesI));
input = NaN(2*r+1,2*r+1,3,numStarts,'single');
target = NaN(1,numStarts);
recorded = false(1,numStarts);

%fprintf('%d reachable states | ',length(reachableStatesI));

%for rsI = 1:numStarts
parfor rsI = 1:numStarts
    i = reachableStatesI(rsI);
    [y,x] = ind2sub(size(map),i);
    
    % cut out the neighborhood
    neighborhood = double(getNeighborhood(map,i,r));
    
    % see if the goal is inside or out of the neighborhood
    if (goal.x > x+r || goal.x < x-r || goal.y > y+r || goal.y < y-r) %#ok<PFBNS>
        % the goal is outside
        % determine where the goal is relative to the current position
        deltaX = sign(goal.x - x);
        deltaY = sign(goal.y - y);
        
        if (isempty(goalDirectionX) && isempty(goalDirectionY))
            % no target goal direction given, use any direction, indicate it by baking in the color
            % bake the goal position into the neighborhood by raising the
            % values of the corresponding borders
            if (deltaY > 0)
                neighborhood(end,:) = addC+neighborhood(end,:);
            end
            if (deltaY < 0)
                neighborhood(1,:) = addC+neighborhood(1,:);
            end
            if (deltaX < 0)
                neighborhood(:,1) = addC+neighborhood(:,1);
            end
            if (deltaX > 0)
                neighborhood(:,end) = addC+neighborhood(:,end);
            end
        else
            % at least one target goal direction is given, see if the instance at hand fits it
            if (~isempty(goalDirectionX) && goalDirectionX ~= deltaX)
                % wrong x direction, skip the instance
                continue;
            end
            
            if (~isempty(goalDirectionY) && goalDirectionY ~= deltaY)
                % wrong y direction, skip the instance
                continue;
            end
        end
    else
        % the goal is inside: mark it
        neighborhood(1+r+goal.y-y, 1+r+goal.x-x) = 7;
    end
    
    % mark the current cell
    neighborhood(1+r, 1+r) = 6;
    
    % add it to the data
    recorded(rsI) = true;
    im = single(ind2rgb(neighborhood+1,cm));
    input(:,:,:,rsI) = im;
    target(rsI) = optimalMove(i); %#ok<PFBNS>
end

%% Trim the input and the class
data.input = input(:,:,:,recorded);
data.class = target(recorded);

assert(~any(isnan(data.class)));

%% Save the data
data.imageHeight = 2*r+1;
data.imageWidth = 2*r+1;
data.r = r;
data.cm = cm;
data.numClasses = numel(gCost);
data.moveLabel = moveLabel;
data.rp = rp;

fprintf(' %d (%d) | %s reachable states | %d entries | %s\n',...
    problemI,rp(problemI),hrNumber(length(reachableStatesI)),length(data.class),sec2str(toc(ttt)));

end

