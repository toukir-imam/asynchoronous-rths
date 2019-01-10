function [  ] = theFinalCut( agent,scenarioName )
% shows the agents finished paths
if ~isfield(agent,'paths') || ~isfield(agent,'path')
    fprintf('No path to review');
end

% sanity checks
numTrials = agent.numTrials;
assert(numTrials == length(agent.paths));
assert(numTrials == length(agent.subopt));
assert(numTrials == length(agent.finishedProblems));

%load scenario
load(scenarioName)
figure('Visible','off');


for i =1:numTrials
    path = agent.paths{i};
    pid =  agent.finishedProblems(i);
    mapId = problem(pid).mapInd;
    map = maps{mapId};
    start = problem(pid).start;
    goal = problem(pid).goal;
    
    %if (~isfield(problem(pid),'h0'))
    %    h0 = computeH0_mex(map,goal);
    %else
    %    h0 = problem(pid).h0;
    %end
    x = zeros(size(map));
    x(path) =1;
    %pathH=h0(path)+1;
    %h0(path)
    %size(pathH)
    %xh = pathH-h0 ;
    displayMap(map,x,[0,0,1],false);
    drawSomething(start.x,start.y,'g');
    drawSomething(goal.x,goal.y,'r');
    print('-bestfit',strcat('logs/',num2str(agent.id),'_',num2str(i),'.pdf'),'-dpdf');
    fprintf(num2str(i))
    drawnow
    %asd
end

% the last problem
path = agent.path;
pid =  agent.problemId;
mapId = problem(pid).mapInd;
map = maps{mapId};
start = problem(pid).start;
goal = problem(pid).goal;

%if (~isfield(problem(pid),'h0'))
%    h0 = computeH0_mex(map,goal);
%else
%    h0 = problem(pid).h0;
%end
x = zeros(size(map));
x(path) =1;
%pathH=h0(path)+1;
%h0(path)
%size(pathH)
%xh = pathH-h0 ;
displayMap(map,x,[0,0,1],false);

drawSomething(start.x,start.y,'g');
drawSomething(goal.x,goal.y,'r');
%print('-bestfit',strcat('logs/',num2str(agent.id),'_',num2str(i),'.pdf'),'-dpdf');
fprintf('last')
drawnow
%asd



