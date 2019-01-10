function [ gene ] = randGene( geneMin,geneMax )
% Toukir Imam(mdtoukir@ualberta.ca
gene = zeros(size(geneMax));
for j = 1:length(geneMax)
    gene(j) = randr([geneMin(j),geneMax(j)]);
end



end

