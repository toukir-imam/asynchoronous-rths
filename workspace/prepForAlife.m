clear;
load ('scenarios/MovingAI_342_493298.mat')
for i = 1:length(problem)
    if mod(i,1000)==0
        i
    end
    
    map =maps{problem(i).mapInd};
    problem(i).h0 = computeH0(map,problem(i).goal);
    
end
save('scenarios/MovingAI_342_493298_wh0.mat','maps','problem');
