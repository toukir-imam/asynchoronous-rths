function [ agent ] = createOffspringSexual( id,problem,maps,p1Gene,p2Gene,mutationRate,geneMin,geneMax,energy,energyMultipler )
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
gene = zeros(1,length(geneMax));
if isnan(p1Gene)
    for j = 1:length(geneMax)
        gene(j) = randr([geneMin(j),geneMax(j)]);
    end
else
    %Miosis Dance
    choice = randi([0,1],[1,length(geneMax)]);
    gene(choice==1) = p1Gene(choice==1);
    gene(choice==0) = p2Gene(choice==0);
    gene = mutate(gene, mutationRate, geneMin, geneMax);
end
%korf
%gene = [1,1,1,0,0,0];


%h0 for the goal
%h0 = problem(problemId).h0;
h0 = computeH0_mex(map,goal);
hStar = problem(problemId).optimalTravelCost; 

%energy

if isnan(energy)
    energy = hStar*energyMultipler;
end


agent = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,1);



end

