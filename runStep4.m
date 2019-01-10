function agent = runStep4(agent,errorRate)
%% Runs a single step of a given agent
% Vadim Bulitko
% Feb 16, 2016

%% Do nothing if we are already at the goal
if (agent.x == agent.goal.x && agent.y == agent.goal.y)
    return
end
if ~isempty(agent.path)
    s = 'here'
    iNext = agent.path(end);
    agent.path =agent.path(1:end-1);
    agent.travelCost = agent.travelCost + agent.pathCost(end);
    agent.energy = agent.energy-agent.pathCost(end);
    agent.pathCost = agent.pathCost(1:end-1);
    [y,x] = ind2sub(size(agent.map),iNext);
    agent.x = x;
    agent.y =y;
    return;
end

%learningOperator = round(agent.gene(1));
%weightC = agent.gene(2);
%weightH = agent.gene(3);
%beamWidth = agent.gene(4);
%markExpendable = round(agent.gene(5));
%da = round(agent.gene(6));


goalI = sub2ind(size(agent.map),agent.goal.y,agent.goal.x);

%%Plan
lookahead =agent.gene(1);
%alpha = agent.gene(8);
%beta = agent.gene(9);
%gamma = agent.gene(10);
expansion = 0;
numExpandedState = 0;

curI = sub2ind(size(agent.map),agent.y,agent.x);
openN =[curI];
openG =[0];
openH =[getH(curI,agent.h,errorRate)];
openF =[getH(curI,agent.h,errorRate)];

closedN =[];
closedG =[];
closedH =[];
closedF =[];
sucTree = 0;
beforeI = curI;
before = getH(curI,agent.h,errorRate);
while (expansion <lookahead)

    %get the minimum F from open
    expansion = expansion +1;
    curI = openN(1);
    iG = openG(1);
    iH=openH(1);
    iF = openF(1);
    if curI ==goalI
        s = 'noway';
        break;
    end
    %put it in closed
    clEnd = length(closedN)+1;
    closedN(clEnd) = curI;
    closedG(clEnd) = iG;
    closedH(clEnd) =iH;
    closedF(clEnd) = iF;
    
    %delete it from open
    openN =openN(2:end);
    openG =openG(2:end);
    openH =openH(2:end);
    openF =openF(2:end);
    
    %get neighbors of curN
    curN = curI +agent.frontier;
    availableN = ~agent.map(curN);
    curN = curN(availableN);
    curG = iG + agent.g(availableN);
    curH = getH(curN,agent.h,errorRate);
    curF = curH + curG;
    for i =1:length(curN)
        i;
        sucTree;
        %if not in open put it in open
        if ~any(closedN ==curN(i))
            if any(openN ==curN(i))
                prevG = openG(find(openN==curN(i)));
            else
                l = length(openN)+1;
                openN(l) = curN(i);
                openG(l) = Inf;
                openF(l) = curF(i);
                openH(l) = curH(i);
                prevG = Inf;
            end
            if prevG > curG(i)
                openG(find(openN==curN(i)))=curG(i);

                %add to the suc tree
                if ~any(sucTree(:,1) == curN(i))
                   [rowS, colS] = size(sucTree);
                   sucTree(rowS+1,1) = curN(i);
                end
                if ~any(sucTree(1,:) == curI)
                   [rowS, colS] = size(sucTree);
                   sucTree(1,colS+1) = curI;
                end  
                   frow = find(sucTree(:,1) == curN(i));
                   fcol = find(sucTree(1,:) == curI);
                   sucTree(frow,2:end) =  0;
                   sucTree(frow,fcol) = curG(i) -iG;

            end
        end
        
    end
    %sort open list
 
    [openF, I ]= sort(openF);

    openN = openN(I);
    openG = openG(I);
    openH = openH(I);  
end

[~,minFi ]= min(openF);
subgoal = openN(minFi);
agent.subgoal =subgoal;
agent.sucTree =sucTree;
iNext = subgoal;
path = [iNext];
pathCost = [];

while iNext ~= beforeI
    rowId = find(sucTree(:,1) ==iNext);
    colId = find(sucTree(rowId,2:end))+1;
    sP = sucTree(1,colId);
    cost = sucTree(rowId,colId);
    if sP ==beforeI
        break;
    end
    path = [path sP];
    pathCost = [pathCost cost];
    iNext = sP;
end
agent.path = path;
agent.pathCost =pathCost;
%sum(pathCost);
if length(agent.path) >0
    iNext = agent.path(end);
    agent.path =agent.path(1:end-1);
    agent.travelCost = agent.travelCost + cost;
    agent.energy = agent.energy-cost;
    [y,x] = ind2sub(size(agent.map),iNext);
    agent.x = x;
    agent.y =y;
end
closedN;

%Dijkstra()
agent.h = setH(closedN,Inf,agent.h,errorRate);
s = 'starting';
while length (openN) >0
    length(closedN);
    [openH,I] = sort(openH);
    openN = openN(I);
    closedN;
    closedH;
    %openG = openG(I);
    %openF = openF(I);
    
    s = openN(1);
    sH = openH(1);
    
    %delete from open
    %delete it from open
    openN =openN(2:end);
    %openG =openG(2:end);
    openH =openH(2:end);
    %openF =openF(2:end);
    
     %delete it from closed
    
    if any(closedN == s)
        inC = find(closedN ==s);
        closedN(inC)=[];
        closedH(inC) =[];
        if length(closedN) ==0
            break
        end
    end
    
    rowId = find(sucTree(:,1) ==s);
    colId = find(sucTree(rowId,2:end))+1
    sP = sucTree(1,colId)
    c = sucTree(rowId,colId);
    
    %sP = find(find(sucTree(:,1) == s),:);
    spH = getH(sP,agent.h,errorRate)
    f = c + sH;

    if spH > f
        agent.h =setH(sP,f,agent.h,errorRate);
        if ~any(openN == sP)
            l = length(openN)+1;
            openN(l) = sP;
            openH(l) = f;
        end
            
    end
    
    
end
if length(closedN) ~=0
    for i=1:length(closedN)
        cid = closedN(i);
        ch = closedH(i);
        agent.h = setH(cid,ch,agent.h,errorRate);
    end
end
after = getH(beforeI,agent.h,errorRate);
return





end
