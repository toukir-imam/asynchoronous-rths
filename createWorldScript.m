scenarioName = 'scenarios/mm_8_1024.mat';
mapId = 1;
numEateries = 2;
cutOffWindow = [50,500];

worldAL = createWorldAL(scenarioName,mapId,numEateries,cutOffWindow)
save('worlds/world1.mat','worldAL');