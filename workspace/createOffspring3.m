function [ agent ] = createOffspring3( id,problem,maps,pGene,mutationRate,geneMin,geneMax,energy,energyMultipler)
%Author: Toukir Imam (mdtoukir@ualberta.ca)
%create offspring using the old style
%ifPgene is NaN, a random gene will be created


numProblem = length(problem);
problemId = randi([1,numProblem]);


start = problem(problemId).start;

goal =  problem(problemId).goal;

mapId = problem(problemId).mapInd;
map = maps{mapId};

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

if (~isfield(problem(problemId),'h0'))
   h0 = computeH0_mex(map,goal);
else
   h0 = problem(problemId).h0;
end

    
hStar = problem(problemId).optimalTravelCost; 

    

if isnan(energy)
    energy = hStar*energyMultipler;
end

agent = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,1);



end

