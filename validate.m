
clear;
%load('scenarios/mm_8_1024_opl.mat');
%load('scenarios/uniMap_200_10000')
load('scenarios/uniMap_342_1710_opl.mat')
%load('scenarios/uniMap_342_34200')
%load('scenarios/uniMap_8_80.mat')
%load('scenarios/MovingAI_342_493298.mat')
%gene =  [3.0522   26.3443   35.9914    0.4935    0.2708    0.9438 1];
%gene = convertGene([1.2998 2.6339  0.39132 0.70855 0.93316 3.1896 0.24461 0 0.27904]  )
%gene(5)=0

%gene = [1 1 1 0 0 0];
%gene = [3 7 1 1 1 0]
%gene = [20 0];
gene = [3.0000    3.4235    1.2998    0.2446    1.0000         0    0.2790];
testgene = load('logs/_self_compare_async_50_6_corrected.mat');
%gene = testgene.gGene{1}

nProblems = length(problem);
cutoff = 10^5;
errorRate =0;
[subopt, sc, solved,nTouched,nTouchedH] = geneEval(gene,problem,maps,nProblems,cutoff,errorRate);
mean(subopt)
sum(solved)
mean(nTouched)
mean(nTouchedH)
%save('logs/touching_correlation.mat','nTouched','nTouchedH','timeList');









% p = problem(12161);
%map = maps{p.mapInd}; %#ok<PFBNS>
%goal = p.goal;
%mapHeight = size(map,1);
%s2 = sqrt(2);
%neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight]; 
               
%gCost = [s2 1 s2 1 s2 1 s2 1];
%hs = p.optimalTravelCost;
%maxTravel = hs*cutoff;
%if (~isfield(p,'h0'))
%    h = computeH0_mex(map,goal);
%else
%    h = p.h0;
%end
%iStart = sub2ind(size(map),p.start.y,p.start.x);

% Run the algorithm
%[solution, sc, solved,sPath,sExStates,newMap] =  ...
%    uLRTATest(iStart,map,goal,neighborhoodI,gCost,h,h,errorRate,maxTravel,gene);

%energy =10^9;
%id =1;
%agent = createAgent(p.start.x,p.start.y,map,goal,energy,gene,id,h,hs,1);
%agent.path =[];
%agent.exStates=[];
%while ~(agent.x == agent.goal.x && agent.y==agent.goal.y) && ~(agent.energy==0)
%    agent = runStepTest(agent,0);
    %xh = agent.h -h;
    %xh = zeros(size(map))
    %displayMap(agent.map,xh,[0,0,1],false);
   
    %drawAgent(agent);
 
    %drawSomething(p.start.x,p.start.y,'g');
    %drawSomething(goal.x,goal.y,'r');

    %drawnow
    
%end
%xh = zeros(size(map));
%displayMap(agent.map,xh,[0,0,1],false);
%xx =sPath(find(sExStates));
%yy = agent.path(find(agent.exStates));
%for i =1:length(yy)
    %if ~(any(xx==yy(i)))
%        [y,x] = ind2sub(size(map),yy(i));
%        drawSomething(x,y,'g');
    %else
    %    drawSomething(x,y,'g');
    %end
%end
%drawnow
%for i =1:length(xx)
%[y,x] = ind2sub(size(map),xx(i));
%    if ~any(yy == xx(i))
%        drawSomething(x,y,'r');
%    else
%        drawSomething(x,y,'y');
%    end
        
%end
%drawSomething(agent.x,agent.y,'b');
%drawnow
%i = sub2ind(size(agent.map),agent.y,agent.x);
%iN = i + agent.frontier;
%availableN = ~agent.map(iN);















