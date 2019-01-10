function [ output_args ] = drawAgent( agent )
%Author : Toukir Imam
%   Detailed explanation goes here
    %viscircles([agent.x ,agent.y],.1,'color','red');
    x = agent.x;
    y =agent.y;
    rectangle('Position',[x+0.7,y+0.7,0.6,0.6],'FaceColor','r','EdgeColor','r');

end

