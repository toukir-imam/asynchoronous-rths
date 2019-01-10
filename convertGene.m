function [ asGene ] = convertGene( gene )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
w = gene(1);
wc = gene(2);
da = round(gene(3));
markExpendable = round(gene(4));
backtrack = round(gene(5));
learningOperator = round(gene(6));
beamWidth = gene(7);
learningQuota = gene(8);
learningRate = gene(9);

%learningOperator = round(gene(1));
%weightC = gene(2);
%weightH = gene(3);
%beamWidth = gene(4);
%markExpendable = round(gene(5));
%da = round(gene(6));
%learningRate = gene(7);
asGene = zeros(1,7);
asGene(1) = learningOperator;
asGene(2)= w*wc;
asGene(3) = w;
asGene(4) = beamWidth;
asGene(5) = markExpendable;
asGene(6) = da;
asGene(7) = learningRate;

end

