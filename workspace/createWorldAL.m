function [ worldAL] = createWorldAL( scenarioName,mapId,numEateries,cutOffWindow )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% 
%author : Toukir (mdtoukir@ualberta.ca)

%input values
%scenarioName = 'scenarios/mm_8_1024.mat';
%mapId = 1;
%numEateries = 3;
%cutOffWindow = [50,1500];
%load map
load(scenarioName);
map = maps{mapId};
%numProblems = length(problem);
%numMaps = length(maps);
%problemPerMap = round(numProblems./numMaps);

%optimal distance matrix
optMatrix = zeros([numEateries numEateries]);
h0s =cell(1,numEateries);
%select start and goal
mapSize = size(map);
%pick first point
point = randi([1,times(mapSize(1),mapSize(2))]); 
while map(point) ==true
    point = randi([1,times(mapSize(1),mapSize(2))]); 
end
    eateries = [point];
    [y,x] = ind2sub(mapSize,point);
    sGole = struct('x',x,'y',y);
    h0s{1} = computeH0(map,sGole);
%chose next numEateries -1 points

while length(eateries) ~= numEateries
    point = randi([1,times(mapSize(1),mapSize(2))]); 
    
    %make sure the point is not in the walll
    while map(point) ==true
        point = randi([1,times(mapSize(1),mapSize(2))]); 
    end
    start = point;
    discardFlag = false;
    for i = 1:length(eateries)
        goalI = eateries(i);
        [y,x]= ind2sub(mapSize,goalI);
        goal = struct('x',x,'y',y);

        %setup ularta
        %gene 
        gene = [1 1 0  0 0 1 0 0];       % Korf's LRTA*

        %gcost
        s2 = sqrt(2);
        gCost = [s2 1 s2 1 s2 1 s2 1];

        %h
        h0 = computeH0(map,goal);
        h = h0;
        %errorrate and cutoff
        errorRate = 0;
        cutOff = 10000;

        %neighbourhoodI
        mapHeight = size(map,1);
        neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
        oldDistTraveled = 0;
        iter =9999;
        while iter>0
            iter=iter-1;
            [distTraveled, meanScrubbing, solved,h] = uLRTA(start,map,goal,neighborhoodI,gCost,h0,h,errorRate,cutOff,gene);
            %if distTraveled == oldDistTraveled
            %    break
            %else
            %    oldDistTraveled = distTraveled;
            %end
        end
      if distTraveled <cutOffWindow(1) || distTraveled >cutOffWindow(2)
            discardFlag = true;
            break
        end
      optMatrix(length(eateries)+1,i) = distTraveled
    end
    if discardFlag ~=true
        %find h0 for the start point
        [y,x]= ind2sub(mapSize,start);
        startS = struct('x',x,'y',y);
        h0 = computeH0(map,startS);
        eateries =[eateries start];
        h0s{length(eateries)}=h0;
       
    else
        for k = 1: length(eateries)
            optMatrix(length(eateries)+1,k) = 0;
        end
    end
end
optMatrix = tril(optMatrix)' + tril(optMatrix);
worldAL = struct('eateries',eateries,'optMatrix',optMatrix,'h0s',h0s,'map',map);




end

