function [ mH  ] = drawSomething( x,y,color )
%Author : Toukir Imam
%   Detailed explanation goes here
    rectangle('Position',[x+0.5,y+0.5,0.4,0.4],'FaceColor',color,'EdgeColor',color);
    mH = gca;

end
