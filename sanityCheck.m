function [ meanSubopt,isSolved ] = sanityCheck(gene )
% Run test on smaller problem to check the sanity of gene
diary on
x = load('scenarios/uniMap_342_17100.mat');
nProblems = length(x.problem);
cutoff =2000000;
errorRate =0;

[subopt, sc, solved] = geneEval(gene,x.problem,x.maps,nProblems,cutoff,errorRate);
meanSubopt = mean(subopt);
numSolved = sum(solved);
if numSolved == nProblems
    isSolved = true;
else
    isSolved = false;
end
fprintf('sanity check results: subopt : %.2f, numSolved %i / %i\n',meanSubopt,numSolved, nProblems);

end

