function [ mSubopt,maxSubopt,mnTouched,mnTouchedH,solved ] = evaluate( maps,problem,gene ,fNproblems)
    
    nProblems = length(problem);
    problem =problem(randperm(length(problem)));
    finalNProblems = min(nProblems,fNproblems);
    
    cutoff = 10^5;
    errorRate =0;
    tstart = tic;
    %fprintf('evaluating on %d problems\n',finalNProblems)
    [subopt, ~, solved,nTouched,nTouchedH,tTouched,tTouchedH] = geneEval(gene,problem,maps,finalNProblems,cutoff,errorRate);
    solved = sum(solved);
    tend = toc(tstart);
    mSubopt = mean(subopt);
    maxSubopt = max(subopt);
    mnTouched = mean(nTouched);
    mnTouchedH = mean(nTouchedH);
    %logFile = 'logs/corr.txt';
    %fileID = fopen(logFile,'a');
    %fprintf(fileID,'%d %d %d\n',tTouched,tTouchedH,tend);
    %fclose(fileID);
    fprintf('time taken for evaluation %s \n',sec2str(tend));
    %fprintf('mean Subopt: %.3f\nnumSolved: %d / %d\nsolvedMeanSubopt: %.3f\n', ...
    %mean(subopt),sum(solved),length(solved),mean(subopt(solved)));
end

