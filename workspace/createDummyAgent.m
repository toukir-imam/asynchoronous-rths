function [ dum ] = createDummyAgent(maps,problem,geneMax,attr)
% Toukir Imam(mdtoukir@ualberta.ca)
%creates a dummy agent.
%The maps,problem, and geneMax is necessary to make sure the field types of
%the struct are what they supposed to be;

id = 0;
gene =zeros(size(geneMax));

mutationRate =gene;
geneMin = gene;
energyMultipler = 0;

dum = createOffspring6( id,problem,maps,gene,mutationRate,geneMin,geneMax,energyMultipler,attr);
dum.isDummy =true;

end

