function [ mapList, problems ] = prepForAsync( scenarioName )
% Toukir Imam (mdtoukir@ualberta.ca
x = load(scenarioName);
outFileName = strcat(scenarioName,'_async');
mapList =struct();
for i =1:length(x.maps)
    mapList(i).map =x.maps{i};
end

for i =1:length(x.problem)
    p = x.problem(i);
    myMap = mapList(p.mapInd).map;
    mystart = p.start;
    mygoal =p.goal;
    [~,diff,~] = aStarDistance(myMap,mystart,mygoal);
    x.problem(i).aStarDifficulty = diff;
end
problems = x.problem;
save(outFileName,'mapList','problems');


end

