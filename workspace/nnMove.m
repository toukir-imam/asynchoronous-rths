function [distTraveled, meanScrubbing, solved] = nnMove(i,map,goal,r,cutOff,net,cm,addC)
%% Returns the expected distance traveled to a goal state
%% Heuristic-free move-driven agent
% Vadim Bulitko
% May 30, 2016

%% Preliminaries
% Set initial parameters
mapSize = size(map);
iGoal = sub2ind(mapSize,goal.y,goal.x);
distTraveled = 0;
nVisits = zeros(mapSize);
mapHeight = size(map,1);
neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
targetHeight = net.meta.normalization.imageSize(1);
targetWidth = net.meta.normalization.imageSize(2);


%% As long as we haven't reached the goal and haven't run out of quota
while (i ~= iGoal && distTraveled < cutOff)
    % Mark the visit to the current state
    nVisits(i) = nVisits(i) + 1;
    
    % Check if the goal is in our immediate neighborhood
    iN = i + neighborhoodI;
    availableN = ~map(iN);
    iN = iN(availableN);
    if (ismember(iGoal,iN))
        distTraveled = distTraveled + distanceI(i,iGoal,mapSize);
        i = iGoal;
        continue;
    end
    
    % Generate the neighborhood
    [y,x] = ind2sub(size(map),i);
    neighborhood = double(getNeighborhood(map,i,r));
    
    % see if the goal is inside or out of the neighborhood
    if (goal.x > x+r || goal.x < x-r || goal.y > y+r || goal.y < y-r)
        % the goal is outside
        % determine where the goal is relative to the current position
        goalAbove = goal.y > y;
        goalBelow = goal.y < y;
        goalLeft = goal.x < x;
        goalRight = goal.x > x;
        
        % bake the goal position into the neighborhood by raising the
        % values of the corresponding borders
        if (goalAbove)
            neighborhood(end,:) = addC+neighborhood(end,:);
        end
        if (goalBelow)
            neighborhood(1,:) = addC+neighborhood(1,:);
        end
        if (goalLeft)
            neighborhood(:,1) = addC+neighborhood(:,1);
        end
        if (goalRight)
            neighborhood(:,end) = addC+neighborhood(:,end);
        end
    else
        % the goal is inside
        neighborhood(1+r+goal.y-y, 1+r+goal.x-x) = 4;
    end
    
    % mark the current cell
    neighborhood(1+r, 1+r) = 6;
    
    % generate the NN input
    im = single(ind2rgb(neighborhood+1,cm));
    
    % Run it through the net to get the move
    im = gpuArray(single(im));
    im = imresize2(im,[targetHeight,targetWidth]);
    res = vl_simplenn(net, im, [], [], 'Mode', 'test');
    scores = squeeze(gather(res(end).x));
    
    % Hard arg max
    % [~, moveI] = max(scores);
    
    % Soft arg max
    [~,moveI] = histc(rand,[0;cumsum(scores(:))/sum(scores)]);

    % Produce the next move
    iNext = i + neighborhoodI(moveI);
    
    % Draw randomly from available moves if the NN-suggested move is unavailable
    if (map(iNext))
        iN = i + neighborhoodI;
        availableN = ~map(iN);
        iN = iN(availableN);
        iNext = iN(randi(length(iN)));
    end        
    
    % Make the move
    distTraveled = distTraveled + distanceI(i,iNext,mapSize);
    i = iNext;
    
end

%% Wrap up
nVisitsNZ = nVisits(nVisits > 0);
meanScrubbing = mean(nVisitsNZ);
solved = distTraveled <= cutOff;

end
