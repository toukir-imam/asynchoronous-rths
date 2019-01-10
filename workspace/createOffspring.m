function [ agent ] = createOffspring( id,worldAL,pGene,mutationRate,geneMin,geneMax,energy )
%author Toukir Imam (mdtoukir@ualberta.ca)
%ifPgene is NaN, a random gene will be created
%unpack the worldAL struct
eateries = worldAL(1).eateries;
map = worldAL(1).map;
optMatrix = worldAL(1).optMatrix;



 %choose a eatery as starting position
startI = randi([1,length(eateries)]);
start = eateries(startI);
[startY,startX]= ind2sub(size(map),start);

% choose something else as goal
goalI = randi([1,length(eateries)]);
goalE = eateries(goalI);
while goalE == start
    goalI = randi([1,length(eateries)]);
    goalE = eateries(goalI);
end
[goal.y ,goal.x] = ind2sub(size(map),goalE);

%energy of 
%energy = optMatrix(startI,goalI)* energyMultiplier;

% Mutate genome
if isnan(pGene)
    for j = 1:length(geneMax)
        gene(j) = randr([geneMin(j),geneMax(j)]);
    end
else
    gene = mutate(pGene, mutationRate, geneMin, geneMax);
end
%korf
%gene = [1,1,1,0,0,0];


%h0 for the goal
h0= worldAL(goalI).h0s;
hStar = optMatrix(startI,goalI); 

agent = createAgent(startX,startY,map,goal,energy,gene,id,h0,hStar,1);

end

