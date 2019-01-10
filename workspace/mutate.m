function newGene = mutate(gene, mutationRate, geneMin, geneMax)
%% Mutates the existing gene
% Vadim Bulitko
% Feb 16, 2016

newGene = gene;

for j = 1:length(gene)
    newGene(j) = newGene(j) + mutationRate(j)*randn;
    newGene(j) = min(newGene(j),geneMax(j));
    newGene(j) = max(newGene(j),geneMin(j));
end

end
