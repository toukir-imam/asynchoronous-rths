scenarioName = 'scenarios/uniMap_342_17100'
load(scenarioName);
for pid = 1: length(problem)
    mapId = problem(pid).mapInd;
    map = maps{mapId};
    goal = problem(pid).goal;
    hp = dijkstraMEX(map, goal);
    %% hill climb
    i = sub2ind(size(map),problem(pid).start.y,problem(pid).start.x);
    iGoal = sub2ind(size(map),problem(pid).goal.y,problem(pid).goal.x);
    mapHeight = size(map,1);
    neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
    step =0;
    while (i ~=iGoal)
        iN = i + neighborhoodI;
        availableN = ~map(iN);
        iN = iN(availableN);
        hN = getH(iN,hp,0);
        [~,minIndex] = min(hN);
        iNext = iN(minIndex);
        i = iNext;
        step = step +1;
    end
    problem(pid).optimalPathLength = step;

   
end
 save(strcat(scenarioName,'_opl.mat'),'problem','maps')
