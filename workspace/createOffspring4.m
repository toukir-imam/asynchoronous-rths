function [ agent ] = createOffspring4( id,problem,maps,p1Gene,p2Gene,mutationRate,geneMin,geneMax,energyMultipler)
%Author: Toukir Imam (mdtoukir@ualberta.ca)
%create offspring using the old style
%ifP1gene is NaN, a random gene will be created
%Meiosis dance is performed between p1Gene and p2Gene
%energy is energyMultiplier times optimal travel cost


numProblem = length(problem);
problemId = randi([1,numProblem]);

start = problem(problemId).start;

goal =  problem(problemId).goal;

mapId = problem(problemId).mapInd;
map = maps{mapId};


% Mutate genome
gene = zeros(size(geneMax));
if isnan(p1Gene)
    for j = 1:length(geneMax)
        gene(j) = randr([geneMin(j),geneMax(j)]);
    end
else 
    %check number of parents
    if isnan(p2Gene)
        %Mitosis
        gene = mutate(p1Gene, mutationRate, geneMin, geneMax);
    else
        %Meiosis Dance
        choice = randi([0,1],[1,length(geneMax)]);
        gene(choice==1) = p1Gene(choice==1);
        gene(choice==0) = p2Gene(choice==0);
        gene = mutate(gene, mutationRate, geneMin, geneMax);    
    end
    
end

%h0 for the goal

if (~isfield(problem(problemId),'h0'))
   h0 = computeH0_mex(map,goal);
else
   h0 = problem(problemId).h0;
end

%OTC
hStar = problem(problemId).optimalTravelCost; 

%Energy
energy = hStar*energyMultipler;


agent = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,1);

%Save the problemid
agent.problemId = problemId;


end

