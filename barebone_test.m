load('scenarios/uniMap_342_1710.mat')

mymap = struct();
for i =1:length(maps)
    mymap(i).map = maps{i};
end
pop =50;
steps = 500;
start = tic;
barebone(pop,problem,mymap,steps)
tend = toc(start) 