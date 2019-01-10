function [ agent ] = createOffspring6( id,problem,maps,pGene,mutationRate,geneMin,geneMax,energyMultiplier,attr)
%Author: Toukir Imam (mdtoukir@ualberta.ca)
%create offspring using the old style
%ifP1gene is NaN, a random gene will be created
%Meiosis dance is performed between p1Gene and p2Gene
%energy is energyMultiplier times optimal travel cost


numProblem = length(problem);

problemId = randi([1,numProblem]);
%OTC
hStar = problem(problemId).optimalTravelCost;
aStarDifficulty = problem(problemId).aStarDifficulty;
%food value
foodValue = hStar*aStarDifficulty;

%while ~(foodValue > attr.lBound && foodValue <attr.uBound)
%    problemId = randi([1,numProblem]);
%    hStar = problem(problemId).optimalTravelCost;
%    aStarDifficulty = problem(problemId).aStarDifficulty;
%    %food value
%    foodValue = hStar*aStarDifficulty;

%end
energy = foodValue *energyMultiplier;
start = problem(problemId).start;

goal =  problem(problemId).goal;

mapId = problem(problemId).mapInd;
map = maps(mapId).map;


% Mutate genome
if sum(mutationRate(:))>0
    gene = mutate(pGene, mutationRate, geneMin, geneMax);
else
    gene = pGene;
end

%h0 for the goal

if (~isfield(problem(problemId),'h0'))
   h0 = single(computeH0(map,goal));
else
   h0 = single(problem(problemId).h0);
end
energy = max(0,energy);



agent = createAgent(start.x,start.y,map,goal,energy,gene,id,h0,hStar,aStarDifficulty,1);
%check if it should start counting final form trials.
if energyMultiplier<=attr.finalForm
    agent.inFinalForm = true;
end

%Save the problemid
agent.problemId = problemId;


end

