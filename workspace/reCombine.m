function [ gene ] = reCombine(p1Gene,p2Gene )
%Toukir Imam (mdtoukir@ualberta.ca)

choice = randi([0,1],[1,length(p1Gene)]);
gene = zeros(size(choice));
gene(choice==1) = p1Gene(choice==1);
gene(choice==0) = p2Gene(choice==0);



end

