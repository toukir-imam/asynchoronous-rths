%% 
%author : Toukir (mdtoukir@ualberta.ca)

%clear workspace
clear;
clc

%input values
scenarioName = 'scenarios/mm_8_1024.mat';
mapId = 1;
numEateries = 3;
cutOffWindow = [50,1500];
%load map
load(scenarioName);
map = maps{mapId};
numProblems = length(problem);
numMaps = length(maps);
problemPerMap = round(numProblems./numMaps);

%optimal distance matrix
optMatrix = zeros([numEateries numEateries]);
h0s =[];
%select start and goal
mapSize = size(map);
%pick first point
point = randi([1,times(mapSize(1),mapSize(2))]); 
while map(point) ==true
    point = randi([1,times(mapSize(1),mapSize(2))]); 
end
    eateries = [point];
    
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
        while true
            [distTraveled, meanScrubbing, solved,h] = uLRTA(start,map,goal,neighborhoodI,gCost,h0,h,errorRate,cutOff,gene);
            if distTraveled == oldDistTraveled
                break
            else
                oldDistTraveled = distTraveled;
            end
        end
      if distTraveled <cutOffWindow(1) || distTraveled >cutOffWindow(2)
            discardFlag = true;
            break
        end
      optMatrix(length(eateries)+1,i) = distTraveled
    end
    if discardFlag ~=true
        eateries =[eateries start];
        h0s=[h0s h0];
    else
        for k = 1: length(eateries)
            optMatrix(length(eateries)+1,k) = 0;
        end
    end
end
eateries
optMatrix



