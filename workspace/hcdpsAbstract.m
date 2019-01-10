function [reps, absMap, movesClimbed] = hcdpsAbstract(map,cutOff)
% hcdps - creates abstract regions

%% Setup
mapSize = size(map);
absMap = nan(mapSize);
absMap(map) = -1;           % walls
reps = [];
display = true;

% This is just to get the frontier vector
goal.x = 1;
goal.y = 1;
agent = createAgent(1,1,map,goal,[],[],[],[],[]);
frontier = agent.frontier;
g = agent.g;

movesClimbed = 0;

%% As long as there are unassigned states, create a region and grow it
while (any(isnan(absMap(:))))
    
    % Start a new region by selecting a random state among the unassigned ones
    unassignedStates = find(isnan(absMap(:)));
    r = unassignedStates(randi(length(unassignedStates)));
    reps = [reps r]; %#ok<AGROW>
    closed = false(mapSize);
    
    if (display)
        fprintf('Starting region %d\n',r); %#ok<UNRCH>
        visualize(reps,absMap,map);
        %pause
    end
    
    % Grow the region with reachability-constrained BFS
    queue = [r]; %#ok<NBRAK>
    while (~isempty(queue))
        
        % Remove the head of the queue
        s = queue(1);
        queue = queue(2:end);
        
        % Check its reachability from the representative
        [isReach, numClimbed] = bdreachable(r,s,map,cutOff,frontier,g);
        movesClimbed = movesClimbed + numClimbed;
        
        if (~isReach)
            closed(s) = true;
            continue;
        end
        
        %fprintf('%d is bi-reachable from %d\n',r,s);
        
        % Add it to the region
        absMap(s) = r;
        
        % Add its children to the queue
        children = frontier + s;
        queue = [queue children(isnan(absMap(children)) & ~ismember(children,queue) & ~closed(children))]; %#ok<AGROW>
        
        %pause
        
    end
    
    if (display)
        fprintf('...region %d was grown to %d states\n\n',r,length(find(r == absMap(:)))); %#ok<UNRCH>
        visualize(reps,absMap,map);
        %pause
        
    end
    
end

end


function [r, numClimbed] = bdreachable(s1,s2,map,cutOff,frontier,g)
% bdreachable checks bi-directional reachability of two states

numClimbed = 0;

if (s1 == s2)
    r = true;
    return
else
    [r, ~, n, ~] = mexReachable(map,s1,s2,int32(frontier),g,cutOff,true);
    numClimbed = numClimbed + n;
    if (~r)
        return;
    end
    [r, ~, n, ~] = mexReachable(map,s2,s1,int32(frontier),g,cutOff,true);
    numClimbed = numClimbed + n;
end

end

function visualize(reps,absMap,map)
% visualize the current map

dM = double(absMap);
dM(map) = NaN;
dM(reps) = -1;

pcolor2([],[],dM,0);
axis tight;
colorbar off

colormap lines

drawnow

end
