
geneMax = [4 10 10 1 1 1 1];
geneMin = [1 1 1 0 0 0 0 ];
results =[];
halfMillionScenario= 'scenarios/MovingAI_342_493298_opl';%'scenarios/uniMap_342_1710.mat';%'scenarios/mm_8_8.mat';%'scenarios/uniMap_342_493164';
load(halfMillionScenario);
fNproblems = 4500;
for j = 1: 5
    for i = 1: 10
        gene = randGene(geneMin,geneMax);
        [ subopt,~,~,~,~ ] = evaluate(maps,problem,gene,fNproblems);
        results(j,i) = subopt;
    end
end


