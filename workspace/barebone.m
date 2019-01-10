 function [] =barebone(pop,problem,maps,steps)
p1Gene = NaN;
p2Gene =NaN;
geneMin = [1, 0, 0,0,0,0];
geneMax = [4, 10, 10,1,1,1];
noMutation = zeros(size(geneMax));
id =1;
energyMultiplier =0;
dum = createOffspring4(id,problem,maps,p1Gene,p2Gene,noMutation,geneMin,geneMax,energyMultiplier);

agents = repmat(dum,[1,pop]);
for i = 1:pop
    id =1 ;
    agents(i) = createOffspring4(id,problem,maps,p1Gene,p2Gene,noMutation,geneMin,geneMax,energyMultiplier);
    
    
end
for j = 1:steps
    if mod(j,100)==0
        j
    end
    for i = 1:pop
        agents(i) = runStep(agents(i),0);
        if ((agents(i).goal.x == agents(i).x) && (agents(i).goal.y == agents(i).y))
            agents(i) = createOffspring6(id,problem,maps,p1Gene,p2Gene,noMutation,geneMin,geneMax,energyMultiplier);
        end
    end
end
end